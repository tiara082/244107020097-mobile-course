import '../entities/note.dart';

class SearchNotes {
  const SearchNotes();

  List<Note> call({
    required List<Note> notes,
    required String query,
  }) {
    final sanitizedQuery = query.trim().toLowerCase();
    if (sanitizedQuery.isEmpty) return notes;

    return notes.where((note) {
      final titleMatch = note.title.toLowerCase().contains(sanitizedQuery);
      final bodyMatch = note.body.toLowerCase().contains(sanitizedQuery);
      final categoryMatch = note.category.toLowerCase().contains(sanitizedQuery);
      return titleMatch || bodyMatch || categoryMatch;
    }).toList(growable: false);
  }
}
