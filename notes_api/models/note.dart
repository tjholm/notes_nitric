import 'package:equatable/equatable.dart';

class Note extends Equatable {
  final int? id;
  final String title;
  final String content;
  final DateTime? createdDate;

  Note({
    this.id,
    required this.title,
    required this.content,
    this.createdDate,
  });

  // Create a Note from a map (e.g., from a database query)
  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'],
      title: map['title'],
      content: map['content'],
      createdDate: map['created_date'],
    );
  }

  // Convert a Note to a map (e.g., for database insertion)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'created_date': createdDate?.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [id, title, content, createdDate];

  @override
  bool? get stringify => true;
}

class CreateNoteBody extends Equatable {
  final String title;
  final String content;

  CreateNoteBody({
    required this.title,
    required this.content,
  });

  factory CreateNoteBody.fromMap(Map<String, dynamic> map) {
    return CreateNoteBody(
      title: map['title'],
      content: map['content'],
    );
  }

  // Convert a Note to a map (e.g., for database insertion)
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
    };
  }

  @override
  List<Object?> get props => [
        title,
        content,
      ];

  @override
  bool? get stringify => true;
}

class UpdateNoteBody extends Equatable {
  final String title;
  final String content;

  UpdateNoteBody({
    required this.title,
    required this.content,
  });

  factory UpdateNoteBody.fromMap(Map<String, dynamic> map) {
    return UpdateNoteBody(
      title: map['title'],
      content: map['content'],
    );
  }

  // Convert a Note to a map (e.g., for database insertion)
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'created_date': DateTime.now(),
    };
  }

  @override
  List<Object?> get props => [
        title,
        content,
      ];

  @override
  bool? get stringify => true;
}
