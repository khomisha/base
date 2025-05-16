Here's how to handle the **window close event** (e.g., tab/browser closing) in Flutter for web using **`package:web`**. This is useful for scenarios like showing a confirmation dialog or saving data before the user exits:

---

### **Example 1: Basic BeforeUnload Handler**
Show a confirmation dialog when the user tries to close the window:
```dart
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:web/web.dart' as web;

void setupBeforeUnload() {
  if (kIsWeb) {
    web.window.addEventListener('beforeunload', (web.Event event) {
      final e = event as web.BeforeUnloadEvent; // Cast to access returnValue
      e.preventDefault(); // Required to trigger the browser's confirmation dialog
      e.returnValue = ''; // Legacy property (still required for some browsers)
      return ''; // Modern browsers ignore this but require a non-null value
    });
  }
}
```

---

### **Example 2: Conditionally Show Dialog**
Only prompt if unsaved changes exist:
```dart
bool _hasUnsavedChanges = true;

void setupConditionalBeforeUnload() {
  if (kIsWeb) {
    web.window.addEventListener('beforeunload', (web.Event event) {
      if (_hasUnsavedChanges) {
        final e = event as web.BeforeUnloadEvent;
        e.preventDefault();
        e.returnValue = '';
        return '';
      }
      return null; // No dialog if no unsaved changes
    });
  }
}
```

---

### **Example 3: Cleanup on Window Close**
Run cleanup logic (sync-only) before closing:
```dart
void setupCleanupOnClose() {
  if (kIsWeb) {
    web.window.addEventListener('beforeunload', (web.Event event) {
      // Synchronous cleanup (e.g., logging, clearing temp data)
      print('Performing cleanup before window closes...');
      // Note: Async operations (e.g., HTTP requests) may NOT complete
      return null; // Allow the window to close immediately
    });
  }
}
```

---

### **Important Notes**
1. **Browser Restrictions**:
   - You **can't fully prevent closure**; the dialog is just a courtesy.
   - Custom messages in the dialog are **ignored by most modern browsers** (they show a generic warning).

2. **Async Limitations**:
   - The `beforeunload` event handler **must be synchronous**. Async operations (e.g., HTTP requests) may not complete before the window closes.

3. **Flutter Integration**:
   - Call `setupBeforeUnload()` in `initState()` of a `StatefulWidget`.
   - Use `dispose()` to remove listeners if needed (though `beforeunload` typically doesn’t require cleanup).

---

### **Full Flutter Integration**
```dart
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:web/web.dart' as web;

class MyPage extends StatefulWidget {
  const MyPage({super.key});

  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  bool _hasUnsavedChanges = true;

  @override
  void initState() {
    super.initState();
    _setupBeforeUnload();
  }

  void _setupBeforeUnload() {
    if (kIsWeb) {
      web.window.addEventListener('beforeunload', _handleBeforeUnload);
    }
  }

  dynamic _handleBeforeUnload(web.Event event) {
    if (_hasUnsavedChanges) {
      final e = event as web.BeforeUnloadEvent;
      e.preventDefault();
      e.returnValue = '';
      return '';
    }
    return null;
  }

  @override
  void dispose() {
    if (kIsWeb) {
      web.window.removeEventListener('beforeunload', _handleBeforeUnload);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Switch(
          value: _hasUnsavedChanges,
          onChanged: (v) => setState(() => _hasUnsavedChanges = v),
        ),
      ),
    );
  }
}
```

---

### **Alternatives**
- For navigation within your app, use Flutter's own navigation system (e.g., `Navigator`).
- For data persistence, use `shared_preferences` or a backend service.

This approach ensures your Flutter web app behaves gracefully when users attempt to close the window.

Apologies for the confusion earlier! With Dart's new **`dart:js_interop`** (replacing `dart:js_util`), here's the corrected approach using the modern JS interop system:

---

### **Step 1: Update Imports**
```dart
import 'dart:js_interop'; // Core JS interop
import 'dart:js_interop_unsafe'; // For toJS/toDart conversions (if needed)
import 'package:web/web.dart' as web;
```

---

### **Step 2: Define the Event Handler**
Use **`JS`-compatible types** and **extension types** for type safety:
```dart
@JS()
external dynamic _handleBeforeUnload(web.Event event);
```

---

### **Step 3: Attach the Event Listener**
Use `toJS` to convert Dart functions to JS-compatible callbacks:
```dart
void _setupBeforeUnload() {
  if (kIsWeb) {
    web.window.addEventListener(
      'beforeunload'.toJS,
      _handleBeforeUnload.toJS, // Convert to JS function
    );
  }
}
```

---

