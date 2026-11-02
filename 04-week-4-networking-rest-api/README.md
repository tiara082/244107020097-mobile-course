# Week 4: Networking & REST API (Dio & Riverpod)

## Student Details
* **Name:** Tiara Febrianie
* **Student ID (NIM):** 244107020097
* **Class:** TI-3I
* **Department:** Information Technology - State Polytechnic of Malang (Polinema)


---

## Lab Reflections

### 1. Why is the UI forbidden from calling Dio directly? What breaks if this rule is violated?

In mobile application development, coupling UI widgets directly to a low-level networking client like Dio breaks separation of concerns and creates tight coupling. If a widget calls `Dio().get(...)` directly:

First, the UI becomes almost impossible to unit test or widget test because every test would attempt to fire real HTTP network requests across the internet, leading to flaky tests, rate limiting, and slow CI/CD runs. By routing requests through a repository layer that is provided by Riverpod, we can easily override the repository with a fake or mock in tests without changing a single line of UI code.

Second, technical networking concerns (like base URLs, authentication tokens, timeout headers, and serialization from raw JSON maps) end up scattered across multiple UI pages. If the backend API changes an endpoint path or data structure, we would have to hunt down and fix code across dozens of screen files.

Third, state management breaks down: multiple screens might independently trigger duplicate network requests for the same data rather than reading from a single shared state cache.

### 2. When is client-side pagination enough, and when must you rely on server pagination (`_page` / `_limit`)?

Client-side pagination is only acceptable when the total dataset is guaranteed to remain small and finite—for example, a list of 50 states, fixed app settings, or a local list of categories. In that case, fetching all items once and slicing the list in memory saves backend roundtrips.

However, for dynamic, growing, or large collections (like social media feeds, e-commerce products, or user posts), server-side pagination with query parameters like `_page` and `_limit` is mandatory:
* Mobile devices have constrained memory and bandwidth. Downloading thousands of records upfront causes significant initial load latency, drains battery and cellular data, and can crash the app with out-of-memory errors.
* On the backend, querying and serializing 10,000 records on every request puts unnecessary load on the database.

Server-side pagination ensures that mobile clients only download what the user is currently looking at, loading subsequent pages via infinite scrolling as the user approaches the bottom of the list.

### 3. How do repository exceptions become `AsyncError` without `try`/`catch` in every widget? When is explicit `try`/`catch` still needed?

In Riverpod, when using `AsyncNotifier` (or `FutureProvider`), the `build()` method is asynchronous and returns a `Future`. Riverpod automatically wraps this future in an internal error handler: if the repository throws an uncaught exception (such as a `DioException`), Riverpod catches it and automatically transitions the provider's state to `AsyncError(error, stackTrace)`. The UI widget merely observes this through `postsAsync.when(loading: ..., error: ..., data: ...)`, eliminating the need for repetitive `try/catch` boilerplate across every screen.

Explicit `try/catch` is still required, however, in imperative event handlers and side-effect methods—such as our manual `refresh()` method or when submitting a form via a button click. In those callback methods, state is mutated manually, so wrapping the repository call in `try/catch` is necessary to catch the failure and set `state = AsyncError(e, st)` so the UI can react to the failed refresh without crashing the app.

### 4. Which part of the AI output did you fix, and why?

When using AI to generate the repository layer for the comments endpoint and error mapping, I audited the code against practical Flutter engineering standards and fixed several crucial gaps:

First, the AI generated `Post.fromJson` and `Comment.fromJson` using direct forced casts like `json['userId'] as int`. In real-world APIs, fields can arrive as null, missing, or numbers as doubles. I refactored the models to use defensive parsing: `(json['userId'] as num?)?.toInt() ?? 0` and `json['title'] as String? ?? ''`, which prevents the common `type 'Null' is not a subtype of type 'String'` runtime crashes.

Second, the AI only handled basic HTTP status codes and completely ignored network-level errors like `connectionTimeout` and `connectionError`. I expanded `friendlyErrorMessage()` to map all major `DioExceptionType` cases into clear, human-readable Indonesian messages with actionable retry prompts.

Third, the AI attempted to use an unsupported `retry` parameter from Riverpod 3.0 that failed to compile on Riverpod 2.6.1, which I removed to ensure clean compilation.

Lastly, the AI test only tested the happy path with complete JSON. I added unit tests specifically verifying defensive parsing against missing fields, multiple HTTP status code mappings (404, connection error, timeout), and provider state transitions using a `FakePostRepository`.

