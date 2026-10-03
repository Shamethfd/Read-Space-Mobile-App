import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:read_space/main.dart';
import 'package:read_space/models/book.dart';

class CatalogueScreen extends StatefulWidget {
  const CatalogueScreen({super.key, this.query = '', this.onlyAvailable = false, this.genre = 'All', this.section});
  final String query;
  final bool onlyAvailable;
  final String genre;
  final String? section;

  @override
  State<CatalogueScreen> createState() => _CatalogueScreenState();
}

class _CatalogueScreenState extends State<CatalogueScreen> {
  late final TextEditingController _searchCtrl;
  late String _activeChip; // 'All' | 'Available Now' | 'Quiet Zone' | genre

  // M02 design chip labels (matches the hi-fi exactly)
  static const _chips = [
    'All',
    'Available Now',
    'Quiet Zone',
    'Computer Sci',
    'Science',
    'History',
    'Fiction',
    'Arts',
  ];

  static List<Book> get _sampleBooks => [
    Book(
      id: '1',
      title: 'Design Patterns',
      author: 'E. Gamma, R. Helm, R. Johnson',
      isbn: '9780201633610',
      genre: 'Technology',
      description: 'Elements of Reusable Object-Oriented Software',
      pages: 395,
      language: 'English',
      status: BookStatus.available,
      section: LibrarySection.general,
      shelfLocation: 'A-12',
      totalCopies: 3,
      availableCopies: 2,
      holdCount: 1,
      coverColor: const Color(0xFF123C69),
    ),
    Book(
      id: '2',
      title: 'Clean Code',
      author: 'Robert C. Martin',
      isbn: '9780132350884',
      genre: 'Technology',
      description: 'A Handbook of Agile Software Craftsmanship',
      pages: 464,
      language: 'English',
      status: BookStatus.onLoan,
      section: LibrarySection.quiet,
      shelfLocation: 'Q-05',
      totalCopies: 2,
      availableCopies: 0,
      holdCount: 3,
      coverColor: const Color(0xFFE8A43A),
    ),
    Book(
      id: '3',
      title: 'The Pragmatic Programmer',
      author: 'Andrew Hunt, David Thomas',
      isbn: '9780201616224',
      genre: 'Technology',
      description: 'Your Journey to Mastery',
      pages: 352,
      language: 'English',
      status: BookStatus.available,
      section: LibrarySection.general,
      shelfLocation: 'A-08',
      totalCopies: 4,
      availableCopies: 3,
      holdCount: 0,
      coverColor: const Color(0xFF1E88E5),
    ),
    Book(
      id: '4',
      title: 'Introduction to Algorithms',
      author: 'Thomas H. Cormen',
      isbn: '9780262033848',
      genre: 'Science',
      description: 'A comprehensive introduction to the modern study of computer algorithms',
      pages: 1312,
      language: 'English',
      status: BookStatus.available,
      section: LibrarySection.quiet,
      shelfLocation: 'Q-15',
      totalCopies: 2,
      availableCopies: 1,
      holdCount: 2,
      coverColor: const Color(0xFF43A047),
    ),
    Book(
      id: '5',
      title: 'Sapiens',
      author: 'Yuval Noah Harari',
      isbn: '9780062316097',
      genre: 'History',
      description: 'A Brief History of Humankind',
      pages: 443,
      language: 'English',
      status: BookStatus.available,
      section: LibrarySection.general,
      shelfLocation: 'H-03',
      totalCopies: 5,
      availableCopies: 4,
      holdCount: 1,
      coverColor: const Color(0xFF7B1FA2),
    ),
    Book(
      id: '6',
      title: '1984',
      author: 'George Orwell',
      isbn: '9780451524935',
      genre: 'Fiction',
      description: 'A dystopian social science fiction novel',
      pages: 328,
      language: 'English',
      status: BookStatus.onLoan,
      section: LibrarySection.general,
      shelfLocation: 'F-22',
      totalCopies: 3,
      availableCopies: 0,
      holdCount: 5,
      coverColor: const Color(0xFFD32F2F),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _searchCtrl = TextEditingController(text: widget.query);
    if (widget.onlyAvailable) {
      _activeChip = 'Available Now';
    } else if (widget.section == 'Quiet Zone') {
      _activeChip = 'Quiet Zone';
    } else if (widget.genre != 'All') {
      _activeChip = widget.genre == 'Technology' ? 'Computer Sci' : widget.genre;
    } else {
      _activeChip = 'All';
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Book> _filtered(List<Book> all) {
    var list = all;

    switch (_activeChip) {
      case 'Available Now':
        list = list.where((b) => b.status == BookStatus.available).toList();
      case 'Quiet Zone':
        list = list.where((b) => b.section == LibrarySection.quiet).toList();
      case 'Computer Sci':
        list = list.where((b) => b.genre == 'Technology').toList();
      case 'All':
        break;
      default:
        list = list.where((b) => b.genre == _activeChip).toList();
    }

    final q = _searchCtrl.text.trim().toLowerCase();
    if (q.isNotEmpty) {
      list = list
          .where((b) =>
              b.title.toLowerCase().contains(q) ||
              b.author.toLowerCase().contains(q) ||
              b.isbn.contains(q))
          .toList();
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    final books = _filtered(_sampleBooks);
    final canPop = Navigator.canPop(context);
    final showBackButton = canPop;

    return Scaffold(
      backgroundColor: AppTheme.pageBackground,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Flat header matching M02 ─────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
              child: Row(
                children: [
                  if (showBackButton) ...[
                    Semantics(
                      button: true,
                      label: 'Go back',
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_rounded,
                            color: AppTheme.textPrimary),
                        tooltip: 'Back',
                        onPressed: () {
                          if (Navigator.canPop(context)) {
                            Navigator.pop(context);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 4),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'READSPACE CATALOGUE',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primaryBlue,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Browse Catalogue',
                          style: GoogleFonts.inter(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Search field ─────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Semantics(
                      label: 'Search field: title, author or ISBN',
                      child: TextField(
                        controller: _searchCtrl,
                        autofocus: widget.query.isNotEmpty,
                        textInputAction: TextInputAction.search,
                        style: GoogleFonts.inter(fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Search by title, author or ISBN...',
                          fillColor: Colors.white,
                          filled: true,
                          prefixIcon: const Icon(Icons.search_rounded,
                              color: AppTheme.secondaryText, size: 20),
                          suffixIcon: _searchCtrl.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.close_rounded,
                                      size: 16, color: AppTheme.secondaryText),
                                  onPressed: () =>
                                      setState(() => _searchCtrl.clear()),
                                )
                              : null,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                                const BorderSide(color: AppTheme.border),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                                const BorderSide(color: AppTheme.border),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                                color: AppTheme.primaryBlue, width: 2),
                          ),
                          isDense: true,
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Filter icon — prototype addition: saved searches
                  Tooltip(
                    message: 'Prototype addition: saved searches',
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppTheme.border),
                      ),
                      child: Icon(Icons.tune_rounded,
                          size: 18, color: AppTheme.secondaryText),
                    ),
                  ),
                ],
              ),
            ),

            // ── Filter chips row — matches M02 exactly ───────────────────
            SizedBox(
              height: 36,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: _chips.length,
                separatorBuilder: (_, __) => const SizedBox(width: 6),
                itemBuilder: (context, i) {
                  final chip = _chips[i];
                  final selected = _activeChip == chip;
                  return Semantics(
                    selected: selected,
                    label: 'Filter: $chip',
                    child: GestureDetector(
                      onTap: () => setState(() => _activeChip = chip),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: selected ? AppTheme.primaryBlue : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: selected
                                ? AppTheme.primaryBlue
                                : AppTheme.border,
                          ),
                        ),
                        child: Text(
                          chip,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: selected
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: selected
                                ? Colors.white
                                : AppTheme.secondaryText,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 6),

            // ── Results count ────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
              child: Row(
                children: [
                  Text(
                    'Search Results',
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Showing ${books.length} book${books.length == 1 ? '' : 's'}',
                    style: GoogleFonts.inter(
                        fontSize: 11, color: AppTheme.secondaryText),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 2),

            // ── Book list ────────────────────────────────────────────────
            Expanded(
              child: Builder(
                builder: (context) {

                  if (books.isEmpty) {
                    return _EmptyState(
                      query: _searchCtrl.text,
                      chip: _activeChip,
                      onClear: () => setState(() {
                        _searchCtrl.clear();
                        _activeChip = 'All';
                      }),
                    );
                  }

                  return ListView.builder(
                    key: const PageStorageKey<String>('catalogue_book_list'),
                    padding: const EdgeInsets.fromLTRB(12, 6, 12, 24),
                    itemCount: books.length,
                    itemBuilder: (context, i) => _BookCard(
                      book: books[i],
                      onView: () => Navigator.pushNamed(
                        context,
                        AppRoutes.bookDetail,
                        arguments: books[i].id,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Book Card — matches M02 hi-fi design ─────────────────────────────────────
class _BookCard extends StatelessWidget {
  const _BookCard({required this.book, required this.onView});
  final Book book;
  final VoidCallback onView;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '${book.title} by ${book.author}. ${book.status.name}. Tap to view.',
      child: Card(
        margin: const EdgeInsets.fromLTRB(0, 2, 0, 8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cover image (color swatch)
              Container(
                width: 56,
                height: 76,
                decoration: BoxDecoration(
                  color: book.coverColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.menu_book_rounded,
                        color: Colors.white38, size: 24),
                    const SizedBox(height: 4),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        book.genre == 'Technology' ? 'READSPACE' : book.genre.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                            fontSize: 7,
                            color: Colors.white54,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Text content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'by ${book.author}',
                      style: GoogleFonts.inter(
                          fontSize: 12, color: AppTheme.secondaryText),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'ISBN ${book.isbn}',
                      style: GoogleFonts.inter(
                          fontSize: 10, color: AppTheme.secondaryText),
                    ),
                    const SizedBox(height: 6),
                    _StatusChip(status: book.status),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // "View" button — matches M02
              Align(
                alignment: Alignment.bottomRight,
                child: Semantics(
                  button: true,
                  label: 'View ${book.title}',
                  child: OutlinedButton(
                    onPressed: onView,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      minimumSize: const Size(58, 32),
                      textStyle:
                          GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600),
                      side: BorderSide(color: AppTheme.primaryBlue),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('View'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Empty State ───────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  const _EmptyState(
      {required this.query, required this.chip, required this.onClear});
  final String query;
  final String chip;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off_rounded,
              size: 56, color: AppTheme.secondaryText.withValues(alpha: 0.4)),
          const SizedBox(height: 16),
          Text(
            query.isEmpty
                ? 'No books in "$chip"'
                : 'No results for "$query"',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: onClear,
            icon: const Icon(Icons.clear_all_rounded, size: 16),
            label: const Text('Clear Filter'),
          ),
        ],
      ),
    );
  }
}

// ── Status Chip ───────────────────────────────────────────────────────────────
class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});
  final BookStatus status;

  @override
  Widget build(BuildContext context) {
    final label;
    final color;
    switch (status) {
      case BookStatus.available:
        label = 'Available';
        color = AppTheme.success;
        break;
      case BookStatus.onLoan:
        label = 'On Loan';
        color = AppTheme.orange;
        break;
      case BookStatus.reserved:
        label = 'Reserved';
        color = AppTheme.primaryBlue;
        break;
      case BookStatus.maintenance:
        label = 'Maintenance';
        color = AppTheme.red;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 9,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
