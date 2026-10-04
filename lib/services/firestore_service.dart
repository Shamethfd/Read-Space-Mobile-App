import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/book.dart';
import '../models/fine_appeal.dart';
import '../models/hold.dart';
import '../models/notice.dart';
import '../models/payment_transaction.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Books collection
  CollectionReference get _booksCollection => _firestore.collection('books');

  // Holds collection
  CollectionReference get _holdsCollection => _firestore.collection('holds');

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
      return snapshot.docs.map((doc) {
        return Book.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();
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
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Hold.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  // Get user's holds (one-time)
  Future<List<Hold>> getUserHolds(String userId) async {
    try {
      final snapshot = await _holdsCollection
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs.map((doc) {
        return Hold.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();
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

  // Cancel hold
  Future<void> cancelHold(String holdId) async {
    try {
      await _holdsCollection.doc(holdId).update({
        'holdStatus': 'cancelled',
      });
    } catch (e) {
      throw Exception('Failed to cancel hold: $e');
    }
  }

  // Check if user already has a hold on a book
  Future<bool> hasActiveHold(String userId, String bookId) async {
    try {
      final snapshot = await _holdsCollection
          .where('userId', isEqualTo: userId)
          .where('bookId', isEqualTo: bookId)
          .where('holdStatus', whereIn: ['pending', 'ready'])
          .get();
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      throw Exception('Failed to check hold: $e');
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
