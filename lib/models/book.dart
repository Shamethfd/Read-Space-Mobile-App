import 'package:flutter/material.dart';

enum BookStatus {
  available,
  onLoan,
  reserved,
  maintenance,
}

enum LibrarySection {
  general,
  quiet,
  reference,
}

class Book {
  final String id;
  final String title;
  final String author;
  final String isbn;
  final String genre;
  final String description;
  final int pages;
  final String language;
  final BookStatus status;
  final LibrarySection section;
  final String shelfLocation;
  final int totalCopies;
  final int availableCopies;
  final int holdCount;
  final Color coverColor;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.isbn,
    required this.genre,
    required this.description,
    required this.pages,
    required this.language,
    required this.status,
    required this.section,
    required this.shelfLocation,
    required this.totalCopies,
    required this.availableCopies,
    required this.holdCount,
    required this.coverColor,
  });

  Book copyWith({
    String? id,
    String? title,
    String? author,
    String? isbn,
    String? genre,
    String? description,
    int? pages,
    String? language,
    BookStatus? status,
    LibrarySection? section,
    String? shelfLocation,
    int? totalCopies,
    int? availableCopies,
    int? holdCount,
    Color? coverColor,
  }) {
    return Book(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      isbn: isbn ?? this.isbn,
      genre: genre ?? this.genre,
      description: description ?? this.description,
      pages: pages ?? this.pages,
      language: language ?? this.language,
      status: status ?? this.status,
      section: section ?? this.section,
      shelfLocation: shelfLocation ?? this.shelfLocation,
      totalCopies: totalCopies ?? this.totalCopies,
      availableCopies: availableCopies ?? this.availableCopies,
      holdCount: holdCount ?? this.holdCount,
      coverColor: coverColor ?? this.coverColor,
    );
  }

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      author: json['author'] as String? ?? '',
      isbn: json['isbn'] as String? ?? '',
      genre: json['genre'] as String? ?? '',
      description: json['description'] as String? ?? '',
      pages: json['pages'] is int
          ? json['pages'] as int
          : (json['pages'] as num?)?.toInt() ?? 0,
      language: json['language'] as String? ?? 'English',
      status: BookStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => BookStatus.available,
      ),
      section: LibrarySection.values.firstWhere(
        (e) => e.name == json['section'],
        orElse: () => LibrarySection.general,
      ),
      shelfLocation: json['shelfLocation'] as String? ?? '',
      totalCopies: json['totalCopies'] is int
          ? json['totalCopies'] as int
          : (json['totalCopies'] as num?)?.toInt() ?? 0,
      availableCopies: json['availableCopies'] is int
          ? json['availableCopies'] as int
          : (json['availableCopies'] as num?)?.toInt() ?? 0,
      holdCount: json['holdCount'] is int
          ? json['holdCount'] as int
          : (json['holdCount'] as num?)?.toInt() ?? 0,
      coverColor: _parseColor(json['coverColor']),
    );
  }

  static Color _parseColor(dynamic value) {
    if (value is Color) return value;
    if (value is int) return Color(value);
    if (value is String) {
      final parsed = int.tryParse(value);
      if (parsed != null) return Color(parsed);
    }
    return const Color(0xFF1E3A8A);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'isbn': isbn,
      'genre': genre,
      'description': description,
      'pages': pages,
      'language': language,
      'status': status.name,
      'section': section.name,
      'shelfLocation': shelfLocation,
      'totalCopies': totalCopies,
      'availableCopies': availableCopies,
      'holdCount': holdCount,
      'coverColor': coverColor.toARGB32().toString(),
    };
  }
}
