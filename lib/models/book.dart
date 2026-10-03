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

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'] as String,
      title: json['title'] as String,
      author: json['author'] as String,
      isbn: json['isbn'] as String,
      genre: json['genre'] as String,
      description: json['description'] as String,
      pages: json['pages'] as int,
      language: json['language'] as String,
      status: BookStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => BookStatus.available,
      ),
      section: LibrarySection.values.firstWhere(
        (e) => e.name == json['section'],
        orElse: () => LibrarySection.general,
      ),
      shelfLocation: json['shelfLocation'] as String,
      totalCopies: json['totalCopies'] as int,
      availableCopies: json['availableCopies'] as int,
      holdCount: json['holdCount'] as int,
      coverColor: Color(int.parse(json['coverColor'] as String)),
    );
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
      'coverColor': coverColor.value.toString(),
    };
  }
}