### **Full Example**
```dart
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:web/web.dart' as web;
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

class MyPage extends StatefulWidget {
  const MyPage({super.key});

  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  bool _hasUnsavedChanges = true;

  @override
  void initState() {
    super.initState();
    _setupBeforeUnload();
  }

  void _setupBeforeUnload() {
    if (kIsWeb) {
      web.window.addEventListener(
        'beforeunload'.toJS,
        _handleBeforeUnload.toJS, // Convert to JS function
      );
    }
  }

  @JS() // Mark as JS-compatible
  external dynamic _handleBeforeUnload(web.Event event);

  @override
  void dispose() {
    if (kIsWeb) {
      web.window.removeEventListener(
        'beforeunload'.toJS,
        _handleBeforeUnload.toJS,
      );
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Switch(
          value: _hasUnsavedChanges,
          onChanged: (v) => setState(() => _hasUnsavedChanges = v),
        ),
      ),
    );
  }
}

// Define the JS interop logic
extension type _BeforeUnloadHandler(JSFunction _) implements JSFunction {
  external factory _BeforeUnloadHandler(dynamic Function(web.Event event) f);
}

extension _MyPageStateExtension on _MyPageState {
  // JS interop implementation
  dynamic _handleBeforeUnload(web.Event event) {
    if (event case web.BeforeUnloadEvent() when _hasUnsavedChanges) {
      event.preventDefault();
      event.returnValue = ''.toJS; // Convert to JS string
    }
    return null;
  }
}
```

---

### **Key Changes**
1. **`dart:js_interop`** replaces `dart:js_util`.
2. **`toJS` Conversions**: Explicitly convert strings and functions to JS types.
3. **Type Safety**: Use `external` and `@JS()` to define JS-compatible methods.
4. **Extension Types**: For advanced type mappings (optional but recommended).

---

### **Why This Works**
- **Modern Interop**: `dart:js_interop` uses static typing and avoids magic strings.
- **JS Function Conversion**: `toJS` ensures Dart functions are JS-compatible.
- **Browser Compliance**: `preventDefault()` and `returnValue` still control the close dialog.

---

### **Notes**
- **Strings**: Always convert literals (e.g., `'beforeunload'.toJS`).
- **Functions**: Use `toJS` when passing Dart functions to JS APIs.
- **Null Safety**: Return `null` explicitly if no value is needed.

This approach aligns with Dart's latest JS interop system while maintaining browser functionality.

To programmatically close a browser window in Flutter for the web using **`package:web`** (modern JS interop), follow these steps. Note that browser security restrictions may prevent closing windows/tabs not opened by your script.

---

### **1. Close the Current Window**
Attempt to close the current window/tab (works **only** if the window was opened by your script via `window.open()`):
```dart
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:web/web.dart' as web;

void closeCurrentWindow() {
  if (kIsWeb) {
    try {
      web.window.close(); // Might be blocked by the browser
    } catch (e) {
      print('Failed to close window: $e');
    }
  }
}
```

---

### **2. Close a Child Window (Popup)**
Close a window that **you programmatically opened**:
```dart
web.Window? childWindow;

void openChildWindow() {
  if (kIsWeb) {
    // Open a blank child window (URL can be customized)
    childWindow = web.window.open('', 'myPopup');
  }
}

void closeChildWindow() {
  if (kIsWeb) {
    childWindow?.close(); // Close the child window
    childWindow = null;
  }
}
```

---

### **Full Flutter Example**
```dart
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:web/web.dart' as web;

class WindowDemo extends StatefulWidget {
  const WindowDemo({super.key});

  @override
  State<WindowDemo> createState() => _WindowDemoState();
}

class _WindowDemoState extends State<WindowDemo> {
  web.Window? childWindow;

  void _openChild() {
    if (kIsWeb) {
      childWindow = web.window.open('', 'flutterChild');
      print('Child window opened');
    }
  }

  void _closeChild() {
    if (kIsWeb) {
      childWindow?.close();
      childWindow = null;
      print('Child window closed');
    }
  }

  void _closeCurrent() {
    if (kIsWeb) {
      try {
        web.window.close();
      } catch (e) {
        print('Browser blocked closing the main window: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cannot close main window!'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _openChild,
              child: const Text('Open Child Window'),
            ),
            ElevatedButton(
              onPressed: _closeChild,
              child: const Text('Close Child Window'),
            ),
            ElevatedButton(
              onPressed: _closeCurrent,
              child: const Text('Close Current Window'),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

### **Key Notes**
- **Main Window Restrictions**: Browsers block `window.close()` for the main window unless it was opened by another script (e.g., via `window.open()`).
- **Child Windows**: You can only close windows **you opened programmatically**.
- **Popup Blockers**: `window.open()` may be blocked unless triggered by direct user interaction (e.g., a button click).
- **Error Handling**: Wrap `window.close()` in a `try/catch` to handle browser denials.

---

### **When It Works**
| Scenario                   | Supported? |
|----------------------------|------------|
| Closing a child window      | ✅ Yes     |
| Closing a script-opened tab | ✅ Yes     |
| Closing the main user tab   | ❌ No      |

---

### **Alternatives**
- Use **`dart:html`** (deprecated) for legacy projects (not recommended).
- For cross-platform navigation, use Flutter’s `Navigator` to close app screens (not browser windows).
