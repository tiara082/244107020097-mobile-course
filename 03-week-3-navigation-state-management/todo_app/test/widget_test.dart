import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_app/main.dart';
import 'package:todo_app/providers/todo_provider.dart';
import 'package:todo_app/models/todo.dart';

class FakeTodoListNotifier extends TodoListNotifier {
  final List<Todo> initial;
  FakeTodoListNotifier(this.initial);

  @override
  Future<List<Todo>> build() async => initial;
}

void main() {
  testWidgets('TodoApp renders loading indicator initially', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: TodoApp(),
      ),
    );

    // Before build completes, initial state displays loading indicator
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Advance fake clock so the 2-second delay timer completes cleanly
    await tester.pump(const Duration(seconds: 3));
  });

  testWidgets('TodoApp renders list of todos when loaded', (WidgetTester tester) async {
    final mockTodos = [
      Todo(id: '1', title: 'Belajar GoRouter dan Riverpod', createdAt: DateTime.now()),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          todoListProvider.overrideWith(() => FakeTodoListNotifier(mockTodos)),
        ],
        child: const TodoApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Belajar GoRouter dan Riverpod'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });
}
