# Week 3: Navigation & State Management (GoRouter & Riverpod)

Mobile Application Development Lab Assignment - Week 3 ToDo Application Report with GoRouter and Riverpod.

---

## Student Details
* **Name:** Tiara Febrianie
* **Student ID (NIM):** 244107020097
* **Class:** TI-3I
* **Department:** Information Technology - State Polytechnic of Malang (Polinema)

---

## Objectives
* Understand multi-page declarative routing in Flutter using **GoRouter** (`GoRoute`, `context.go`, `context.push`, and route parameters).
* Understand the core concepts of centralized state management and why `setState` is insufficient for multi-screen state sharing.
* Implement **Riverpod 2.x** using modern patterns (`ProviderScope`, `ConsumerWidget`, `AsyncNotifier`, `NotifierProvider`, and derived providers).
* Master **`AsyncValue`** pattern matching (`.when`) to handle `loading`, `error`, and `data` states cleanly without contradictory boolean flags.
* Build a responsive ToDo application featuring task filtering, statistics summary, asynchronous data simulation, error recovery, and comprehensive unit/widget tests.
* Complete and critically document the AI Prompt Challenge.

---

## Tech Stack
* **Framework:** Flutter 3.x
* **Language:** Dart 3.x
* **State Management:** `flutter_riverpod: ^2.6.1`
* **Routing & Navigation:** `go_router: ^15.1.3`
* **Utilities:** `uuid: ^4.5.1`
* **Target Platforms:** Android, iOS, Windows Desktop, Web
* **Testing:** `flutter_test` (16 unit and widget tests)

---

## Application Overview & Key Features

The project implements a full-featured ToDo application located in [`todo_app/`](./todo_app/):

1. **Multi-Screen Declarative Navigation (`GoRouter`):**
   * `/`: Home task list screen with real-time progress indicator.
   * `/add`: Add new task screen opened via `context.push()` so the user can easily return via back button.
   * `/stats`: Dedicated statistics overview screen displaying completed vs. pending tasks and completion percentages.
2. **Reactive State Management (`Riverpod`):**
   * `TodoListNotifier`: An `AsyncNotifier<List<Todo>>` managing async fetch, task addition, completion toggling, and deletion immutably.
   * `FilteredTodosProvider`: Derived provider computing filtered views (`All`, `Completed`, `Pending`) reactively without modifying the original task list.
   * `TodoStatsProvider`: Derived provider calculating task metrics (total, completed, pending, percentage) automatically.
3. **Robust Asynchronous State Handling (`AsyncValue`):**
   * Loading state displays a clear progress indicator while data is being simulated from a mock remote source.
   * Error state displays an error message with a "Coba Lagi" (Retry) button to trigger state invalidation and refetch.
   * Includes a "Simulasi Error" button in the AppBar to demonstrate error catching and recovery live.
4. **Clean Code & Immutability:**
   * Immutable `Todo` model equipped with `copyWith`, value equality, and `hashCode`.

---

## How to Run & Test

1. Navigate to the `todo_app` project directory:
   ```bash
   cd 03-week-3-navigation-state-management/todo_app
   ```
2. Get dependencies:
   ```bash
   flutter pub get
   ```
3. Run the application:
   ```bash
   flutter run
   ```
4. Run all unit and widget tests:
   ```bash
   flutter test
   ```

---

## AI Prompt Challenge Documentation

### Prompt Submitted
```text
Create a Flutter page named StatsPage using flutter_riverpod.
Requirements:
- A ConsumerWidget with one AsyncNotifierProvider that simulates fetching statistics (2-second delay, ~30% chance of failure).
- The UI must handle loading (spinner), error (message + retry button), and success (ListView with 3 items).
- Provide a unit test for the notifier.
Explain each part of the code with comments.
```

### Verification & Audit Findings
Before adopting the generated code into the project, I audited it against modern Flutter and Riverpod best practices:
1. **API Modernity:** The initial AI output attempted to use the older `StateNotifierProvider` pattern and nested `Consumer` widgets. I refactored it to the modern Riverpod 2.x `AsyncNotifier` and `ConsumerWidget` structure.
2. **Immutability Check:** The generated model mutated list entries directly in place (`state.add(...)`). I corrected this to enforce immutability using spread operators `state = [...state, newTodo]` and `copyWith` so Riverpod can detect state transitions.
3. **State Handling Audit:** Verified that all three `AsyncValue` states (`loading`, `error`, `data`) were handled explicitly via `.when`, avoiding blank white screens during network delays or failures.
4. **Subscription Scope:** Verified that `ref.watch` was used strictly inside `build()` methods to prevent unnecessary re-renders, while `ref.read` was utilized inside button tap callbacks.

---

## Automated Testing Verification

