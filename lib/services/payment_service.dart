import '../models/payment_transaction.dart';
import 'firestore_service.dart';

class PaymentService {
  final FirestoreService _firestoreService = FirestoreService();

  Future<List<PaymentTransaction>> getPaymentsByMember(String memberId) async {
    return await _firestoreService.getUserPaymentsStream(memberId).first;
  }

  Future<PaymentTransaction?> getPaymentById(String id) async {
    final payments = await _firestoreService.getAllPaymentsStream().first;
    try {
      return payments.firstWhere((t) => t.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<PaymentTransaction> createPayment({
    required String memberId,
    required String memberName,
    required double amount,
    required String paymentMethod,
    required String reason,
    String? bookTitle,
    required String receiptUrl,
  }) async {
    final transaction = PaymentTransaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      memberId: memberId,
      memberName: memberName,
      amount: amount,
      paymentMethod: paymentMethod,
      reason: reason,
      bookTitle: bookTitle,
      transactionId: 'TXN-${DateTime.now().year}-${DateTime.now().millisecondsSinceEpoch}',
      paymentDate: DateTime.now(),
      status: PaymentStatus.pending,
      receiptUrl: receiptUrl,
      createdAt: DateTime.now(),
    );

    await _firestoreService.createPayment(transaction);
    return transaction;
  }

  Future<PaymentTransaction> updatePaymentStatus({
    required String paymentId,
    required PaymentStatus status,
    String? verifiedBy,
  }) async {
    final payments = await _firestoreService.getAllPaymentsStream().first;
    final payment = payments.firstWhere((t) => t.id == paymentId);
    
    final updated = payment.copyWith(
      status: status,
      verifiedBy: verifiedBy,
      verifiedAt: status == PaymentStatus.approved ? DateTime.now() : null,
    );
    
    await _firestoreService.updatePayment(paymentId, updated.toJson());
    return updated;
  }

  Future<double> getOutstandingFines(String memberId) async {
    final payments = await getPaymentsByMember(memberId);
    return payments
        .where((p) => p.status == PaymentStatus.pending || p.status == PaymentStatus.rejected)
        .fold<double>(0.0, (sum, p) => sum + p.amount);
  }
}
