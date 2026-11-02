# Week 9: AI-Assisted Development & Vibe Coding

## Student Details
* **Name:** Tiara Febrianie
* **Student ID (NIM):** 244107020097
* **Class:** TI-3I
* **Department:** Information Technology - State Polytechnic of Malang (Polinema)


---

## Lab Reflections

### 1. Which AI hallucination did you find and how did you prove it?

During initial code generation, the AI produced a widget snippet for the search bar trailing clear button:
`trailing: [Icon(Icons.clear, onPressed: () => ref.read(...))]`
In the Flutter framework, `Icon` is a purely visual widget that renders a graphical glyph from a font; it does not extend button classes and has no `onPressed` callback. 

I proved this hallucination in two ways:
1. **Dart Analyzer & Compiler Error:** When analyzing the code, the analyzer immediately reported `The named parameter 'onPressed' isn't defined for the class 'Icon'`.
2. **Official Flutter API Reference:** Verifying the Flutter SDK documentation confirmed that interactive icon buttons must use the `IconButton` widget (`IconButton(icon: const Icon(Icons.clear), onPressed: ...)`).  
Catching this demonstrated why developer oversight is essential: AI frequently confuses similar-sounding properties between visual and interactive widgets.

### 2. Which prompt helped most and what did you change?

The prompt that delivered the highest quality output was the **Five-Slot Formula** with strict **negative constraints** (*Limits*):
* **Initial Weak Prompt:** Asking `"Buatkan fitur search catatan Flutter"` resulted in a messy 120-line `StatefulWidget` where filtering was done inside `setState()`, completely bypassing our Clean Architecture setup and hardcoding sample data directly inside the build method.
* **Refined Five-Slot Prompt:** Adding explicit architectural constraints (`Limits: Do not put search logic inside UI widgets; filter logic must live in a pure domain usecase SearchNotes without Flutter imports; use Riverpod providers for state`) immediately guided the AI to separate concerns properly.  
Specifying what the AI was **forbidden** from doing (*negative prompting*) proved significantly more effective than only describing the desired end feature.

### 3. Which refactor did you make to AI code?

The most critical refactoring made to the AI code was **sanitizing and normalizing the search query string**:
* **AI's Raw Logic:** The AI initially wrote `notes.where((note) => note.title.contains(query)).toList()`.
* **The Defects:**
  1. It was case-sensitive: searching `"mobile"` would fail to match `"Praktikum Mobile"`.
  2. It failed on whitespace: if a mobile user accidentally typed a trailing space from auto-correct (`"kuliah "`), it returned zero matches.
  3. It only searched titles, ignoring the note body and category tags.
* **My Refactor in `SearchNotes`:**
  ```dart
  final sanitizedQuery = query.trim().toLowerCase();
  if (sanitizedQuery.isEmpty) return notes;
  return notes.where((note) {
    final titleMatch = note.title.toLowerCase().contains(sanitizedQuery);
    final bodyMatch = note.body.toLowerCase().contains(sanitizedQuery);
    final categoryMatch = note.category.toLowerCase().contains(sanitizedQuery);
    return titleMatch || bodyMatch || categoryMatch;
  }).toList(growable: false);
  ```
This transformed a fragile snippet into a robust, real-world search engine that handles keyboard quirks gracefully.

### 4. Which accept/reject decision was hardest?

The hardest decision was **rejecting the AI's proposal to use an animated search delegate with `SearchAnchor.viewBuilder`**. 

The AI argued that using `SearchAnchor` was the "most modern Material 3 way" in Flutter. However, after analyzing the trade-offs:
* `SearchAnchor` opened a full-screen overlay dialog that hid the existing note cards and required managing separate route navigation transitions.
* For our campus notes screen, users need an instant, in-page filter experience where typing immediately narrows down the list below the search bar without jarring screen transitions or modal dialogs.
* Furthermore, the AI's code for `SearchAnchor` contained multiple deprecated constructor parameters that triggered warnings on Flutter 3.24+.

I decided to reject the overly complex full-screen anchor and instead implemented an in-page `SearchBar` connected directly to Riverpod's `filteredNotesProvider`. This kept the code lean (<80 lines), maintained immediate visual feedback, and ensured 100% testability with standard widget testers.

