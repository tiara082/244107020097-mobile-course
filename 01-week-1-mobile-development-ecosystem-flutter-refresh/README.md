# Week 1: Mobile Development Ecosystem & Flutter Refresh

## Student Details
* **Name:** Tiara Febrianie
* **Student ID (NIM):** 244107020097
* **Class:** TI-3I
* **Department:** Information Technology - State Polytechnic of Malang (Polinema)

---

## Lab Reflections

### 1. When is native development more appropriate than cross-platform development?

Cross-platform tools like Flutter are very convenient because we can write a single codebase for both Android and iOS, saving substantial development time. However, native development (using Kotlin/Java for Android and Swift/Objective-C for iOS) is still the better choice in specific situations:

First, when an app needs deep hardware integration or access to specific device features—such as custom Bluetooth peripherals, low-level sensors, or background services. Cross-platform plugins do not always support the newest OS APIs immediately when Apple or Google release new platform updates, and writing custom platform channels can sometimes take more effort than building native from the start.

Second, for applications that require maximum graphical performance, such as 3D gaming, complex animations, or real-time camera and video editing. Native code communicates directly with the OS graphics layer without the overhead of Flutter's rendering engine.

Lastly, when an app needs to follow platform-specific UI guidelines strictly (Material Design on Android and Cupertino on iOS) down to the smallest detail, or when adding features to an existing legacy native app where introducing a cross-platform framework would add unnecessary bundle size and architectural complexity.

### 2. How does a state change relate to the widget tree and declarative UI?

In traditional imperative UI (like native Android with Java/Kotlin using XML and `findViewById`), we usually grab a UI element by ID and manually update its properties—for example, calling `setText()` on a text view. Flutter works differently using a declarative approach: the UI is simply a visual representation of the current state of our data.

In this week's profile app, information like the student details and the counter are stored as state variables. Widgets in Flutter are immutable, meaning they cannot be modified once built. When data changes (for example, when we click the button to increment the counter or edit profile info), we call `setState()`. This tells Flutter that the underlying data has changed and that the UI needs to be updated.

When `setState()` runs, Flutter executes the `build()` method again to reconstruct the widget subtree with the updated state. Instead of redrawing everything from scratch on the screen, Flutter's engine compares the new widget tree with the previous one and only updates and repaints the specific widgets whose data actually changed.

### 3. Why are small commits with clear messages useful for teamwork and a portfolio?

From a teamwork perspective, making small, frequent commits that focus on a single logical task makes collaboration much smoother. When working with other developers, small commits mean smaller pull requests, which are easier to read and review. If a bug happens to be introduced, it is easy to locate the exact commit that caused the problem and revert it without breaking other features that were worked on at the same time. It also helps prevent large, painful merge conflicts when teammates edit overlapping files.

For a personal portfolio repository, commit history acts as a transparent log of our thought process and problem-solving habits. When an instructor or potential employer inspects the repository, having clear commits (like following conventional commits such as `feat:`, `fix:`, `docs:`) shows that we work methodically and build features step-by-step, rather than just writing everything in one go and making a single vague commit like "finish assignment".
