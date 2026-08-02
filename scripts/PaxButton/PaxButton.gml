/// @desc A clickable button widget.
function PaxButton() : PaxWidget() constructor {
    /// @ignore
    _label = undefined;

    pressed = new PaxSignal();
    released = new PaxSignal();
    clicked = new PaxSignal();
    pointer_entered = new PaxSignal();
    pointer_exited = new PaxSignal();
    focus_entered = new PaxSignal();
    focus_exited = new PaxSignal();
    
    styles = undefined;
    focus_mode = PaxFocusMode.All;
    is_pressed = false;

    row();
    center();

    /// @desc Sets the button's text label.
    /// @param {String} str
    /// @returns {Struct.PaxButton}
    static text = function(str) {
        if (_label == undefined) {
            _label = new PaxLabel(str);
            add(_label);
        } else {
            _label.text = str;
        }

        return self;
    }

    /// @desc [Override] Uses a per-state style set in place of the theme's. The set is linked, not copied.
    /// @param {Struct.PaxButtonStyles} preset_styles
    /// @returns {Struct.PaxButton}
    static styled = function(preset_styles) {
        styles = preset_styles;
        return self;
    }

    /// @desc Connects a handler to the clicked signal.
    /// @param {Function} handler
    /// @returns {Struct.PaxButton}
    static on_clicked = function(handler) {
        clicked.connect(handler);
        return self;
    }

    /// @desc Connects a handler to the pressed signal.
    /// @param {Function} handler
    /// @returns {Struct.PaxButton}
    static on_pressed = function(handler) {
        pressed.connect(handler);
        return self;
    }

    /// @desc Connects a handler to the released signal.
    /// @param {Function} handler
    /// @returns {Struct.PaxButton}
    static on_released = function(handler) {
        released.connect(handler);
        return self;
    }

    /// @desc Connects a handler to the pointer_entered signal.
    /// @param {Function} handler
    /// @returns {Struct.PaxButton}
    static on_pointer_entered = function(handler) {
        pointer_entered.connect(handler);
        return self;
    }

    /// @desc Connects a handler to the pointer_exited signal.
    /// @param {Function} handler
    /// @returns {Struct.PaxButton}
    static on_pointer_exited = function(handler) {
        pointer_exited.connect(handler);
        return self;
    }

    /// @desc Connects a handler to the focus_entered signal.
    /// @param {Function} handler
    /// @returns {Struct.PaxButton}
    static on_focus_entered = function(handler) {
        focus_entered.connect(handler);
        return self;
    }

    /// @desc Connects a handler to the focus_exited signal.
    /// @param {Function} handler
    /// @returns {Struct.PaxButton}
    static on_focus_exited = function(handler) {
        focus_exited.connect(handler);
        return self;
    }

    /// @ignore [Override] Translates pointer events into button state and signals.
    /// @param {Struct.PaxEvent} event
    static _on_event = function(event) {
        switch (event.type) {
            case PaxEventType.PointerEntered:
                pointer_entered.emit(self);
                break;
            case PaxEventType.PointerExited:
                pointer_exited.emit(self);
                break;
            case PaxEventType.PointerPressed:
                if (event.button != mb_left) break;
                is_pressed = true;
                pressed.emit(self);
                event.consume();
                break;
            case PaxEventType.PointerReleased:
                if (!is_pressed) break;
                is_pressed = false;
                released.emit(self);
                if (_hit_test(event.x, event.y)) clicked.emit(self);
                event.consume();
                break;
            case PaxEventType.PointerCancelled:
                is_pressed = false;
                break;
            case PaxEventType.FocusEntered:
                focus_entered.emit(self);
                break;
            case PaxEventType.FocusExited:
                focus_exited.emit(self);
                break;
            case PaxEventType.KeyPressed:
                if (event.key == vk_enter || event.key == vk_space) {
                    clicked.emit(self);
                    event.consume();
                }
                break;
            case PaxEventType.Accept:
                clicked.emit(self);
                event.consume();
                break;
        }
    }
    
    /// @ignore [Override] Resolves the style for the current interaction state.
    /// @returns {Struct.PaxStyle}
    static _get_target_style = function() {
        var styles = _get_styles();
        if (!enabled) return styles.disabled;
        if (is_pressed && is_hovered) return styles.pressed;
        if (is_hovered) return styles.hovered;
        if (is_focused) return styles.focused;
        return style ?? styles.normal;
    }

    /// @ignore
    /// @returns {Struct.PaxButtonStyles}
    static _get_styles = function() {
        return styles ?? pax_theme().button;
    }
}
