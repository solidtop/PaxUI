/// @desc Base for widgets holding a boolean checked state, such as checkboxes and toggles.
function PaxCheckable() : PaxWidget() constructor {
    /// @ignore
    _checked = false;

    styles = undefined;
    focus_mode = PaxFocusMode.All;
    toggled = new PaxSignal();
    is_pressed = false;

    /// @desc Sets the checked state.
    /// @param {Bool} value
    /// @returns {Struct.PaxCheckable}
    static checked = function(value) {
        _apply(value);
        return self;
    }

    /// @desc Switches on.
    /// @returns {Struct.PaxCheckable}
    static check = function() {
        _apply(true);
        return self;
    }

    /// @desc Switches off.
    /// @returns {Struct.PaxCheckable}
    static uncheck = function() {
        _apply(false);
        return self;
    }

    /// @desc Returns whether the widget is checked.
    /// @returns {Bool}
    static is_checked = function() {
        return _checked;
    }

    /// @desc Connects a handler to toggled.
    /// @param {Function} handler
    /// @returns {Struct.PaxCheckable}
    static on_toggled = function(handler) {
        toggled.connect(handler);
        return self;
    }

    /// @ignore [Override] Clicks and space/enter flip the checked state.
    /// @param {Struct.PaxEvent} event
    static _on_event = function(event) {
        switch (event.type) {
            case PaxEventType.PointerPressed:
                if (event.button != mb_left) break;
                is_pressed = true;
                event.consume();
                break;
            case PaxEventType.PointerReleased:
                if (!is_pressed) break;
                is_pressed = false;
                if (_hit_test(event.x, event.y)) _activate();
                event.consume();
                break;
            case PaxEventType.PointerCancelled:
                is_pressed = false;
                break;
            case PaxEventType.KeyPressed:
                if (event.key != vk_space && event.key != vk_enter) break;
                _activate();
                event.consume();
                break;
            case PaxEventType.Accept:
                _activate();
                event.consume();
                break;
        }
    }

    /// @ignore [Virtual] Responds to a click or key press. Override to change what activation does.
    static _activate = function() {
        _apply(!_checked);
    }

    /// @ignore [Virtual] Reacts to the checked state changing, before toggled is emitted.
    static _on_checked_changed = function() {}

    /// @ignore
    /// @param {Bool} value
    static _apply = function(value) {
        if (value == _checked) return;
        _checked = value;
        _on_checked_changed();
        toggled.emit(_checked);
    }
}
