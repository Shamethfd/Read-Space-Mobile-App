import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:read_space/main.dart' show AppTheme, PrimaryButton, AppRoutes;
import 'package:read_space/models/payment_transaction.dart';
import 'package:read_space/services/payment_service.dart';
import 'package:read_space/widgets/bank_info_card.dart';
import 'package:read_space/widgets/payment_history_card.dart';

class PayLibraryFineScreen extends StatefulWidget {
  const PayLibraryFineScreen({super.key});

  @override
  State<PayLibraryFineScreen> createState() => _PayLibraryFineScreenState();
}

class _PayLibraryFineScreenState extends State<PayLibraryFineScreen> {
  final _paymentService = PaymentService();
  final ImagePicker _imagePicker = ImagePicker();

  // TODO: Get actual member data from auth service
  final String _memberId = 'IT23624344';
  final String _memberName = 'Fernando K S R';
  final String _bookTitle = 'Data Structures & Algorithms';

  double _outstandingAmount = 150.00;
  List<PaymentTransaction> _paymentHistory = [];
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _selectedReceiptPath;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final payments = await _paymentService.getPaymentsByMember(_memberId);
      final outstanding = await _paymentService.getOutstandingFines(_memberId);

      if (mounted) {
        setState(() {
          _paymentHistory = payments;
          _outstandingAmount = outstanding;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load payment data';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _pickReceipt() async {
    final pickedFile = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      setState(() {
        _selectedReceiptPath = pickedFile.path;
      });
    }
  }

  Future<void> _submitPayment() async {
    if (_selectedReceiptPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload payment proof'),
          backgroundColor: AppTheme.red,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // TODO: Upload receipt to backend and get URL
      final receiptUrl = 'https://example.com/receipts/${DateTime.now().millisecondsSinceEpoch}.jpg';

      await _paymentService.createPayment(
        memberId: _memberId,
        memberName: _memberName,
        amount: _outstandingAmount,
        paymentMethod: 'Bank Transfer (BOC)',
        reason: 'Overdue Return Fine',
        bookTitle: _bookTitle,
        receiptUrl: receiptUrl,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment receipt submitted successfully'),
            backgroundColor: AppTheme.success,
          ),
        );
        await _loadData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to submit payment'),
            backgroundColor: AppTheme.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.pageBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
        ),
        title: Text(
          'Pay Library Fine',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildOutstandingCard(),
                  const SizedBox(height: 24),
                  BankInfoCard(
                    bankName: 'BOC / People\'s Bank',
                    accountName: 'University Library Fund',
                    accountNumber: '1234-5678-9012',
                    referenceCode: '$_memberId-FINE',
                  ),
                  const SizedBox(height: 24),
                  _buildUploadSection(),
                  const SizedBox(height: 24),
                  PrimaryButton(
                    label: _isSubmitting ? 'Submitting...' : 'Submit Payment Receipt',
                    onPressed: _isSubmitting ? null : _submitPayment,
                  ),
                  const SizedBox(height: 32),
                  _buildPaymentHistory(),
                ],
              ),
            ),
    );
  }

  Widget _buildOutstandingCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Total Outstanding',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'OVERDUE',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.red,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'LKR ${_outstandingAmount.toStringAsFixed(2)}',
            style: GoogleFonts.poppins(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Overdue Book: $_bookTitle',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: AppTheme.secondaryText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Upload Payment Proof',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: _pickReceipt,
          child: Container(
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _selectedReceiptPath != null
                    ? AppTheme.primaryBlue
                    : AppTheme.border,
                style: BorderStyle.solid,
              ),
            ),
            child: _selectedReceiptPath != null
                ? Stack(
                    children: [
                      Center(
                        child: Icon(
                          Icons.check_circle,
                          color: AppTheme.success,
                          size: 48,
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: IconButton(
                          onPressed: () {
                            setState(() => _selectedReceiptPath = null);
                          },
                          icon: const Icon(Icons.close, size: 20),
                          color: AppTheme.secondaryText,
                        ),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.cloud_upload_outlined,
                        color: AppTheme.secondaryText,
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap to upload bank receipt or screenshot',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'JPG, PNG, PDF',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: AppTheme.secondaryText,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payment History',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        if (_paymentHistory.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.border),
            ),
            child: Center(
              child: Text(
                'No payment history',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: AppTheme.secondaryText,
                ),
              ),
            ),
          )
        else
          ..._paymentHistory.map((transaction) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: PaymentHistoryCard(
                  transaction: transaction,
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.transactionDetails,
                      arguments: transaction,
                    );
                  },
                ),
              )),
      ],
    );
  }
}
