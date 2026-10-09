import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:read_space/models/book.dart';
import 'package:read_space/models/hold.dart';

/// In-memory transactional library test harness reproducing Firestore transaction semantics.
class MemoryLibraryStore {
  final Map<String, Map<String, dynamic>> books = {};
  final Map<String, Map<String, dynamic>> holds = {};

  void seedBook(Book book) {
    books[book.id] = Map<String, dynamic>.from(book.toJson());
  }

  void seedHold(Hold hold) {
    holds[hold.id] = Map<String, dynamic>.from(hold.toJson());
  }

  Book? getBook(String id) {
    final data = books[id];
    if (data == null) return null;
    return Book.fromJson(data);
  }

  Hold? getHold(String id) {
    final data = holds[id];
    if (data == null) return null;
    return Hold.fromJson(data);
  }

  List<Hold> getActiveHoldsForUser(String userId, String bookId) {
    return holds.values
        .map((m) => Hold.fromJson(m))
        .where((h) =>
            h.userId == userId &&
            h.bookId == bookId &&
            (h.holdStatus == HoldStatus.pending || h.holdStatus == HoldStatus.ready))
        .toList();
  }

  /// Case 1 & 2: Reserve an available book in a transaction
  Hold reserveAvailableBook({required String userId, required String bookId}) {
    // 1. Duplicate hold check
    if (getActiveHoldsForUser(userId, bookId).isNotEmpty) {
      throw DuplicateHoldException('You already have an active hold on this book.');
    }

    // 2. Read book
    final bookData = books[bookId];
    if (bookData == null) {
      throw Exception('Book not found');
    }

    final availableCopies = (bookData['availableCopies'] as num?)?.toInt() ?? 0;
    if (availableCopies <= 0) {
      throw Exception('No copies available for direct reservation. Please join the queue instead.');
    }

    final newAvailableCopies = availableCopies - 1;
    final newStatus = newAvailableCopies == 0 ? BookStatus.reserved.name : BookStatus.available.name;

    final holdId = 'hold_${DateTime.now().microsecondsSinceEpoch}_${holds.length + 1}';
    final now = DateTime.now();

    final hold = Hold(
      id: holdId,
      bookId: bookId,
      userId: userId,
      createdAt: now,
      holdStatus: HoldStatus.ready,
      queuePosition: 0,
      readyAt: now,
      expiresAt: now.add(const Duration(hours: 48)),
    );

    // Atomic update
    bookData['availableCopies'] = newAvailableCopies;
    bookData['status'] = newStatus;
    holds[holdId] = hold.toJson();

    return hold;
  }

  /// Case 3: Join the hold queue for an unavailable / zero-stock book
  Hold joinHoldQueue({required String userId, required String bookId}) {
    // 1. Duplicate hold check
    if (getActiveHoldsForUser(userId, bookId).isNotEmpty) {
      throw DuplicateHoldException('You already have an active hold on this book.');
    }

    final bookData = books[bookId];
    if (bookData == null) {
      throw Exception('Book not found');
    }

    final currentHoldCount = (bookData['holdCount'] as num?)?.toInt() ?? 0;
    final newHoldCount = currentHoldCount + 1;

    final holdId = 'hold_${DateTime.now().microsecondsSinceEpoch}_${holds.length + 1}';
    final now = DateTime.now();

    final hold = Hold(
      id: holdId,
      bookId: bookId,
      userId: userId,
      createdAt: now,
      holdStatus: HoldStatus.pending,
      queuePosition: newHoldCount,
    );

    bookData['holdCount'] = newHoldCount;
    holds[holdId] = hold.toJson();

    return hold;
  }

