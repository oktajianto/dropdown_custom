part of 'custom_dropdown.dart';

/// Controls a [CustomDropdown] programmatically and reports its open state.
///
/// Create one, pass it to a dropdown's `controller`, and call [open], [close],
/// or [toggle] from anywhere (e.g. another button). Because it is a
/// [ChangeNotifier], you can also listen for open/close changes:
///
/// ```dart
/// final controller = DropdownController();
///
/// CustomDropdown<String>(
///   controller: controller,
///   items: const ['A', 'B'],
///   onChanged: (_) {},
/// );
///
/// // Elsewhere:
/// ElevatedButton(onPressed: controller.open, child: const Text('Open'));
/// controller.addListener(() => print('open: ${controller.isOpen}'));
/// ```
///
/// A controller drives a single dropdown at a time. Dispose it when you are
/// done, like any [ChangeNotifier].
class DropdownController extends ChangeNotifier {
  VoidCallback? _openHook;
  VoidCallback? _closeHook;
  bool _isOpen = false;

  /// Whether the dropdown menu is currently open.
  bool get isOpen => _isOpen;

  /// Opens the menu. No-op if already open, if no dropdown is attached, or if
  /// the dropdown is disabled/empty.
  void open() => _openHook?.call();

  /// Closes the menu. No-op if already closed or no dropdown is attached.
  void close() => _closeHook?.call();

  /// Opens the menu if closed, or closes it if open.
  void toggle() => _isOpen ? close() : open();

  // --- Internal: wired up by CustomDropdown's state ---

  void _attach({required VoidCallback open, required VoidCallback close}) {
    _openHook = open;
    _closeHook = close;
  }

  void _detach() {
    _openHook = null;
    _closeHook = null;
  }

  void _setIsOpen(bool value) {
    if (_isOpen == value) return;
    _isOpen = value;
    notifyListeners();
  }
}
