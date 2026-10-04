import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:read_space/main.dart' show AppTheme, AppRoutes;
import 'package:read_space/models/fine_appeal.dart';
import 'package:read_space/services/firestore_service.dart';

class AdminAppealsScreen extends StatefulWidget {
  const AdminAppealsScreen({super.key});

  @override
  State<AdminAppealsScreen> createState() => _AdminAppealsScreenState();
}

class _AdminAppealsScreenState extends State<AdminAppealsScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  String _selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
        ),
        title: Text(
          'Fine Appeals',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: _buildAppealsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: AppTheme.border),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip('All'),
            const SizedBox(width: 8),
            _buildFilterChip('Pending'),
            const SizedBox(width: 8),
            _buildFilterChip('Approved'),
            const SizedBox(width: 8),
            _buildFilterChip('Rejected'),
            const SizedBox(width: 8),
            _buildFilterChip('Resolved'),
            const SizedBox(width: 8),
            _buildFilterChip('Cancelled'),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    return FilterChip(
      label: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: isSelected ? Colors.white : AppTheme.textPrimary,
        ),
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = label;
        });
      },
      selectedColor: AppTheme.primaryBlue,
      backgroundColor: const Color(0xFFF3F4F6),
      checkmarkColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? AppTheme.primaryBlue : AppTheme.border,
        ),
      ),
    );
  }

  Widget _buildAppealsList() {
    Stream<List<FineAppeal>> stream;
    
    if (_selectedFilter == 'All') {
      stream = _firestoreService.getAllAppealsStream();
    } else {
      stream = _firestoreService.getAppealsByStatusStream(_selectedFilter.toLowerCase());
    }

    return StreamBuilder<List<FineAppeal>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error loading appeals: ${snapshot.error}',
              style: GoogleFonts.poppins(color: AppTheme.secondaryText),
            ),
          );
        }

        final appeals = snapshot.data ?? [];

        if (appeals.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: appeals.length,
          itemBuilder: (context, index) {
            return _buildAppealCard(appeals[index]);
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(60),
            ),
            child: Icon(
              Icons.inbox_outlined,
              size: 60,
              color: AppTheme.primaryBlue,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Appeals Found',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'There are no $_selectedFilter appeals at the moment.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppTheme.secondaryText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppealCard(FineAppeal appeal) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appeal.userName,
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      appeal.userEmail,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppTheme.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
              _buildStatusBadge(appeal.status),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.description,
                size: 14,
                color: AppTheme.secondaryText,
              ),
              const SizedBox(width: 4),
              Text(
                'Fine ID: #${appeal.fineId}',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: AppTheme.secondaryText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            appeal.reason,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: 14,
                color: AppTheme.secondaryText,
              ),
              const SizedBox(width: 4),
              Text(
                _formatDate(appeal.submittedAt),
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppTheme.secondaryText,
                ),
              ),
              const Spacer(),
              if (appeal.proofImageUrl != null || appeal.proofDocumentUrl != null)
                Icon(
                  Icons.attach_file,
                  size: 14,
                  color: AppTheme.primaryBlue,
                ),
            ],
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(
              context,
              AppRoutes.adminAppealDetails,
              arguments: appeal,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(40),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'View Details',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(AppealStatus status) {
    Color backgroundColor;
    Color textColor;
    String label;

    switch (status) {
      case AppealStatus.pending:
        backgroundColor = const Color(0xFFFFF3CD);
        textColor = const Color(0xFF856404);
        label = 'Pending';
        break;
      case AppealStatus.approved:
        backgroundColor = const Color(0xFFD1E7DD);
        textColor = const Color(0xFF0F5132);
        label = 'Approved';
        break;
      case AppealStatus.rejected:
        backgroundColor = const Color(0xFFF8D7DA);
        textColor = const Color(0xFF842029);
        label = 'Rejected';
        break;
      case AppealStatus.resolved:
        backgroundColor = const Color(0xFFD1E7DD);
        textColor = const Color(0xFF0F5132);
        label = 'Resolved';
        break;
      case AppealStatus.cancelled:
        backgroundColor = const Color(0xFFE2E3E5);
        textColor = const Color(0xFF41464B);
        label = 'Cancelled';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
