/// @desc A single-line editable text field. 
function PaxTextInput() : PaxWidget() constructor {
    /// @ignore
    _text = "";
    /// @ignore
    _placeholder = "";
    /// @ignore 
    _caret = 0;
    /// @ignore 
    _anchor = 0;
    /// @ignore
    _scroll_x = 0;
    /// @ignore
    _blink_time = 0;
    /// @ignore 
    _repeat_key_code = vk_nokey;
    /// @ignore 
    _repeat_next = 0;

    text_changed = new PaxSignal();
    submitted = new PaxSignal();

    focus_mode = PaxFocusMode.All;
    styles = undefined;
    is_pressed = false;
    repeat_delay = 400;   
    repeat_interval = 40;  

    height(36);

    /// @desc Sets the text and moves the caret to the end.
    /// @param {String} value
    /// @returns {Struct.PaxTextInput}
    static text = function(value) {
        _text = value;
        _caret = string_length(_text);
        _anchor = _caret;
        return self;
    }

    /// @desc Sets the placeholder shown while empty and unfocused.
    /// @param {String} value
    /// @returns {Struct.PaxTextInput}
    static placeholder = function(value) {
        _placeholder = value;
        return self;
    }

    /// @desc Returns the current text.
    /// @returns {String}
    static get_text = function() {
        return _text;
    }

    /// @desc Uses a custom style set in place of the theme's.
    /// @param {Struct.PaxTextInputStyles} preset_styles
    /// @returns {Struct.PaxTextInput}
    static styled = function(preset_styles) {
        styles = preset_styles;
        return self;
    }

    /// @desc Connects a handler to text_changed.
    /// @param {Function} handler
    /// @returns {Struct.PaxTextInput}
    static on_changed = function(handler) {
        text_changed.connect(handler);
        return self;
    }

    /// @desc Connects a handler to submitted.
    /// @param {Function} handler
    /// @returns {Struct.PaxTextInput}
    static on_submitted = function(handler) {
        submitted.connect(handler);
        return self;
    }
    
    /// @ignore [Override] Handles typed characters, shortcuts, and repeating edit
    /// keys while focused, and advances the caret blink.
    /// @param {Real} dt
    static _update = function(dt) {
        if (!is_focused) return;
        _blink_time += dt;

        if (keyboard_check(vk_control)) {
            keyboard_string = ""; // control combos aren't text
            if (keyboard_check_pressed(ord("A"))) _select_all();
            if (keyboard_check_pressed(ord("C"))) _copy();
            if (keyboard_check_pressed(ord("X"))) _cut();
            if (keyboard_check_pressed(ord("V"))) _paste();
        } else {
            // character input — keyboard_string gives OS key-repeat and layout
            var typed = keyboard_string;
            if (typed != "") {
                keyboard_string = "";
                _insert_printable(typed);
            }
        }

        var extend = keyboard_check(vk_shift);
        if (_key_fires(vk_left)) _caret_left(extend);
        if (_key_fires(vk_right)) _caret_right(extend);
        if (_key_fires(vk_backspace)) _delete_before();
        if (_key_fires(vk_delete)) _delete_after();
        if (keyboard_check_pressed(vk_home)) _set_caret(0, extend);
        if (keyboard_check_pressed(vk_end)) _set_caret(string_length(_text), extend);
    }

    /// @ignore [Override] Pointer places the caret or drags a selection; keys edit.
    /// @param {Struct.PaxEvent} event
    static _on_event = function(event) {
        switch (event.type) {
            case PaxEventType.PointerPressed:
                if (event.button != mb_left) break;
                is_pressed = true;
                _caret_from_x(event.x, keyboard_check(vk_shift)); // shift-click extends
                _reset_blink();
                event.consume();
                break;
            case PaxEventType.PointerMoved:
                if (!is_pressed) break;
                _caret_from_x(event.x, true); // dragging extends the selection
                event.consume();
                break;
            case PaxEventType.PointerReleased:
                is_pressed = false;
                event.consume();
                break;
            case PaxEventType.KeyPressed:
                _handle_key(event);
                break;
            case PaxEventType.FocusEntered:
                keyboard_string = ""; // discard anything typed before focus
                _reset_blink();
                break;
        }
    }
    
    /// @desc [Override] Draws the box, selection highlight, text (or placeholder) and caret, clipped to the text area.
    /// @param {Struct.PaxDrawContext} ctx
    static _draw = function(ctx) {
        var input_styles = _get_styles();
        var box = _box_target_style(input_styles);

        if (box.sprite != undefined) {
            ctx.sprite(box.sprite, box.subimg,
                bounds.x, bounds.y, bounds.width, bounds.height, box.colour);
        }

        var pad = input_styles.padding;
        var text_x = bounds.x + pad;
        var view_width = bounds.width - pad * 2;
        var mid_y = bounds.y + bounds.height * 0.5;
        var inner_top = bounds.y + pad * 0.5;
        var inner_height = bounds.height - pad;
        var draw_x = text_x - _scroll_x;

        // clip drawing to the text area (intersect with the current scissor)
        var prev = gpu_get_scissor();
        var clip_left = max(text_x, prev.x);
        var clip_right = min(text_x + view_width, prev.x + prev.w);
        gpu_set_scissor(clip_left, prev.y, max(0, clip_right - clip_left), prev.h);

        var show_placeholder = (_text == "" && !is_focused);
        if (show_placeholder) {
            var ph = input_styles.placeholder;
            ctx.text(_placeholder, ph.font, draw_x, mid_y, 999999, ph.colour, fa_left, fa_middle);
        } else {
            var ts = input_styles.text;
            draw_set_font(ts.font);

            // selection highlight, behind the text
            if (is_focused && _has_selection()) {
                var start_px = string_width(string_copy(_text, 1, _selection_start()));
                var end_px = string_width(string_copy(_text, 1, _selection_end()));
                ctx.sprite(spr_pax_pixel, 0,
                    draw_x + start_px, inner_top, end_px - start_px, inner_height,
                    input_styles.selection_colour);
            }

            ctx.text(_text, ts.font, draw_x, mid_y, 999999, ts.colour, fa_left, fa_middle);

            if (is_focused && !_has_selection() && _blink_on()) {
                var caret_x = draw_x + string_width(string_copy(_text, 1, _caret));
                ctx.sprite(spr_pax_pixel, 0,
                    caret_x, inner_top, 2, inner_height, input_styles.caret_colour);
            }
        }

        gpu_set_scissor(prev.x, prev.y, prev.w, prev.h);
    }

    /// @ignore 
    /// @param {Struct.PaxEvent} event
    static _handle_key = function(event) {
        switch (event.key) {
            case vk_enter:  submitted.emit(_text); event.consume(); break;
            case vk_escape: pax_focus().unfocus(); event.consume(); break;
            case vk_tab:    break; // let focus navigation move on

            case vk_left:
            case vk_right:
            case vk_backspace:
            case vk_delete:
            case vk_home:
            case vk_end:
                event.consume();
                break;
        }
    }

    /// @ignore
    /// @returns {Bool}
    static _has_selection = function() {
        return _anchor != _caret;
    }

    /// @ignore
    /// @returns {Real}
    static _selection_start = function() {
        return min(_anchor, _caret);
    }

    /// @ignore
    /// @returns {Real}
    static _selection_end = function() {
        return max(_anchor, _caret);
    }

    /// @ignore
    /// @returns {String}
    static _selected_text = function() {
        var start = _selection_start();
        return string_copy(_text, start + 1, _selection_end() - start);
    }

    /// @ignore
    static _select_all = function() {
        _anchor = 0;
        _caret = string_length(_text);
        _reset_blink();
        _ensure_caret_visible();
    }

    /// @ignore 
    /// @param {Real} index
    /// @param {Bool} extend
    static _set_caret = function(index, extend = false) {
        _caret = clamp(index, 0, string_length(_text));
        if (!extend) _anchor = _caret;
        _reset_blink();
        _ensure_caret_visible();
    }

    /// @ignore
    /// @param {Bool} extend
    static _caret_left = function(extend) {
        if (!extend && _has_selection()) _set_caret(_selection_start(), false);
        else _set_caret(_caret - 1, extend);
    }

    /// @ignore
    /// @param {Bool} extend
    static _caret_right = function(extend) {
        if (!extend && _has_selection()) _set_caret(_selection_end(), false);
        else _set_caret(_caret + 1, extend);
    }

    /// @ignore 
    /// @param {Real} pointer_x
    /// @param {Bool} extend
    static _caret_from_x = function(pointer_x, extend = false) {
        var input_styles = _get_styles();
        draw_set_font(input_styles.text.font);

        var target = pointer_x - (bounds.x + input_styles.padding) + _scroll_x;
        var length = string_length(_text);
        var best_index = 0;
        var best_distance = abs(target);

        for (var i = 1; i <= length; i++) {
            var distance = abs(string_width(string_copy(_text, 1, i)) - target);
            if (distance < best_distance) {
                best_distance = distance;
                best_index = i;
            }
        }

        _set_caret(best_index, extend);
    }

    /// @ignore Inserts text, replacing the selection when there is one.
    /// @param {String} str
    static _insert = function(str) {
        if (_has_selection()) {
            var start = _selection_start();
            _remove_range(start, _selection_end());
            _caret = start;
        }

        var tail = string_length(_text) - _caret;
        _text = string_copy(_text, 1, _caret) + str + string_copy(_text, _caret + 1, tail);
        _caret += string_length(str);
        _anchor = _caret;
        _after_edit();
    }

    /// @ignore Inserts only the printable characters of a string at the caret.
    /// @param {String} str
    static _insert_printable = function(str) {
        var clean = "";
        var length = string_length(str);
        for (var i = 1; i <= length; i++) {
            var ch = string_char_at(str, i);
            if (ord(ch) >= 32) clean += ch;
        }
        if (clean != "") _insert(clean);
    }

    /// @ignore Backspace: deletes the selection, else the character before the caret.
    static _delete_before = function() {
        if (_has_selection()) { _delete_selection(); return; }
        if (_caret == 0) return;
        _remove_range(_caret - 1, _caret);
        _caret--;
        _anchor = _caret;
        _after_edit();
    }

    /// @ignore Delete: deletes the selection, else the character after the caret.
    static _delete_after = function() {
        if (_has_selection()) { _delete_selection(); return; }
        if (_caret >= string_length(_text)) return;
        _remove_range(_caret, _caret + 1);
        _after_edit();
    }

    /// @ignore
    static _delete_selection = function() {
        var start = _selection_start();
        _remove_range(start, _selection_end());
        _caret = start;
        _anchor = start;
        _after_edit();
    }

    /// @ignore 
    /// @param {Real} a
    /// @param {Real} b
    static _remove_range = function(a, b) {
        _text = string_copy(_text, 1, a) + string_copy(_text, b + 1, string_length(_text) - b);
    }

    /// @ignore
    static _copy = function() {
        if (_has_selection()) clipboard_set_text(_selected_text());
    }

    /// @ignore
    static _cut = function() {
        if (!_has_selection()) return;
        clipboard_set_text(_selected_text());
        _delete_selection();
    }

    /// @ignore
    static _paste = function() {
        if (clipboard_has_text()) _insert_printable(clipboard_get_text());
    }

    /// @ignore
    static _after_edit = function() {
        _reset_blink();
        _ensure_caret_visible();
        text_changed.emit(_text);
    }

    /// @ignore 
    static _ensure_caret_visible = function() {
        if (bounds.width <= 0) return;

        var input_styles = _get_styles();
        draw_set_font(input_styles.text.font);

        var caret_px = string_width(string_copy(_text, 1, _caret));
        var view_width = bounds.width - input_styles.padding * 2;

        if (caret_px - _scroll_x < 0) _scroll_x = caret_px;
        else if (caret_px - _scroll_x > view_width) _scroll_x = caret_px - view_width;
        _scroll_x = max(0, _scroll_x);
    }

    /// @ignore
    static _reset_blink = function() {
        _blink_time = 0;
    }

    /// @ignore
    /// @returns {Bool}
    static _blink_on = function() {
        return (_blink_time mod 1.0) < 0.5;
    }

    /// @ignore 
    /// @param {Constant.VirtualKey} key
    /// @returns {Bool}
    static _key_fires = function(key) {
        if (keyboard_check_pressed(key)) {
            _repeat_key_code = key;
            _repeat_next = current_time + repeat_delay;
            return true;
        }
        if (_repeat_key_code != key) return false;
        if (!keyboard_check(key)) {
            _repeat_key_code = vk_nokey;
            return false;
        }
        if (current_time >= _repeat_next) {
            _repeat_next = current_time + repeat_interval;
            return true;
        }
        return false;
    }

    /// @ignore
    /// @param {Struct.PaxTextInputStyles} input_styles
    /// @returns {Struct.PaxStyle}
    static _box_target_style = function(input_styles) {
        if (!enabled) return input_styles.box_disabled;
        if (is_focused) return input_styles.box_focused;
        if (is_hovered) return input_styles.box_hovered;
        return input_styles.box;
    }

    /// @ignore
    /// @returns {Struct.PaxTextInputStyles}
    static _get_styles = function() {
        return styles ?? pax_theme().text_input;
    }
}
