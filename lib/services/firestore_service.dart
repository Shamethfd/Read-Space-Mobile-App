import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/book.dart';
import '../models/booking.dart';
import '../models/fine_appeal.dart';
import '../models/hold.dart';
import '../models/notice.dart';
import '../models/payment_transaction.dart';
import '../models/seat.dart';

class FirestoreService {
  final FirebaseFirestore _firestore;

  FirestoreService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // Books collection
  CollectionReference get _booksCollection => _firestore.collection('books');

  // Holds collection
  CollectionReference get _holdsCollection => _firestore.collection('holds');

  // Bookings collection
  CollectionReference get _bookingsCollection => _firestore.collection('bookings');

  // Seats collection
  CollectionReference get _seatsCollection => _firestore.collection('seats');

  // Notices collection
  CollectionReference get _noticesCollection => _firestore.collection('notices');

  // Payments collection
  CollectionReference get _paymentsCollection => _firestore.collection('payments');

  // Users collection
  CollectionReference get _usersCollection => _firestore.collection('users');

  // Fine Appeals collection
  CollectionReference get _fineAppealsCollection => _firestore.collection('fineAppeals');

  // ==================== BOOKS ====================

  // Get all books stream
  Stream<List<Book>> getBooksStream() {
    return _booksCollection.snapshots().map((snapshot) {
      try {
        final books = snapshot.docs.map((doc) {
          try {
            return Book.fromJson(doc.data() as Map<String, dynamic>);
          } catch (e) {
            print('❌ Error parsing book ${doc.id}: $e');
            print('Data: ${doc.data()}');
            return null;
          }
        }).whereType<Book>().toList();
        print('✅ Successfully parsed ${books.length} books');
        return books;
      } catch (e) {
        print('❌ Error in getBooksStream: $e');
        return [];
      }
    });
  }

