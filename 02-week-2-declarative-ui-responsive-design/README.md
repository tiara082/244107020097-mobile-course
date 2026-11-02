# Week 2: Declarative UI & Responsive Design

## Student Details
* **Name:** Tiara Febrianie
* **Student ID (NIM):** 244107020097
* **Class:** TI-3I
* **Department:** Information Technology - State Polytechnic of Malang (Polinema)

---

## Lab Reflections

### 1. How does imperative thinking differ from declarative thinking when building UI?

In imperative UI development (like native Android with Java/Kotlin using XML and `findViewById`), we think in terms of step-by-step UI mutations. We find a specific view element and tell it directly how to change: for example, calling `button.setEnabled(false)` or `textView.setText("...")`. The developer has to manually manage transitions between states, which often leads to bugs where the UI gets out of sync with the underlying data if one step is forgotten.

In declarative UI with Flutter, we think in terms of UI being a direct function of current data state. Instead of modifying views after they exist, we describe what the whole UI should look like for any given state (such as `isDarkMode` or `constraints.maxWidth >= kWideBreakpoint`). When something changes, we simply update the state using `setState()`, and Flutter handles rebuilding the widget tree to reflect those changes on screen. We don't worry about "how to manually transition each widget", but rather "what the widgets should look like given the current data".

### 2. When does Expanded help, and when can it cause a layout error?

`Expanded` is very helpful inside a `Row` or `Column` when we want a widget to automatically fill whatever remaining empty space exists along that axis, rather than guessing or hardcoding pixel sizes. In our academic dashboard, wrapping the card's title in `Expanded` inside the `Row` allows the text to occupy the remaining horizontal width beside the icon without causing overflow or clipping.

However, `Expanded` causes a runtime error (specifically an assertion error about unbounded constraints) if placed inside a parent that has infinite/unbounded dimensions along that axis—most commonly inside a scrollable container. For instance, placing an `Expanded` inside a `Row` that is directly wrapped in a horizontal `SingleChildScrollView` crashes the layout because the scroll view allows infinite width, making it impossible for `Expanded` to know how much space it should take. To prevent this, the parent must be bounded using constraints (like `LayoutBuilder` or a fixed-width container), or the child must use its own natural sizing instead of `Expanded`.

### 3. How do breakpoints and themes affect user experience?

Breakpoints allow an application to adapt intelligently across varying screen form factors instead of forcing mobile-sized layouts onto wide desktop monitors or vice versa. In this dashboard, setting a breakpoint at 700px (`kWideBreakpoint`) means smartphone users get a clean, readable single-column vertical layout that is easy to scroll with one hand. On wider screens like tablets or desktop browsers, the same page switches to a two-column grid so that screen real estate isn't wasted and cards don't look awkwardly stretched.

Themes (supporting both light and dark modes) directly affect usability, accessibility, and visual comfort. Using centralized `ThemeData` ensures high contrast ratios for readability in bright sunlight while offering dark mode to reduce eye strain in low-light environments. Centralizing typography and color schemes in `Theme.of(context)` also guarantees visual consistency across all cards and widgets without hardcoding color values in multiple places.

### 4. What did you verify after receiving an AI design recommendation?

When comparing `GridView` and `LayoutBuilder + Column/Row` using AI, the suggestion pointed toward `LayoutBuilder` because it handles dynamic card heights more flexibly without aspect-ratio overflow. Rather than taking that recommendation at face value, I verified several concrete things:
* First, I tested the layout at extreme dimensions, resizing the emulator down to 320px and up to 1200px to verify that no `RenderFlex` overflow warnings appeared in the terminal.
* Second, I checked accessibility: wrapping cards and switches with explicit `Semantics` tags to make sure screen readers read the labels in a logical, linear order (top-to-bottom) rather than jumping across columns.
* Third, I verified that all suggested widgets (`LayoutBuilder`, `SingleChildScrollView`, `Card`, `Switch.adaptive`) are part of standard Flutter and stable without relying on deprecated APIs or external packages.
* Finally, I wrote automated widget tests in `test/widget_test.dart` simulating narrow (400px) and wide (1200px) screens with `tester.view.physicalSize` to prove programmatically that the layout adapts as expected.