  /// Case 5 & 6: Cancel a hold with stock restoration / queue advancement
  void cancelHold(String holdId) {
    final holdData = holds[holdId];
    if (holdData == null) return;

    final statusStr = holdData['holdStatus'] as String?;
    if (statusStr != 'pending' && statusStr != 'ready') {
      return;
    }

    final bookId = holdData['bookId'] as String;
    final bookData = books[bookId];
    if (bookData == null) {
      holdData['holdStatus'] = 'cancelled';
      return;
    }

    final isReady = statusStr == 'ready';

    // Retrieve other pending holds for this book ordered by queuePosition
    final otherPending = holds.values
        .where((m) =>
            m['id'] != holdId &&
            m['bookId'] == bookId &&
            m['holdStatus'] == 'pending')
        .map((m) => Hold.fromJson(m))
        .toList();

    otherPending.sort((a, b) => a.queuePosition.compareTo(b.queuePosition));

    // Cancel target hold
    holdData['holdStatus'] = 'cancelled';

    final availableCopies = (bookData['availableCopies'] as num?)?.toInt() ?? 0;
    final holdCount = (bookData['holdCount'] as num?)?.toInt() ?? 0;
    final now = DateTime.now();

    if (isReady) {
      if (otherPending.isNotEmpty) {
        // Promote next user in line
        final nextInLine = otherPending.first;
        final nextData = holds[nextInLine.id]!;
        nextData['holdStatus'] = 'ready';
        nextData['queuePosition'] = 0;
        nextData['readyAt'] = now.toIso8601String();
        nextData['expiresAt'] = now.add(const Duration(hours: 48)).toIso8601String();

        // Shift remaining queue
        for (int i = 1; i < otherPending.length; i++) {
          final doc = holds[otherPending[i].id]!;
          doc['queuePosition'] = i;
        }

        final newHoldCount = (holdCount > 0) ? holdCount - 1 : 0;
        bookData['holdCount'] = newHoldCount;
      } else {
        // No waitlist -> restore stock
        final newAvailable = availableCopies + 1;
        bookData['availableCopies'] = newAvailable;
        bookData['status'] = BookStatus.available.name;
      }
    } else {
      // Pending hold cancelled: re-sequence remaining pending users
      int newPos = 1;
      for (final doc in otherPending) {
        final m = holds[doc.id]!;
        m['queuePosition'] = newPos;
        newPos++;
      }

      final newHoldCount = (holdCount > 0) ? holdCount - 1 : 0;
      bookData['holdCount'] = newHoldCount;
    }
  }
}

Book _createTestBook({
  required String id,
  required String title,
  int totalCopies = 2,
  int availableCopies = 2,
  int holdCount = 0,
  BookStatus status = BookStatus.available,
}) {
  return Book(
    id: id,
    title: title,
    author: 'Test Author',
    isbn: '9780123456789',
    genre: 'Technology',
    description: 'Test description',
    pages: 250,
    language: 'English',
    status: status,
    section: LibrarySection.general,
    shelfLocation: 'A-01',
    totalCopies: totalCopies,
    availableCopies: availableCopies,
    holdCount: holdCount,
    coverColor: const Color(0xFF1E3A8A),
  );
}

