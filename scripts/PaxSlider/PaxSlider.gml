/// @desc A horizontal slider. 
function PaxSlider() : PaxWidget() constructor {
    /// @ignore
    _value = 0;
    /// @ignore
    _min_value = 0;
    /// @ignore
    _max_value = 1;
    /// @ignore 
    _step = 0;
    /// @ignore
    _dragging = false;
    /// @ignore
    _track_transition = undefined;
    /// @ignore
    _fill_transition = undefined;
    /// @ignore
    _handle_transition = undefined;
    
    styles = undefined;
    focus_mode = PaxFocusMode.All;
    value_changed = new PaxSignal();
    
    height(80);

    /// @desc Sets the value range and re-clamps the current value.
    /// @param {Real} min_value
    /// @param {Real} max_value
    /// @returns {Struct.PaxSlider}
    static range = function(min_value, max_value) {
        _min_value = min_value;
        _max_value = max_value;
        _apply(_value);
        return self;
    }

    /// @desc Sets the value, clamped to the range.
    /// @param {Real} new_value
    /// @returns {Struct.PaxSlider}
    static value = function(new_value) {
        _apply(new_value);
        return self;
    }

    /// @desc Sets the arrow-key nudge amount. 0 uses 5% of the range.
    /// @param {Real} amount
    /// @returns {Struct.PaxSlider}
    static step = function(amount) {
        _step = amount;
        return self;
    }

    /// @desc Returns the current value.
    /// @returns {Real}
    static get_value = function() {
        return _value;
    }

    /// @desc Connects a handler to value_changed.
    /// @param {Function} handler
    /// @returns {Struct.PaxSlider}
    static on_change = function(handler) {
        value_changed.connect(handler);
        return self;
    }

    /// @desc Uses a per-part style set in place of the theme's. The set is linked, not copied.
    /// @param {Struct.PaxSliderStyles} preset_styles
    /// @returns {Struct.PaxSlider}
    static styled = function(preset_styles) {
        styles = preset_styles;
        return self;
    }

    /// @ignore [Override] Press/drag sets the value; arrows nudge when focused.
    /// @param {Struct.PaxEvent} event
    static _on_event = function(event) {
        switch (event.type) {
            case PaxEventType.PointerPressed:
                if (event.button != mb_left) break;
                _dragging = true;
                _apply_from_pointer(event.x);
                event.consume();
                break;
            case PaxEventType.PointerMoved:
                if (!_dragging) break;
                _apply_from_pointer(event.x);
                event.consume();
                break;
            case PaxEventType.PointerReleased:
                if (!_dragging) break;
                _dragging = false;
                event.consume();
                break;
            case PaxEventType.PointerCancelled:
                _dragging = false;
                break;
            case PaxEventType.KeyPressed:
                var nudge_amount = _step > 0 ? _step : (_max_value - _min_value) * 0.05;
                if (event.key == vk_left || event.key == vk_down) {
                    _apply(_value - nudge_amount);
                    event.consume();
                } else if (event.key == vk_right || event.key == vk_up) {
                    _apply(_value + nudge_amount);
                    event.consume();
                }
                break;
        }
    }

    /// @ignore [Override] Draws the track, the filled portion, and the handle.
    /// @param {Struct.PaxDrawContext} ctx
    static _draw = function(ctx) {
        var background = _get_active_style();
        if (background.sprite != undefined) {
            ctx.sprite(background.sprite, background.subimg,
                bounds.x, bounds.y, bounds.width, bounds.height, background.colour);
        }

        var styles = _get_styles();
        var track = _resolve_style(styles.track, _track_transition);
        var fill = _resolve_style(styles.fill, _fill_transition);
        var handle = _resolve_style(_handle_target_style(styles), _handle_transition);

        var handle_size = styles.handle_size;
        var track_height = styles.track_height;
        var fraction = _fraction();
        var handle_center_x = bounds.x + handle_size * 0.5 + fraction * (bounds.width - handle_size);
        var track_top = bounds.y + (bounds.height - track_height) * 0.5;

        ctx.sprite(track.sprite, track.subimg,
            bounds.x, track_top, bounds.width, track_height, track.colour);

        ctx.sprite(fill.sprite, fill.subimg,
            bounds.x, track_top, handle_center_x - bounds.x, track_height, fill.colour);

        var handle_x = handle_center_x - handle_size * 0.5;
        var handle_y = bounds.y + (bounds.height - handle_size) * 0.5;
        
        ctx.sprite(handle.sprite, handle.subimg,
            handle_x, handle_y, handle_size, handle_size, handle.colour);
    }

    /// @ignore [Override] Advances the track, fill, and handle transitions.
    /// @param {Real} dt
    static _update_transitions = function(dt) {
        if (_transition == undefined) return;
        _transition.update(_get_target_style(), dt);

        var styles = _get_styles();
        _track_transition = _part_transition(_track_transition);
        _fill_transition = _part_transition(_fill_transition);
        _handle_transition = _part_transition(_handle_transition);

        _track_transition.update(styles.track, dt);
        _fill_transition.update(styles.fill, dt);
        _handle_transition.update(_handle_target_style(styles), dt);
    }

    /// @ignore 
    /// @param {Struct.PaxSliderStyles} styles
    /// @returns {Struct.PaxStyle}
    static _handle_target_style = function(styles) {
        if (is_hovered || _dragging) return styles.handle_hovered;
        if (is_focused) return styles.handle_focused;
        return styles.handle;
    }

    /// @ignore
    /// @returns {Struct.PaxSliderStyles}
    static _get_styles = function() {
        return styles ?? pax_theme().slider;
    }

    /// @ignore
    /// @param {Real} new_value
    static _apply = function(new_value) {
        var clamped_value = clamp(new_value, _min_value, _max_value);
        if (clamped_value == _value) return;
        _value = clamped_value;
        value_changed.emit(_value);
    }

    /// @ignore 
    /// @returns {Real}
    static _fraction = function() {
        if (_max_value == _min_value) return 0;
        return (_value - _min_value) / (_max_value - _min_value);
    }

    /// @ignore 
    /// @param {Real} pointer_x
    static _apply_from_pointer = function(pointer_x) {
        var handle_size = _get_styles().handle_size;
        var usable_width = max(1, bounds.width - handle_size);
        var fraction = clamp((pointer_x - bounds.x - handle_size * 0.5) / usable_width, 0, 1);
        _apply(_min_value + fraction * (_max_value - _min_value));
    }
}
