import 'repositories/note_repository.dart';

Future<int> syncNotes(NoteRepository repo) async {
  final dirtyCount = await repo.countDirty();
  if (dirtyCount == 0) return 0;

  // Simulate network synchronization delay
  await Future.delayed(const Duration(milliseconds: 1200));

  // Mark all unsynced dirty records as synced
  await repo.markAllSynced();
  return dirtyCount;
}