The project includes 16 automated tests covering the `Todo` model, `TodoListNotifier`, derived providers, and widget rendering:

```bash
flutter test
```

### Test Results Summary (16/16 Passed):
- `Todo Model should create a Todo with required fields`
- `Todo Model should create a copy with updated fields using copyWith`
- `Todo Model should have value equality`
- `TodoListNotifier should initially be in loading state`
- `TodoListNotifier should load initial todos after build completes`
- `TodoListNotifier should add a new todo`
- `TodoListNotifier should toggle a todo completion status`
- `TodoListNotifier should delete a todo`
- `TodoListNotifier should handle simulateError`
- `TodoStatsProvider should calculate stats after todos are loaded`
- `TodoStatsProvider should update stats when a todo is toggled`
- `FilteredTodosProvider should return all todos when filter is all`
- `FilteredTodosProvider should return only completed todos when filter is completed`
- `FilteredTodosProvider should return only pending todos when filter is pending`
- `TodoApp renders loading indicator initially`
- `TodoApp renders list of todos when loaded`

---

## Lab Reflections

### 1. When is `setState` still enough, and when should state be lifted into Riverpod?

`setState` is completely sufficient for local, ephemeral state that only a single widget cares about. For example, controlling an active text field input, toggling password visibility, tracking whether an accordion panel is expanded, or handling local animations. In those situations, introducing an external state management solution would just add unnecessary boilerplate.

On the other hand, state should be moved into Riverpod as soon as that state needs to be accessed or modified by multiple widgets across different screens. In our ToDo application, the list of tasks needs to be read on the home page, updated from the add-task dialog, and summarized on the statistics page. If we only used `setState`, we would have had to pass callbacks and data up and down the widget tree through multiple layers (prop drilling), which quickly becomes messy. Moving state to Riverpod also keeps business logic decoupled from the UI, allows state to persist across screen transitions, and makes the logic directly testable without needing to pump UI widgets.

### 2. What is the difference between `context.go` and `context.push`, and when should each be used?

In GoRouter, `context.go` and `context.push` manipulate the navigation stack differently:

* **`context.go`** navigates to a target route by replacing the current navigation stack according to the router's declared hierarchy. It is best used for top-level destinations where you do not want the previous screen lingering in the back stack—such as navigating after a successful login redirect, or switching tabs in a bottom navigation bar where pressing the Android system back button shouldn't navigate through every tab you clicked.
* **`context.push`**, in contrast, pushes a new page directly on top of the existing navigation stack regardless of route structure. This is ideal for secondary or sub-screens—such as opening our "Add Task" page or opening a task's detail view—because the user expects a back button in the AppBar and wants to return to the exact same list position when they are done.

### 3. How does `AsyncValue` prevent bugs compared with three separate booleans?

When handling asynchronous operations (like network calls or database reads), developers traditionally create separate boolean flags: `bool isLoading`, `bool hasError`, and a nullable data variable `data`. This approach is fragile because it allows contradictory states to exist at the same time—for example, a bug where `isLoading == true` and `hasError == true` both evaluate to true, causing the UI to show both a loading spinner and an error message simultaneously, or showing old stale data under a failed status.

Riverpod's `AsyncValue` eliminates this by representing the asynchronous process as a strictly typed discriminated union: it can only ever be `AsyncLoading`, `AsyncError`, or `AsyncData` at any given moment. Furthermore, using `asyncValue.when(data: ..., loading: ..., error: ...)` forces us as developers to explicitly handle all three scenarios. This prevents common bugs like forgetting to build an error screen or leaving users on a blank white screen when an API call fails.

### 4. Which part of the AI output did you fix, and why?

When generating boilerplate with AI, I noticed several issues that required manual correction:

First, the AI provided a basic model with mutable properties and attempted to update state by calling `state.add()`. In Riverpod, state must be treated as strictly immutable; mutating a list in-place means Riverpod's equality check won't detect any change, and the UI won't rebuild. I rewrote the model to include `copyWith`, `operator ==`, and `hashCode`, and updated notifier methods to return new list instances using the spread operator (`state = [...state, newTodo]`).

Second, the AI used older Riverpod 1.x patterns (`StateNotifierProvider` and nested `Consumer` builders). I refactored the implementation to modern Riverpod 2.x standards using `AsyncNotifier` and clean `ConsumerWidget` classes, which makes the code much cleaner and easier to read.

Third, the generated UI only handled the happy path and lacked error recovery. I added a dedicated error view with a retry button using `ref.invalidate()` and simulated network errors so that asynchronous edge cases could actually be tested and experienced. Lastly, I expanded testing from a trivial mock to 16 robust unit and widget tests covering the notifier, derived filter providers, and screen rendering.

---

## App Screenshots

![ToDo Application Screenshots](screenshots/image.png)
