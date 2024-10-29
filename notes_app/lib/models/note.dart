import 'package:equatable/equatable.dart';

class Note extends Equatable {
  const Note({
    this.id,
    required this.title,
    required this.content,
    this.createdDate,
  });

  final int? id;
  final String title;
  final String content;
  final DateTime? createdDate;

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

class NotesResponse extends Equatable {
  const NotesResponse({
    required this.notes,
  });

  final List<Note> notes;

  factory NotesResponse.fromMap(Map<String, dynamic> map) {
    return NotesResponse(
      notes: List<Note>.from(
        map['notes']?.map((x) => Note.fromMap(x)),
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'notes': notes.map((x) => x.toMap()).toList(),
    };
  }

  @override
  List<Object?> get props => [notes];

  @override
  bool? get stringify => true;
}

class CreateNoteBody extends Equatable {
  const CreateNoteBody({
    required this.title,
    required this.content,
  });

  final String title;
  final String content;

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
      'created_date': DateTime.now().toIso8601String(),
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