  // Get all books (one-time)
  Future<List<Book>> getAllBooks() async {
    try {
      final snapshot = await _booksCollection.get();
      return snapshot.docs.map((doc) {
        return Book.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      throw Exception('Failed to get books: $e');
    }
  }

  // Get book by ID
  Future<Book?> getBookById(String bookId) async {
    try {
      final doc = await _booksCollection.doc(bookId).get();
      if (doc.exists) {
        return Book.fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get book: $e');
    }
  }

  // Add book
  Future<void> addBook(Book book) async {
    try {
      await _booksCollection.doc(book.id).set(book.toJson());
    } catch (e) {
      throw Exception('Failed to add book: $e');
    }
  }

  // Update book
  Future<void> updateBook(String bookId, Map<String, dynamic> data) async {
    try {
      await _booksCollection.doc(bookId).update(data);
    } catch (e) {
      throw Exception('Failed to update book: $e');
    }
  }

  // Delete book
  Future<void> deleteBook(String bookId) async {
    try {
      await _booksCollection.doc(bookId).delete();
    } catch (e) {
      throw Exception('Failed to delete book: $e');
    }
  }

  // ==================== HOLDS ====================

  // Get user's holds stream
  Stream<List<Hold>> getUserHoldsStream(String userId) {
    return _holdsCollection
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final holds = <Hold>[];
      for (final doc in snapshot.docs) {
        try {
          final data = doc.data() as Map<String, dynamic>;
          if (!data.containsKey('id') || data['id'] == null || (data['id'] as String).isEmpty) {
            data['id'] = doc.id;
          }
          holds.add(Hold.fromJson(data));
        } catch (e) {
          print('❌ Error parsing hold ${doc.id}: $e');
        }
      }
      holds.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return holds;
    });
  }

  // Get user's holds (one-time)
  Future<List<Hold>> getUserHolds(String userId) async {
    try {
      final snapshot = await _holdsCollection
          .where('userId', isEqualTo: userId)
          .get();
      final holds = <Hold>[];
      for (final doc in snapshot.docs) {
        try {
          final data = doc.data() as Map<String, dynamic>;
          if (!data.containsKey('id') || data['id'] == null || (data['id'] as String).isEmpty) {
            data['id'] = doc.id;
          }
          holds.add(Hold.fromJson(data));
        } catch (e) {
          print('❌ Error parsing hold ${doc.id}: $e');
        }
      }
      holds.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return holds;
    } catch (e) {
      throw Exception('Failed to get holds: $e');
    }
  }

  // Create hold
  Future<void> createHold(Hold hold) async {
    try {
      await _holdsCollection.doc(hold.id).set(hold.toJson());
    } catch (e) {
      throw Exception('Failed to create hold: $e');
    }
  }

  // Update hold
  Future<void> updateHold(String holdId, Map<String, dynamic> data) async {
    try {
      await _holdsCollection.doc(holdId).update(data);
    } catch (e) {
      throw Exception('Failed to update hold: $e');
    }
  }

  // Check if user already has an active hold on a book
  Future<bool> hasActiveHold(String userId, String bookId) async {
    try {
      final snapshot = await _holdsCollection
          .where('userId', isEqualTo: userId)
          .where('bookId', isEqualTo: bookId)
          .where('holdStatus', whereIn: ['pending', 'ready'])
          .get();
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // Stream active hold for a user and book
  Stream<Hold?> getActiveUserHoldForBookStream(String userId, String bookId) {
    return _holdsCollection
        .where('userId', isEqualTo: userId)
        .where('bookId', isEqualTo: bookId)
        .snapshots()
        .map((snapshot) {
      for (final doc in snapshot.docs) {
        try {
          final data = doc.data() as Map<String, dynamic>;
          if (!data.containsKey('id') || data['id'] == null || (data['id'] as String).isEmpty) {
            data['id'] = doc.id;
          }
          final hold = Hold.fromJson(data);
          if (hold.holdStatus == HoldStatus.pending || hold.holdStatus == HoldStatus.ready) {
            return hold;
          }
        } catch (_) {}
      }
      return null;
    });
  }

  // Reserve an available book using safe Firestore transaction
  Future<Hold> reserveAvailableBook({
    required String userId,
    required String bookId,
  }) async {
    final activeSnapshot = await _holdsCollection
        .where('userId', isEqualTo: userId)
        .where('bookId', isEqualTo: bookId)
        .where('holdStatus', whereIn: ['pending', 'ready'])
        .get();

    if (activeSnapshot.docs.isNotEmpty) {
      throw DuplicateHoldException('You already have an active hold on this book.');
    }

    final bookRef = _booksCollection.doc(bookId);
    final holdRef = _holdsCollection.doc();
    final now = DateTime.now();

    return await _firestore.runTransaction((transaction) async {
      final bookSnap = await transaction.get(bookRef);
      if (!bookSnap.exists) {
        throw Exception('Book not found');
      }

      final bookData = bookSnap.data() as Map<String, dynamic>;
      final availableCopies = (bookData['availableCopies'] as num?)?.toInt() ?? 0;

      if (availableCopies <= 0) {
        throw Exception('No copies available for direct reservation. Please join the queue instead.');
      }

      final newAvailableCopies = availableCopies - 1;
      final newStatus = newAvailableCopies == 0
          ? BookStatus.reserved.name
          : (bookData['status'] as String? ?? BookStatus.available.name);

      final hold = Hold(
        id: holdRef.id,
        bookId: bookId,
        userId: userId,
        createdAt: now,
        holdStatus: HoldStatus.ready,
        queuePosition: 0,
        readyAt: now,
        expiresAt: now.add(const Duration(hours: 48)),
      );

      transaction.update(bookRef, {
        'availableCopies': newAvailableCopies,
        'status': newStatus,
      });

      transaction.set(holdRef, hold.toJson());

      return hold;
    });
  }

  // Join waitlist queue for an unavailable/zero-stock book using transaction
  Future<Hold> joinHoldQueue({
    required String userId,
    required String bookId,
  }) async {
    final activeSnapshot = await _holdsCollection
        .where('userId', isEqualTo: userId)
        .where('bookId', isEqualTo: bookId)
        .where('holdStatus', whereIn: ['pending', 'ready'])
        .get();

    if (activeSnapshot.docs.isNotEmpty) {
      throw DuplicateHoldException('You already have an active hold on this book.');
    }

    final bookRef = _booksCollection.doc(bookId);
    final holdRef = _holdsCollection.doc();
    final now = DateTime.now();

    return await _firestore.runTransaction((transaction) async {
      final bookSnap = await transaction.get(bookRef);
      if (!bookSnap.exists) {
        throw Exception('Book not found');
      }

      final bookData = bookSnap.data() as Map<String, dynamic>;
      final currentHoldCount = (bookData['holdCount'] as num?)?.toInt() ?? 0;
      final newHoldCount = currentHoldCount + 1;

      final hold = Hold(
        id: holdRef.id,
        bookId: bookId,
        userId: userId,
        createdAt: now,
        holdStatus: HoldStatus.pending,
        queuePosition: newHoldCount,
      );

      transaction.update(bookRef, {
        'holdCount': newHoldCount,
      });

      transaction.set(holdRef, hold.toJson());

      return hold;
    });
  }

  // Cancel hold using safe Firestore transaction and restore stock / advance queue
  Future<void> cancelHold(String holdId) async {
    final holdRef = _holdsCollection.doc(holdId);
    final holdDoc = await holdRef.get();
    if (!holdDoc.exists) return;

    final holdData = holdDoc.data() as Map<String, dynamic>;
    final statusStr = holdData['holdStatus'] as String?;
    if (statusStr != 'pending' && statusStr != 'ready') {
      return; // Already cancelled or expired
    }

    final bookId = holdData['bookId'] as String;
    final bookRef = _booksCollection.doc(bookId);
    final isReady = statusStr == 'ready';

    // Retrieve other pending holds for this book
    final pendingQuery = await _holdsCollection
        .where('bookId', isEqualTo: bookId)
        .where('holdStatus', isEqualTo: 'pending')
        .get();

    final pendingDocs = pendingQuery.docs
        .where((d) => d.id != holdId)
        .toList();

    // Sort by queuePosition ascending, then createdAt ascending
    pendingDocs.sort((a, b) {
      final dataA = a.data() as Map<String, dynamic>;
      final dataB = b.data() as Map<String, dynamic>;
      final posA = (dataA['queuePosition'] as num?)?.toInt() ?? 0;
      final posB = (dataB['queuePosition'] as num?)?.toInt() ?? 0;
      if (posA != posB) return posA.compareTo(posB);
      final dateA = dataA['createdAt']?.toString() ?? '';
      final dateB = dataB['createdAt']?.toString() ?? '';
      return dateA.compareTo(dateB);
    });

    await _firestore.runTransaction((transaction) async {
      final bookSnap = await transaction.get(bookRef);
      if (!bookSnap.exists) {
        transaction.update(holdRef, {'holdStatus': 'cancelled'});
        return;
      }

      final bookData = bookSnap.data() as Map<String, dynamic>;
      final availableCopies = (bookData['availableCopies'] as num?)?.toInt() ?? 0;
      final holdCount = (bookData['holdCount'] as num?)?.toInt() ?? 0;

      // 1. Mark target hold as cancelled
      transaction.update(holdRef, {'holdStatus': 'cancelled'});

      final now = DateTime.now();

      if (isReady) {
        // A reserved physical copy is released
        if (pendingDocs.isNotEmpty) {
          // Promote the first pending waitlist user to ready
          final nextDoc = pendingDocs.first;
          transaction.update(nextDoc.reference, {
            'holdStatus': 'ready',
            'queuePosition': 0,
            'readyAt': now.toIso8601String(),
            'expiresAt': now.add(const Duration(hours: 48)).toIso8601String(),
          });

          // Shift remaining pending holds forward in queue
          for (int i = 1; i < pendingDocs.length; i++) {
            transaction.update(pendingDocs[i].reference, {
              'queuePosition': i,
            });
          }

          // Decrement book holdCount (as one person transitioned from waitlist to ready)
          final newHoldCount = (holdCount > 0) ? holdCount - 1 : 0;
          transaction.update(bookRef, {'holdCount': newHoldCount});
        } else {
          // No waitlist -> restore available stock!
          final newAvailable = availableCopies + 1;
          transaction.update(bookRef, {
            'availableCopies': newAvailable,
            'status': BookStatus.available.name,
          });
        }
      } else {
        // A pending hold was cancelled: re-sequence remaining pending users in queue
        int newPos = 1;
        for (final doc in pendingDocs) {
          transaction.update(doc.reference, {
            'queuePosition': newPos,
          });
          newPos++;
        }

        final newHoldCount = (holdCount > 0) ? holdCount - 1 : 0;
        transaction.update(bookRef, {'holdCount': newHoldCount});
      }
    });
  }

  // ==================== BOOKINGS ====================

  // Get all bookings stream (no user filter - for admin)
  Stream<List<Booking>> getAllBookingsStream() {
    return _bookingsCollection
        .snapshots()
        .map((snapshot) {
      final bookings = snapshot.docs.map((doc) {
        return Booking.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();
      bookings.sort((a, b) => b.startTime.compareTo(a.startTime));
      return bookings;
    });
  }

  // Get user's bookings stream
  Stream<List<Booking>> getUserBookingsStream(String userId) {
    return _bookingsCollection
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final bookings = snapshot.docs.map((doc) {
        return Booking.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();
      bookings.sort((a, b) => b.startTime.compareTo(a.startTime));
      return bookings;
    });
  }

  // Get user's bookings (one-time)
  Future<List<Booking>> getUserBookings(String userId) async {
    try {
      final snapshot = await _bookingsCollection
          .where('userId', isEqualTo: userId)
          .get();
      final bookings = snapshot.docs.map((doc) {
        return Booking.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();
      bookings.sort((a, b) => b.startTime.compareTo(a.startTime));
      return bookings;
    } catch (e) {
      throw Exception('Failed to get bookings: $e');
    }
  }

  // Get booking by ID
  Future<Booking?> getBookingById(String bookingId) async {
    try {
      final doc = await _bookingsCollection.doc(bookingId).get();
      if (doc.exists) {
        return Booking.fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get booking: $e');
    }
  }

  // Create booking
  Future<void> createBooking(Booking booking) async {
    try {
      await _bookingsCollection.doc(booking.id).set(booking.toJson());
    } catch (e) {
      throw Exception('Failed to create booking: $e');
    }
  }

  // Update booking
  Future<void> updateBooking(String bookingId, Map<String, dynamic> data) async {
    try {
      await _bookingsCollection.doc(bookingId).update(data);
    } catch (e) {
      throw Exception('Failed to update booking: $e');
    }
  }

  // Cancel booking
  Future<void> cancelBooking(String bookingId) async {
    try {
      await _bookingsCollection.doc(bookingId).update({
        'status': 'cancelled',
        'cancelledAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to cancel booking: $e');
    }
  }

  // Extend booking time
  Future<void> extendBooking(String bookingId, DateTime newEndTime) async {
    try {
      await _bookingsCollection.doc(bookingId).update({
        'endTime': newEndTime.toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to extend booking: $e');
    }
  }

  // ==================== SEATS ====================

  // Get all seats stream
  Stream<List<Seat>> getSeatsStream() {
    return _seatsCollection
        .snapshots()
        .map((snapshot) {
      final seats = snapshot.docs.map((doc) {
        return Seat.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();
      seats.sort((a, b) => a.seatNumber.compareTo(b.seatNumber));
      return seats;
    });
  }

  // Get all seats (one-time)
  Future<List<Seat>> getSeats() async {
    try {
      final snapshot = await _seatsCollection.get();
      final seats = snapshot.docs.map((doc) {
        return Seat.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();
      seats.sort((a, b) => a.seatNumber.compareTo(b.seatNumber));
      return seats;
    } catch (e) {
      throw Exception('Failed to get seats: $e');
    }
  }

  // Get seat by ID
  Future<Seat?> getSeatById(String seatId) async {
    try {
      final doc = await _seatsCollection.doc(seatId).get();
      if (doc.exists) {
        return Seat.fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get seat: $e');
    }
  }

  // Create seat
  Future<void> createSeat(Seat seat) async {
    try {
      await _seatsCollection.doc(seat.id).set(seat.toJson());
    } catch (e) {
      throw Exception('Failed to create seat: $e');
    }
  }

  // Update seat
  Future<void> updateSeat(String seatId, Map<String, dynamic> data) async {
    try {
      await _seatsCollection.doc(seatId).update(data);
    } catch (e) {
      throw Exception('Failed to update seat: $e');
    }
  }

  // Delete seat
  Future<void> deleteSeat(String seatId) async {
    try {
      await _seatsCollection.doc(seatId).delete();
    } catch (e) {
      throw Exception('Failed to delete seat: $e');
    }
  }

  // Update seat status
  Future<void> updateSeatStatus(String seatId, SeatStatus status) async {
    try {
      await _seatsCollection.doc(seatId).update({
        'status': status.value,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to update seat status: $e');
    }
  }

  // Initialize default seats (for first-time setup)
  Future<void> initializeDefaultSeats() async {
    try {
      final existingSeats = await getSeats();
      if (existingSeats.isNotEmpty) {
        return; // Seats already exist
      }

      final defaultSeats = [
        // Row A
        Seat(
          id: 'A-01',
          seatNumber: 'A-01',
          row: 'A',
          position: 1,
          status: SeatStatus.available,
          hasPowerOutlet: true,
          isNearWindow: false,
          createdAt: DateTime.now(),
        ),
        Seat(
          id: 'A-02',
          seatNumber: 'A-02',
          row: 'A',
          position: 2,
          status: SeatStatus.available,
          hasPowerOutlet: true,
          isNearWindow: false,
          createdAt: DateTime.now(),
        ),
        Seat(
          id: 'A-03',
          seatNumber: 'A-03',
          row: 'A',
          position: 3,
          status: SeatStatus.available,
          hasPowerOutlet: false,
          isNearWindow: false,
          createdAt: DateTime.now(),
        ),
        Seat(
          id: 'A-04',
          seatNumber: 'A-04',
          row: 'A',
          position: 4,
          status: SeatStatus.available,
          hasPowerOutlet: true,
          isNearWindow: true,
          createdAt: DateTime.now(),
        ),
        // Row B
        Seat(
          id: 'B-05',
          seatNumber: 'B-05',
          row: 'B',
          position: 5,
          status: SeatStatus.available,
          hasPowerOutlet: true,
          isNearWindow: false,
          createdAt: DateTime.now(),
        ),
        Seat(
          id: 'B-06',
          seatNumber: 'B-06',
          row: 'B',
          position: 6,
          status: SeatStatus.available,
          hasPowerOutlet: true,
          isNearWindow: false,
          createdAt: DateTime.now(),
        ),
        Seat(
          id: 'B-07',
          seatNumber: 'B-07',
          row: 'B',
          position: 7,
          status: SeatStatus.available,
          hasPowerOutlet: false,
          isNearWindow: false,
          createdAt: DateTime.now(),
        ),
        Seat(
          id: 'B-08',
          seatNumber: 'B-08',
          row: 'B',
          position: 8,
          status: SeatStatus.available,
          hasPowerOutlet: true,
          isNearWindow: true,
          createdAt: DateTime.now(),
        ),
        // Row C
        Seat(
          id: 'C-09',
          seatNumber: 'C-09',
          row: 'C',
          position: 9,
          status: SeatStatus.available,
          hasPowerOutlet: true,
          isNearWindow: false,
          createdAt: DateTime.now(),
        ),
        Seat(
          id: 'C-10',
          seatNumber: 'C-10',
          row: 'C',
          position: 10,
          status: SeatStatus.available,
          hasPowerOutlet: true,
          isNearWindow: false,
          createdAt: DateTime.now(),
        ),
        Seat(
          id: 'C-11',
          seatNumber: 'C-11',
          row: 'C',
          position: 11,
          status: SeatStatus.available,
          hasPowerOutlet: false,
          isNearWindow: false,
          createdAt: DateTime.now(),
        ),
        Seat(
          id: 'C-12',
          seatNumber: 'C-12',
          row: 'C',
          position: 12,
          status: SeatStatus.available,
          hasPowerOutlet: true,
          isNearWindow: true,
          createdAt: DateTime.now(),
        ),
      ];

      for (final seat in defaultSeats) {
        await createSeat(seat);
      }
    } catch (e) {
      throw Exception('Failed to initialize default seats: $e');
    }
  }

  // ==================== NOTICES ====================

  // Get active notices stream
  Stream<List<Notice>> getActiveNoticesStream() {
    return _noticesCollection
        .where('status', isEqualTo: 'published')
        .orderBy('publishedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Notice.fromJson(doc.data() as Map<String, dynamic>);
      }).where((notice) => !notice.isExpired).toList();
    });
  }

  // Get all notices (for admin)
  Stream<List<Notice>> getAllNoticesStream() {
    return _noticesCollection
        .orderBy('publishedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Notice.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  // Add notice
  Future<void> addNotice(Notice notice) async {
    try {
      await _noticesCollection.doc(notice.id).set(notice.toJson());
    } catch (e) {
      throw Exception('Failed to add notice: $e');
    }
  }

  // Update notice
  Future<void> updateNotice(String noticeId, Map<String, dynamic> data) async {
    try {
      await _noticesCollection.doc(noticeId).update(data);
    } catch (e) {
      throw Exception('Failed to update notice: $e');
    }
  }

  // Delete notice
  Future<void> deleteNotice(String noticeId) async {
    try {
      await _noticesCollection.doc(noticeId).delete();
    } catch (e) {
      throw Exception('Failed to delete notice: $e');
    }
  }

  // ==================== PAYMENTS ====================

  // Get user's payments stream
  Stream<List<PaymentTransaction>> getUserPaymentsStream(String memberId) {
    return _paymentsCollection
        .where('memberId', isEqualTo: memberId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return PaymentTransaction.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  // Get all payments (for admin)
  Stream<List<PaymentTransaction>> getAllPaymentsStream() {
    return _paymentsCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return PaymentTransaction.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  // Create payment
  Future<void> createPayment(PaymentTransaction payment) async {
    try {
      await _paymentsCollection.doc(payment.id).set(payment.toJson());
    } catch (e) {
      throw Exception('Failed to create payment: $e');
    }
  }

  // Update payment
  Future<void> updatePayment(String paymentId, Map<String, dynamic> data) async {
    try {
      await _paymentsCollection.doc(paymentId).update(data);
    } catch (e) {
      throw Exception('Failed to update payment: $e');
    }
  }

  // ==================== USERS ====================

  // Get user by ID
  Future<Map<String, dynamic>?> getUserById(String uid) async {
    try {
      final doc = await _usersCollection.doc(uid).get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user: $e');
    }
  }

  // Update user
  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    try {
      await _usersCollection.doc(uid).update(data);
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

  // ==================== FINE APPEALS ====================

  // Get user's appeals stream
  Stream<List<FineAppeal>> getUserAppealsStream(String userId) {
    return _fineAppealsCollection
        .where('userId', isEqualTo: userId)
        .orderBy('submittedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return FineAppeal.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  // Get user's appeals (one-time)
  Future<List<FineAppeal>> getUserAppeals(String userId) async {
    try {
      final snapshot = await _fineAppealsCollection
          .where('userId', isEqualTo: userId)
          .orderBy('submittedAt', descending: true)
          .get();
      return snapshot.docs.map((doc) {
        return FineAppeal.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      throw Exception('Failed to get appeals: $e');
    }
  }

  // Get all appeals (for admin)
  Stream<List<FineAppeal>> getAllAppealsStream() {
    return _fineAppealsCollection
        .orderBy('submittedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return FineAppeal.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  // Get appeals by status (for admin filtering)
  Stream<List<FineAppeal>> getAppealsByStatusStream(String status) {
    return _fineAppealsCollection
        .where('status', isEqualTo: status)
        .orderBy('submittedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return FineAppeal.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  // Get appeal by ID
  Future<FineAppeal?> getAppealById(String appealId) async {
    try {
      final doc = await _fineAppealsCollection.doc(appealId).get();
      if (doc.exists) {
        return FineAppeal.fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get appeal: $e');
    }
  }

  // Create appeal
  Future<void> createAppeal(FineAppeal appeal) async {
    try {
      await _fineAppealsCollection.doc(appeal.id).set(appeal.toJson());
    } catch (e) {
      throw Exception('Failed to create appeal: $e');
    }
  }

  // Update appeal
  Future<void> updateAppeal(String appealId, Map<String, dynamic> data) async {
    try {
      await _fineAppealsCollection.doc(appealId).update(data);
    } catch (e) {
      throw Exception('Failed to update appeal: $e');
    }
  }

  // Cancel appeal
  Future<void> cancelAppeal(String appealId) async {
    try {
      await _fineAppealsCollection.doc(appealId).update({
        'status': 'cancelled',
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to cancel appeal: $e');
    }
  }
}
