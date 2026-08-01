/// @desc Polls device input and routes events through widget trees.
function PaxInputManager() constructor {
    /// @ignore
    _pointer_event = new PaxPointerEvent();
    /// @ignore
    _key_event = new PaxKeyEvent();
    /// @ignore
    _hover_chain = [];
    /// @ignore
    _prev_hover_chain = [];
    /// @ignore
    _active_chain = [];
    /// @ignore
    _focus_chain = [];
    /// @ignore
    _active_button = mb_none;
    /// @ignore
    _press_x = 0;
    /// @ignore
    _press_y = 0;
    /// @ignore
    _last_x = undefined;
    /// @ignore
    _last_y = undefined;
    /// @ignore
    _nav_held = false;
    /// @ignore
    _nav_dir_x = 0;
    /// @ignore
    _nav_dir_y = 0;
    /// @ignore
    _nav_next_repeat = 0;
    /// @ignore
    _nav_suppressed = false;
    
    gamepad_device = 0;       
    stick_deadzone = 0.5;
    nav_repeat_delay = 400;    
    nav_repeat_interval = 130; 
    mouse_buttons = [mb_left, mb_right, mb_middle];

    /// @desc Polls device input and dispatches events through the widget tree.
    /// @param {Struct.PaxWidget} root
    static process = function(root) {
        if (!window_has_focus()) {
            _cancel_gesture();
            _clear_hover();
            return;
        }

        var pointer_x = device_mouse_x_to_gui(0);
        var pointer_y = device_mouse_y_to_gui(0);
        var delta_x = pointer_x - (_last_x ?? pointer_x);
        var delta_y = pointer_y - (_last_y ?? pointer_y);
        _last_x = pointer_x;
        _last_y = pointer_y;

        _update_hover(root, pointer_x, pointer_y);
        _process_press(pointer_x, pointer_y);
        _process_move(pointer_x, pointer_y, delta_x, delta_y);
        _process_release(pointer_x, pointer_y);
        _process_scroll(pointer_x, pointer_y);
        _process_keys(root);
        _process_nav(root);
    }

    /// @desc Transfers the active gesture to a widget in the chain; widgets
    /// cut off below it receive PointerCancelled. Usually via event.steal().
    /// @param {Struct.PaxWidget} widget
    static steal = function(widget) {
        var index = array_get_index(_active_chain, widget);
        if (index <= 0) return;

        _pointer_event.reset(PaxEventType.PointerCancelled);
        _pointer_event.x = _last_x;
        _pointer_event.y = _last_y;
        _pointer_event.button = _active_button;
        _pointer_event.delta_x = 0;
        _pointer_event.delta_y = 0;
        _pointer_event.scroll = 0;

        for (var i = 0; i < index; i++) {
            var cancelled = _active_chain[i];
            if (cancelled.enabled && cancelled.pointer_filter != PaxPointerFilter.Ignore)
                cancelled._on_event(_pointer_event);
            _pointer_event.consumed = false;
        }

        array_delete(_active_chain, 0, index);
    }

    /// @desc Returns the topmost widget under the pointer, or undefined.
    /// @returns {Struct.PaxWidget}
    static hovered = function() {
        return array_first(_hover_chain);
    }

    /// @desc Returns whether the pointer is over a widget other than the root.
    /// @returns {Bool}
    static is_pointer_over_ui = function() {
        return array_length(_hover_chain) > 1;
    }

    /// @ignore Rebuilds the hover chain when the topmost hit changes.
    /// @param {Struct.PaxWidget} root
    /// @param {Real} pointer_x
    /// @param {Real} pointer_y
    static _update_hover = function(root, pointer_x, pointer_y) {
        var hit = _find_hit(root, pointer_x, pointer_y);
        if (hit == array_first(_hover_chain)) return;

        var count = array_length(_hover_chain);
        array_resize(_prev_hover_chain, count);
        array_copy(_prev_hover_chain, 0, _hover_chain, 0, count);
        _build_chain(hit, _hover_chain);

        _emit_hover_diff(pointer_x, pointer_y);
    }

    /// @ignore
    /// @param {Real} pointer_x
    /// @param {Real} pointer_y
    static _emit_hover_diff = function(pointer_x, pointer_y) {
        var i = array_length(_prev_hover_chain) - 1;
        var j = array_length(_hover_chain) - 1;
        while (i >= 0 && j >= 0 && _prev_hover_chain[i] == _hover_chain[j]) {
            i--;
            j--;
        }

        for (var k = 0; k <= i; k++) {
            _prev_hover_chain[k].is_hovered = false;
            _notify(_prev_hover_chain[k], PaxEventType.PointerExited, pointer_x, pointer_y);
        }
        for (var k = j; k >= 0; k--) {
            _hover_chain[k].is_hovered = true;
            _notify(_hover_chain[k], PaxEventType.PointerEntered, pointer_x, pointer_y);
        }
    }

    /// @ignore 
    /// @param {Struct.PaxWidget} widget
    /// @param {Real} point_x
    /// @param {Real} point_y
    /// @returns {Struct.PaxWidget}
    static _find_hit = function(widget, point_x, point_y) {
        if (!widget.visible) return undefined;

        var transform = widget._transform;
        if (transform != undefined) {
            point_x -= transform.x;
            point_y -= transform.y;
        }

        var can_descend = !widget.clips_children
            || _contains(widget.content_bounds, point_x, point_y);

        if (can_descend) {
            var children = widget.children;
            for (var i = array_length(children) - 1; i >= 0; i--) {
                var hit = _find_hit(children[i], point_x, point_y);
                if (hit != undefined) return hit;
            }
        }

        if (widget.pointer_filter == PaxPointerFilter.Ignore) return undefined;
        return widget._hit_test(point_x, point_y) ? widget : undefined;
    }

    /// @ignore
    /// @param {Real} pointer_x
    /// @param {Real} pointer_y
    static _process_press = function(pointer_x, pointer_y) {
        if (_active_button != mb_none) return;

        var button = _pressed_button();
        if (button == mb_none) return;
        if (array_length(_hover_chain) == 0) return;

        _active_button = button;
        _press_x = pointer_x;
        _press_y = pointer_y;
        var count = array_length(_hover_chain);
        array_resize(_active_chain, count);
        array_copy(_active_chain, 0, _hover_chain, 0, count);

        _emit_pointer(_active_chain, PaxEventType.PointerPressed, pointer_x, pointer_y, 0, 0, 0);
        _focus_pressed();
    }

    /// @ignore 
    static _focus_pressed = function() {
        for (var i = 0; i < array_length(_active_chain); i++) {
            var widget = _active_chain[i];
            if (widget.focus_mode != PaxFocusMode.None && widget.enabled) {
                pax_focus().focus(widget);
                return;
            }
        }
        pax_focus().unfocus();
    }

    /// @ignore
    /// @param {Real} pointer_x
    /// @param {Real} pointer_y
    /// @param {Real} delta_x
    /// @param {Real} delta_y
    static _process_move = function(pointer_x, pointer_y, delta_x, delta_y) {
        if (delta_x == 0 && delta_y == 0) return;

        var chain = _active_button != mb_none ? _active_chain : _hover_chain;
        _emit_pointer(chain, PaxEventType.PointerMoved, pointer_x, pointer_y, delta_x, delta_y, 0);
    }

    /// @ignore
    /// @param {Real} pointer_x
    /// @param {Real} pointer_y
    static _process_release = function(pointer_x, pointer_y) {
        if (_active_button == mb_none) return;
        if (!mouse_check_button_released(_active_button)) return;

        _emit_pointer(_active_chain, PaxEventType.PointerReleased, pointer_x, pointer_y, 0, 0, 0);
        _active_button = mb_none;
        array_resize(_active_chain, 0);
    }

    /// @ignore
    /// @param {Real} pointer_x
    /// @param {Real} pointer_y
    static _process_scroll = function(pointer_x, pointer_y) {
        var steps = (mouse_wheel_down() ? 1 : 0) - (mouse_wheel_up() ? 1 : 0);
        if (steps == 0) return;

        _emit_pointer(_hover_chain, PaxEventType.Scroll, pointer_x, pointer_y, 0, 0, steps);
    }

    /// @ignore 
    /// @param {Struct.PaxWidget} root
    static _process_keys = function(root) {
        var pressed = keyboard_check_pressed(vk_anykey);
        var released = keyboard_check_released(vk_anykey);
        if (!pressed && !released) return;

        var focus = pax_focus();
        if (focus.focused != undefined && focus.focused.is_destroyed())
            focus.focused = undefined;

        _build_chain(focus.focused, _focus_chain);

        if (pressed) {
            _emit_key(PaxEventType.KeyPressed);
            if (_key_event.consumed) {
                // a claimed arrow suppresses held navigation until released
                if (_is_arrow(keyboard_lastkey)) _nav_suppressed = true;
            } else {
                _process_tab(root);
            }
        }
        
        if (released) _emit_key(PaxEventType.KeyReleased);
    }

    /// @ignore 
    /// @param {Struct.PaxWidget} root
    static _process_tab = function(root) {
        if (!keyboard_check_pressed(vk_tab)) return;

        var focus = pax_focus();
        if (keyboard_check(vk_shift)) focus.focus_prev(root);
        else focus.focus_next(root);
    }

    /// @ignore
    /// @param {Struct.PaxWidget} root
    static _process_nav = function(root) {
        var dir_x = 0;
        var dir_y = 0;

        var arrows_held = keyboard_check(vk_left) || keyboard_check(vk_right)
            || keyboard_check(vk_up) || keyboard_check(vk_down);
        if (!arrows_held) _nav_suppressed = false;

        if (arrows_held && !_nav_suppressed) {
            dir_x = (keyboard_check(vk_right) ? 1 : 0) - (keyboard_check(vk_left) ? 1 : 0);
            dir_y = (keyboard_check(vk_down) ? 1 : 0) - (keyboard_check(vk_up) ? 1 : 0);
        }

        if (gamepad_device >= 0 && gamepad_is_connected(gamepad_device)) {
            if (dir_x == 0 && dir_y == 0) {
                dir_x = (gamepad_button_check(gamepad_device, gp_padr) ? 1 : 0)
                      - (gamepad_button_check(gamepad_device, gp_padl) ? 1 : 0);
                dir_y = (gamepad_button_check(gamepad_device, gp_padd) ? 1 : 0)
                      - (gamepad_button_check(gamepad_device, gp_padu) ? 1 : 0);
            }
            if (dir_x == 0 && dir_y == 0) {
                var axis_x = gamepad_axis_value(gamepad_device, gp_axislh);
                var axis_y = gamepad_axis_value(gamepad_device, gp_axislv);
                if (abs(axis_x) > stick_deadzone) dir_x = sign(axis_x);
                if (abs(axis_y) > stick_deadzone) dir_y = sign(axis_y);
            }

            if (gamepad_button_check_pressed(gamepad_device, gp_face1))
                _emit_accept();
        }

        _process_nav_direction(root, dir_x, dir_y);
    }

    /// @ignore
    /// @param {Struct.PaxWidget} root
    /// @param {Real} dir_x
    /// @param {Real} dir_y
    static _process_nav_direction = function(root, dir_x, dir_y) {
        if (dir_x == 0 && dir_y == 0) {
            _nav_held = false;
            return;
        }

        var changed = !_nav_held || dir_x != _nav_dir_x || dir_y != _nav_dir_y;
        if (changed) {
            _nav_next_repeat = current_time + nav_repeat_delay;
        } else {
            if (current_time < _nav_next_repeat) return;
            _nav_next_repeat = current_time + nav_repeat_interval;
        }

        _nav_held = true;
        _nav_dir_x = dir_x;
        _nav_dir_y = dir_y;
        pax_focus().focus_direction(root, dir_x, dir_y);
    }

    /// @ignore
    static _emit_accept = function() {
        var focus = pax_focus();
        if (focus.focused == undefined) return;
        if (focus.focused.is_destroyed()) {
            focus.focused = undefined;
            return;
        }

        _build_chain(focus.focused, _focus_chain);
        _key_event.reset(PaxEventType.Accept);
        _key_event.key = vk_nokey;
        _key_event.char = "";
        _bubble_key();
    }

    /// @ignore 
    /// @param {Enum.PaxEventType} type
    static _emit_key = function(type) {
        _key_event.reset(type);
        _key_event.key = keyboard_lastkey;
        _key_event.char = keyboard_lastchar;
        _bubble_key();
    }

    /// @ignore 
    static _bubble_key = function() {
        for (var i = 0; i < array_length(_focus_chain); i++) {
            var widget = _focus_chain[i];
            if (widget.enabled) widget._on_event(_key_event);
            if (_key_event.consumed) return;
        }
    }

    /// @ignore
    /// @param {Constant.VirtualKey} key
    /// @returns {Bool}
    static _is_arrow = function(key) {
        return key == vk_left || key == vk_right || key == vk_up || key == vk_down;
    }

    /// @ignore 
    /// @param {Struct.PaxWidget} widget
    /// @param {Array<Struct.PaxWidget>} chain
    static _build_chain = function(widget, chain) {
        array_resize(chain, 0);
        while (widget != undefined) {
            array_push(chain, widget);
            widget = widget.parent;
        }
    }

    /// @ignore 
    /// @param {Array<Struct.PaxWidget>} chain
    /// @param {Enum.PaxEventType} type
    /// @param {Real} pointer_x
    /// @param {Real} pointer_y
    /// @param {Real} delta_x
    /// @param {Real} delta_y
    /// @param {Real} scroll
    static _emit_pointer = function(chain, type, pointer_x, pointer_y, delta_x, delta_y, scroll) {
        _pointer_event.reset(type);
        _pointer_event.x = pointer_x;
        _pointer_event.y = pointer_y;
        _pointer_event.press_x = _press_x;
        _pointer_event.press_y = _press_y;
        _pointer_event.button = _active_button;
        _pointer_event.delta_x = delta_x;
        _pointer_event.delta_y = delta_y;
        _pointer_event.scroll = scroll;

        for (var i = 0; i < array_length(chain); i++) {
            var widget = chain[i];
            var filter = widget.pointer_filter;
            if (filter == PaxPointerFilter.Ignore) continue;
            if (widget.enabled) widget._on_event(_pointer_event);
            if (_pointer_event.stolen) {
                _pointer_event.stolen = false;
                steal(widget);
                return;
            }
            if (_pointer_event.consumed || filter == PaxPointerFilter.Stop) return;
        }
    }

    /// @ignore 
    /// @param {Struct.PaxWidget} widget
    /// @param {Enum.PaxEventType} type
    /// @param {Real} pointer_x
    /// @param {Real} pointer_y
    static _notify = function(widget, type, pointer_x, pointer_y) {
        if (!widget.enabled || widget.pointer_filter == PaxPointerFilter.Ignore) return;

        _pointer_event.reset(type);
        _pointer_event.x = pointer_x;
        _pointer_event.y = pointer_y;
        _pointer_event.press_x = 0;
        _pointer_event.press_y = 0;
        _pointer_event.button = mb_none;
        _pointer_event.delta_x = 0;
        _pointer_event.delta_y = 0;
        _pointer_event.scroll = 0;
        widget._on_event(_pointer_event);
    }

    /// @ignore 
    static _cancel_gesture = function() {
        if (_active_button == mb_none) return;

        _pointer_event.reset(PaxEventType.PointerCancelled);
        _pointer_event.x = _last_x;
        _pointer_event.y = _last_y;
        _pointer_event.button = _active_button;
        _pointer_event.delta_x = 0;
        _pointer_event.delta_y = 0;
        _pointer_event.scroll = 0;

        for (var i = 0; i < array_length(_active_chain); i++) {
            var widget = _active_chain[i];
            if (widget.enabled && widget.pointer_filter != PaxPointerFilter.Ignore)
                widget._on_event(_pointer_event);
            _pointer_event.consumed = false;
        }

        _active_button = mb_none;
        array_resize(_active_chain, 0);
    }

    /// @ignore 
    static _clear_hover = function() {
        for (var i = 0; i < array_length(_hover_chain); i++) {
            _hover_chain[i].is_hovered = false;
            _notify(_hover_chain[i], PaxEventType.PointerExited, _last_x, _last_y);
        }
        array_resize(_hover_chain, 0);
    }

    /// @ignore
    /// @returns {Constant.MouseButton}
    static _pressed_button = function() {
        for (var i = 0; i < array_length(mouse_buttons); i++) {
            var button = mouse_buttons[i];
            if (mouse_check_button_pressed(button)) return button;
        }
        return mb_none;
    }

    /// @ignore
    /// @param {Struct.PaxRect} rect
    /// @param {Real} point_x
    /// @param {Real} point_y
    /// @returns {Bool}
    static _contains = function(rect, point_x, point_y) {
        return point_x >= rect.x && point_y >= rect.y
            && point_x < rect.x + rect.width && point_y < rect.y + rect.height;
    }
}