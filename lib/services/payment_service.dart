import '../models/payment_transaction.dart';

class PaymentService {
  // TODO: Replace with actual API calls
  // This is a placeholder for backend integration

  // In-memory storage for demo purposes
  final List<PaymentTransaction> _transactions = [];

  Future<List<PaymentTransaction>> getPaymentsByMember(String memberId) async {
    // TODO: Replace with GET /payments?memberId=userId API call
    await Future.delayed(const Duration(milliseconds: 500));
    return _transactions.where((t) => t.memberId == memberId).toList();
  }

  Future<PaymentTransaction?> getPaymentById(String id) async {
    // TODO: Replace with GET /payments/:id API call
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      return _transactions.firstWhere((t) => t.id == id);
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
    // TODO: Replace with POST /payments API call
    await Future.delayed(const Duration(milliseconds: 800));

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

    _transactions.add(transaction);
    return transaction;
  }

  Future<PaymentTransaction> updatePaymentStatus({
    required String paymentId,
    required PaymentStatus status,
    String? verifiedBy,
  }) async {
    // TODO: Replace with PUT /payments/:id/status API call
    await Future.delayed(const Duration(milliseconds: 500));

    final index = _transactions.indexWhere((t) => t.id == paymentId);
    if (index != -1) {
      final updated = _transactions[index].copyWith(
        status: status,
        verifiedBy: verifiedBy,
        verifiedAt: status == PaymentStatus.approved ? DateTime.now() : null,
      );
      _transactions[index] = updated;
      return updated;
    }

    throw Exception('Payment not found');
  }

  Future<double> getOutstandingFines(String memberId) async {
    // TODO: Replace with GET /members/:id/fines API call
    await Future.delayed(const Duration(milliseconds: 300));
    // Return pending + rejected payments as outstanding
    final payments = await getPaymentsByMember(memberId);
    return payments
        .where((p) => p.status == PaymentStatus.pending || p.status == PaymentStatus.rejected)
        .fold<double>(0.0, (sum, p) => sum + p.amount);
  }
}