void main() {
  group('Reservation & Queue Integration Tests', () {
    late MemoryLibraryStore store;

    setUp(() {
      store = MemoryLibraryStore();
    });

    // ── Case 1: Reserve on an available book ─────────────────────────────────
    test('Case 1: Reserve available book creates ready hold and reduces stock by 1', () {
      final book = _createTestBook(id: 'b1', title: 'Design Patterns', availableCopies: 2);
      store.seedBook(book);

      final hold = store.reserveAvailableBook(userId: 'u1', bookId: 'b1');

      expect(hold.holdStatus, equals(HoldStatus.ready));
      expect(hold.queuePosition, equals(0));
      expect(hold.readyAt, isNotNull);
      expect(hold.expiresAt, isNotNull);

      final updatedBook = store.getBook('b1')!;
      expect(updatedBook.availableCopies, equals(1));
      expect(updatedBook.status, equals(BookStatus.available));
    });

    // ── Case 2: Reserve last copy sets availableCopies to 0 and updates status ──
    test('Case 2: Reserving last copy sets availableCopies to 0 and status to reserved', () {
      final book = _createTestBook(id: 'b2', title: 'Clean Architecture', availableCopies: 1);
      store.seedBook(book);

      store.reserveAvailableBook(userId: 'u1', bookId: 'b2');

      final updatedBook = store.getBook('b2')!;
      expect(updatedBook.availableCopies, equals(0));
      expect(updatedBook.status, equals(BookStatus.reserved));

      // Attempting another direct reservation fails
      expect(
        () => store.reserveAvailableBook(userId: 'u2', bookId: 'b2'),
        throwsException,
      );
    });

    // ── Case 3: Zero-stock book joins queue and assigns queue position ───────
    test('Case 3: Zero-stock book enters queue, increments holdCount and sets queuePosition', () {
      final book = _createTestBook(
        id: 'b3',
        title: 'Refactoring',
        availableCopies: 0,
        holdCount: 0,
        status: BookStatus.onLoan,
      );
      store.seedBook(book);

      final hold1 = store.joinHoldQueue(userId: 'u1', bookId: 'b3');
      expect(hold1.holdStatus, equals(HoldStatus.pending));
      expect(hold1.queuePosition, equals(1));

      final hold2 = store.joinHoldQueue(userId: 'u2', bookId: 'b3');
      expect(hold2.holdStatus, equals(HoldStatus.pending));
      expect(hold2.queuePosition, equals(2));

      final updatedBook = store.getBook('b3')!;
      expect(updatedBook.holdCount, equals(2));
      expect(updatedBook.availableCopies, equals(0));
    });

    // ── Case 4: Duplicate hold prevention ────────────────────────────────────
    test('Case 4: Duplicate hold prevention blocks user from holding the same book twice', () {
      final book = _createTestBook(id: 'b4', title: 'The Pragmatic Programmer', availableCopies: 2);
      store.seedBook(book);

      store.reserveAvailableBook(userId: 'u1', bookId: 'b4');

      // Attempting to reserve again by same user throws DuplicateHoldException
      expect(
        () => store.reserveAvailableBook(userId: 'u1', bookId: 'b4'),
        throwsA(isA<DuplicateHoldException>()),
      );

      // Attempting to join queue by same user also throws DuplicateHoldException
      expect(
        () => store.joinHoldQueue(userId: 'u1', bookId: 'b4'),
        throwsA(isA<DuplicateHoldException>()),
      );
    });

    // ── Case 5: Cancellation of ready hold restores stock when no queue ───────
    test('Case 5: Cancellation of ready hold with empty queue restores available stock', () {
      final book = _createTestBook(
        id: 'b5',
        title: 'Structure and Interpretation',
        availableCopies: 1,
      );
      store.seedBook(book);

      final hold = store.reserveAvailableBook(userId: 'u1', bookId: 'b5');
      expect(store.getBook('b5')!.availableCopies, equals(0));

      store.cancelHold(hold.id);

      final updatedHold = store.getHold(hold.id)!;
      expect(updatedHold.holdStatus, equals(HoldStatus.cancelled));

      final updatedBook = store.getBook('b5')!;
      expect(updatedBook.availableCopies, equals(1));
      expect(updatedBook.status, equals(BookStatus.available));
    });

    // ── Case 6: Cancellation with queue promotes next in line and shifts positions
    test('Case 6: Cancellation of ready hold promotes first in queue and shifts remaining positions', () {
      final book = _createTestBook(
        id: 'b6',
        title: 'Domain-Driven Design',
        availableCopies: 1,
      );
      store.seedBook(book);

      // User 1 reserves the last available copy
      final readyHold = store.reserveAvailableBook(userId: 'u1', bookId: 'b6');
      expect(readyHold.holdStatus, equals(HoldStatus.ready));

      // User 2 and User 3 join the waitlist queue
      final pendingHold1 = store.joinHoldQueue(userId: 'u2', bookId: 'b6');
      final pendingHold2 = store.joinHoldQueue(userId: 'u3', bookId: 'b6');
      expect(pendingHold1.queuePosition, equals(1));
      expect(pendingHold2.queuePosition, equals(2));
      expect(store.getBook('b6')!.holdCount, equals(2));

      // User 1 cancels their ready hold
      store.cancelHold(readyHold.id);

      // Stock should NOT increase because it was immediately given to User 2
      final updatedBook = store.getBook('b6')!;
      expect(updatedBook.availableCopies, equals(0));
      expect(updatedBook.holdCount, equals(1)); // 2 was decremented to 1

      // User 2 is promoted to ready for pickup!
      final promotedHold = store.getHold(pendingHold1.id)!;
      expect(promotedHold.holdStatus, equals(HoldStatus.ready));
      expect(promotedHold.queuePosition, equals(0));
      expect(promotedHold.readyAt, isNotNull);

      // User 3 shifts from position #2 to position #1!
      final shiftedHold = store.getHold(pendingHold2.id)!;
      expect(shiftedHold.holdStatus, equals(HoldStatus.pending));
      expect(shiftedHold.queuePosition, equals(1));
    });

    test('Case 6b: Cancellation of pending hold decrements holdCount and shifts following positions', () {
      final book = _createTestBook(
        id: 'b7',
        title: 'Continuous Delivery',
        availableCopies: 0,
        status: BookStatus.onLoan,
      );
      store.seedBook(book);

      final h1 = store.joinHoldQueue(userId: 'u1', bookId: 'b7');
      final h2 = store.joinHoldQueue(userId: 'u2', bookId: 'b7');
      final h3 = store.joinHoldQueue(userId: 'u3', bookId: 'b7');

      expect(h1.queuePosition, equals(1));
      expect(h2.queuePosition, equals(2));
      expect(h3.queuePosition, equals(3));
      expect(store.getBook('b7')!.holdCount, equals(3));

      // User 2 in the middle cancels their pending hold
      store.cancelHold(h2.id);

      expect(store.getHold(h2.id)!.holdStatus, equals(HoldStatus.cancelled));
      expect(store.getBook('b7')!.holdCount, equals(2));

      // User 1 remains at position #1
      expect(store.getHold(h1.id)!.queuePosition, equals(1));
      // User 3 shifts down to position #2
      expect(store.getHold(h3.id)!.queuePosition, equals(2));
    });
  });
}
