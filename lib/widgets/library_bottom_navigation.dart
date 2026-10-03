import 'package:flutter/material.dart';

class LibraryBottomNavigation extends StatelessWidget {
  const LibraryBottomNavigation({
    super.key,
    required this.selectedIndex,
    required this.onSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    const items = [
      (Icons.home_outlined, 'Home'),
      (Icons.menu_book_outlined, 'Catalog'),
      (Icons.calendar_month_outlined, 'Bookings'),
      (Icons.person_outline_rounded, 'Profile'),
    ];

    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final muted = theme.colorScheme.onSurfaceVariant;

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.only(top: 7, bottom: 5),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          border: Border(top: BorderSide(color: theme.dividerColor)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            for (var index = 0; index < items.length; index++)
              Expanded(
                child: InkWell(
                  onTap: () => onSelected(index),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        items[index].$1,
                        color: index == selectedIndex ? primary : muted,
                        size: 21,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        items[index].$2,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: index == selectedIndex ? primary : muted,
                          fontWeight: index == selectedIndex
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
