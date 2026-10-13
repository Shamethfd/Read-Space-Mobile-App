import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:read_space/main.dart';

class LibrarianBookHoldersScreen extends StatefulWidget {
  const LibrarianBookHoldersScreen({super.key});

  @override
  State<LibrarianBookHoldersScreen> createState() => _LibrarianBookHoldersScreenState();
}

class _LibrarianBookHoldersScreenState extends State<LibrarianBookHoldersScreen> {
  String _getDaysRemaining(String? readyAt) {
    if (readyAt == null) return '';
    try {
      final readyDate = DateTime.parse(readyAt);
      final now = DateTime.now();
      final difference = readyDate.difference(now);
      final days = difference.inDays;
      
      if (days <= 0) return '';
      if (days == 1) return '1 day left';
      return '$days days left';
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.pageBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.pageBackground,
        foregroundColor: AppTheme.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppTheme.textPrimary,
        ),
        iconTheme: IconThemeData(color: AppTheme.textPrimary),
        leading: BackButton(color: AppTheme.textPrimary),
        title: const Text('All Book Holders'),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('holds')
            .where('holdStatus', whereIn: ['pending', 'ready'])
            .limit(100)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final holds = snapshot.data?.docs ?? [];
          
          // Sort in memory by createdAt descending
          final sortedHolds = holds.toList()
            ..sort((a, b) {
              final aData = a.data() as Map<String, dynamic>;
              final bData = b.data() as Map<String, dynamic>;
              final aCreatedAt = aData['createdAt'] as String? ?? '';
              final bCreatedAt = bData['createdAt'] as String? ?? '';
              return bCreatedAt.compareTo(aCreatedAt);
            });

          if (sortedHolds.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.bookmark_border_outlined,
                    size: 64,
                    color: AppTheme.secondaryText,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Book Holders',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'There are no active book holds',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppTheme.secondaryText,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: sortedHolds.length,
            itemBuilder: (context, index) {
              final doc = sortedHolds[index];
              final data = doc.data() as Map<String, dynamic>;
              final bookId = data['bookId'] as String? ?? '';
              final userId = data['userId'] as String? ?? '';
              final status = data['holdStatus'] as String? ?? 'pending';
              final readyAt = data['readyAt'] as String?;
              
              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
                builder: (context, userSnapshot) {
                  final userData = userSnapshot.data?.data() as Map<String, dynamic>?;
                  final userName = userData?['fullName'] as String? ?? 'Unknown User';
                  final userEmail = userData?['email'] as String? ?? '';
                  
                  return FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance.collection('books').doc(bookId).get(),
                    builder: (context, bookSnapshot) {
                      final bookData = bookSnapshot.data?.data() as Map<String, dynamic>?;
                      final bookTitle = bookData?['title'] as String? ?? 'Unknown Book';
                      
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.border),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: status == 'ready'
                                    ? AppTheme.success.withValues(alpha: 0.1)
                                    : AppTheme.primaryBlue.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.menu_book,
                                color: status == 'ready'
                                    ? AppTheme.success
                                    : AppTheme.primaryBlue,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    bookTitle,
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    userName,
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      color: AppTheme.secondaryText,
                                    ),
                                  ),
                                  Text(
                                    userEmail,
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      color: AppTheme.secondaryText,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (status == 'ready' && readyAt != null)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppTheme.orange.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  _getDaysRemaining(readyAt),
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.orange,
                                  ),
                                ),
                              )
                            else
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  status == 'ready' ? 'Ready' : 'Pending',
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.primaryBlue,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
