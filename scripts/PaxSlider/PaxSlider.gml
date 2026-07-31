/// @desc A horizontal slider. 
function PaxSlider() : PaxWidget() constructor {
    focus_mode = PaxFocusMode.All;
    height(80);

    value_changed = new PaxSignal();

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
    /// @ignore Per-instance PaxSliderStyle override; undefined uses the theme.
    _styles = undefined;

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

    /// @desc Uses a custom style for the track, fill, handle, and their sizes.
    /// @param {Struct.PaxSliderStyle} slider_style
    /// @returns {Struct.PaxSlider}
    static styled_parts = function(slider_style) {
        _styles = slider_style;
        return self;
    }

    /// @ignore Resolves the active slider style (per-instance override, else theme).
    /// @returns {Struct.PaxSliderStyle}
    static _slider_style = function() {
        return _styles ?? pax_theme().slider;
    }

    /// @ignore
    /// @param {Real} new_value
    static _apply = function(new_value) {
        var clamped_value = clamp(new_value, _min_value, _max_value);
        if (clamped_value == _value) return;
        _value = clamped_value;
        value_changed.emit(_value);
    }

    /// @ignore The value as a 0..1 fraction of the range.
    /// @returns {Real}
    static _fraction = function() {
        if (_max_value == _min_value) return 0;
        return (_value - _min_value) / (_max_value - _min_value);
    }

    /// @ignore Maps a pointer x to a value and applies it. The usable track is
    /// inset by half a handle on each side, so the ends reach min and max.
    /// @param {Real} pointer_x
    static _apply_from_pointer = function(pointer_x) {
        var handle_size = _slider_style().handle_size;
        var usable_width = max(1, bounds.width - handle_size);
        var fraction = clamp((pointer_x - bounds.x - handle_size * 0.5) / usable_width, 0, 1);
        _apply(_min_value + fraction * (_max_value - _min_value));
    }

    /// @desc [Override] Press/drag sets the value; arrows nudge when focused.
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

    /// @desc [Override] Draws the track, the filled portion, and the handle.
    /// @param {Struct.PaxDrawContext} ctx
    static _draw = function(ctx) {
        var slider_style = _slider_style();
        var handle_size = slider_style.handle_size;
        var track_height = slider_style.track_height;
        var fraction = _fraction();
        var handle_center_x = bounds.x + handle_size * 0.5 + fraction * (bounds.width - handle_size);

        // track 
        var track_top = bounds.y + (bounds.height - track_height) * 0.5;
        ctx.sprite(slider_style.track.sprite, slider_style.track.subimg,
            bounds.x, track_top, bounds.width, track_height, slider_style.track.colour);

        // fill
        ctx.sprite(slider_style.fill.sprite, slider_style.fill.subimg,
            bounds.x, track_top, handle_center_x - bounds.x, track_height, slider_style.fill.colour);

        // handle 
        var handle_colour = is_focused
            ? merge_colour(slider_style.handle.colour, c_white, 0.4)
            : slider_style.handle.colour;
        var handle_x = handle_center_x - handle_size * 0.5;
        var handle_y = bounds.y + (bounds.height - handle_size) * 0.5;
        ctx.sprite(slider_style.handle.sprite, slider_style.handle.subimg,
            handle_x, handle_y, handle_size, handle_size, handle_colour);
    }
}
