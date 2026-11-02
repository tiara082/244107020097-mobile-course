import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'local/note.dart';
import 'prefs.dart';
import 'repositories/note_repository.dart';
import 'sync.dart';

final prefsRepositoryProvider = Provider((ref) => PrefsRepository());

final darkModeProvider =
    AsyncNotifierProvider<DarkModeNotifier, bool>(DarkModeNotifier.new);

class DarkModeNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() => ref.watch(prefsRepositoryProvider).getDarkMode();

  Future<void> toggle() async {
    final next = !(state.value ?? false);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(prefsRepositoryProvider).setDarkMode(next);
      return next;
    });
  }
}

final lastOpenedProvider = FutureProvider<String?>((ref) async {
  final repo = ref.watch(prefsRepositoryProvider);
  return repo.getLastOpened();
});

final noteRepositoryProvider = Provider((ref) => NoteRepository());

final notesProvider = FutureProvider<List<Note>>((ref) async {
  final repo = ref.watch(noteRepositoryProvider);
  return repo.fetchNotes();
});

final noteDetailProvider =
    FutureProvider.family<Note?, int>((ref, id) async {
  final repo = ref.watch(noteRepositoryProvider);
  return repo.fetchNoteById(id);
});

final dirtyCountProvider = FutureProvider<int>((ref) async {
  final repo = ref.watch(noteRepositoryProvider);
  return repo.countDirty();
});

final syncNotifierProvider =
    StateNotifierProvider<SyncNotifier, bool>((ref) {
  return SyncNotifier(ref);
});

class SyncNotifier extends StateNotifier<bool> {
  SyncNotifier(this._ref) : super(false);
  final Ref _ref;

  Future<int> runSync() async {
    state = true;
    try {
      final repo = _ref.read(noteRepositoryProvider);
      final count = await syncNotes(repo);
      _ref.invalidate(notesProvider);
      _ref.invalidate(dirtyCountProvider);
      return count;
    } finally {
      state = false;
    }
  }
}
