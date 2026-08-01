/// @desc A scrollable viewport. 
function PaxScrollView() : PaxWidget() constructor {
    /// @ignore
    _scroll_speed = 80;
    /// @ignore
    _smoothing = 18;
    /// @ignore
    _friction = 5;
    /// @ignore
    _min_velocity = 0.5;
    /// @ignore
    _overscroll = 0.4;
    /// @ignore
    _spring_back = 80;
    /// @ignore
    _drag_enabled = true;
    /// @ignore
    _drag_threshold = 10;

    /// @ignore
    _content = new PaxWidget().shrink(0);

    /// @ignore
    _target_x = 0;
    /// @ignore
    _target_y = 0;
    /// @ignore
    _raw_x = 0;
    /// @ignore
    _raw_y = 0;
    /// @ignore
    _dragging = false;
    /// @ignore
    _sample_x = 0;
    /// @ignore
    _sample_y = 0;
    /// @ignore
    _velocity_x = 0;
    /// @ignore
    _velocity_y = 0;
    
    clips_children = true;
    scroll_x = 0;
    scroll_y = 0;
    
    scrolled = new PaxSignal();

    static _add_content = PaxWidget.add;
    _add_content(_content);

    /// @desc Enables or disables drag scrolling (wheel scrolling is unaffected).
    /// @param {Bool} value
    /// @returns {Struct.PaxScrollView}
    static draggable = function(value = true) {
        _drag_enabled = value;
        return self;
    }

    /// @desc Connects a handler to the scrolled signal.
    /// @param {Function} handler
    /// @returns {Struct.PaxScrollView}
    static on_scrolled = function(handler) {
        scrolled.connect(handler);
        return self;
    }

    /// @desc Adds a child widget.
    /// @param {Struct.PaxWidget} child
    /// @returns {Struct.PaxScrollView}
    static add = function(child) { _content.add(child); return self; }

    /// @desc Removes a child widget without destroying it.
    /// @param {Struct.PaxWidget} child
    /// @returns {Struct.PaxScrollView}
    static remove = function(child) { _content.remove(child); return self; }

    /// @desc Sets the spacing between children.
    /// @param {Real} pixels
    /// @returns {Struct.PaxScrollView}
    static gap = function(pixels) { _content.gap(pixels); return self; }

    /// @desc Lays out content's children horizontally.
    /// @returns {Struct.PaxScrollView}
    static row = function() {
        _layout.set_direction(PaxDirection.Row);
        _content.row();
        return self;
    }

    /// @desc Lays out content's children vertically.
    /// @returns {Struct.PaxScrollView}
    static column = function() {
        _layout.set_direction(PaxDirection.Column);
        _content.column();
        return self;
    }

    /// @desc Enables wrapping of children onto multiple lines.
    /// @returns {Struct.PaxScrollView}
    static wrap = function() { 
        _layout.set_wrap(PaxWrap.Wrap);
        _content.wrap(); 
        return self; 
    }

    /// @desc Sets main-axis distribution of children.
    /// @param {Enum.PaxJustify} value
    /// @returns {Struct.PaxScrollView}
    static justify = function(value) { _content.justify(value); return self; }

    /// @desc Sets cross-axis aligment of children.
    /// @param {Enum.PaxAlign} value
    /// @returns {Struct.PaxScrollView}
    static align = function(value) { _content.align(value); return self; }

    /// @desc Centers children on both axis.
    /// @returns {Struct.PaxScrollView}
    static center = function() { _content.center(); return self; }

    /// @desc Returns the maximum horizontal scroll offset.
    /// @returns {Real}
    static max_scroll_x = function() {
        return max(0, _content.bounds.width - content_bounds.width);
    }

    /// @desc Returns the maximum vertical scroll offset.
    /// @returns {Real}
    static max_scroll_y = function() {
        return max(0, _content.bounds.height - content_bounds.height);
    }

    /// @desc Instantly sets the scroll position, clamped to content bounds.
    /// @param {Real} sx
    /// @param {Real} sy
    /// @returns {Struct.PaxScrollView}
    static scroll_to = function(sx, sy) {
        _target_x = clamp(sx, 0, max_scroll_x());
        _target_y = clamp(sy, 0, max_scroll_y());
        _apply_scroll(_target_x, _target_y);
        return self;
    }

    /// @desc Instantly scrolls by a relative amount.
    /// @param {Real} dx
    /// @param {Real} dy
    /// @returns {Struct.PaxScrollView}
    static scroll_by = function(dx, dy) {
        return scroll_to(scroll_x + dx, scroll_y + dy);
    }

    /// @desc Sets the smooth-scroll target; position eases toward it.
    /// @param {Real} sx
    /// @param {Real} sy
    /// @returns {Struct.PaxScrollView}
    static smooth_scroll_to = function(sx, sy) {
        _target_x = clamp(sx, 0, max_scroll_x());
        _target_y = clamp(sy, 0, max_scroll_y());
        return self;
    }

    /// @desc Adjusts the smooth-scroll target by a relative amount.
    /// @param {Real} dx
    /// @param {Real} dy
    /// @returns {Struct.PaxScrollView}
    static smooth_scroll_by = function(dx, dy) {
        return smooth_scroll_to(_target_x + dx, _target_y + dy);
    }

    /// @desc Scrolls smoothly so the given descendant widget is visible within the viewport.
    /// @param {Struct.PaxWidget} widget
    /// @returns {Struct.PaxScrollView}
    static scroll_into_view = function(widget) {
        var ex = widget.bounds.x - _content.bounds.x;
        var ey = widget.bounds.y - _content.bounds.y;
        var ew = widget.bounds.width;
        var eh = widget.bounds.height;

        var view_w = content_bounds.width;
        var view_h = content_bounds.height;

        var new_x = _target_x;
        var new_y = _target_y;

        if (ey < _target_y)
            new_y = ey;
        else if (ey + eh > _target_y + view_h)
            new_y = ey + eh - view_h;

        if (ex < _target_x)
            new_x = ex;
        else if (ex + ew > _target_x + view_w)
            new_x = ex + ew - view_w;

        smooth_scroll_to(new_x, new_y);
        return self;
    }

    /// @ignore [Override] Advances drag tracking, momentum and smoothing.
    /// @param {Real} dt
    static _update = function(dt) {
        if (_dragging) {
            _target_x = _damp_to_bounds(_raw_x, max_scroll_x(), content_bounds.width);
            _target_y = _damp_to_bounds(_raw_y, max_scroll_y(), content_bounds.height);

            _velocity_x = lerp(_velocity_x, (_sample_x - _raw_x) / dt, 0.5);
            _velocity_y = lerp(_velocity_y, (_sample_y - _raw_y) / dt, 0.5);
            _sample_x = _raw_x;
            _sample_y = _raw_y;

            _apply_scroll(_target_x, _target_y);
            return;
        }

        _update_momentum(dt);
        _update_smoothing(dt);
    }

    /// @ignore [Override] Reacts to pointer events bubbling through the view.
    /// @param {Struct.PaxEvent} event
    static _on_event = function(event) {
        switch (event.type) {
            case PaxEventType.PointerPressed:
                // Catch: pressing anywhere in the view halts motion. Reaches
                // us only when no child consumed the press; not consumed here.
                _velocity_x = 0;
                _velocity_y = 0;
                _target_x = clamp(scroll_x, 0, max_scroll_x());
                _target_y = clamp(scroll_y, 0, max_scroll_y());
                break;

            case PaxEventType.PointerMoved:
                if (_dragging) {
                    _raw_x = max_scroll_x() > 0 ? _raw_x - event.delta_x : 0;
                    _raw_y = max_scroll_y() > 0 ? _raw_y - event.delta_y : 0;
                    event.consume();
                    break;
                }

                // Observe gesture moves bubbling past pressed children; once
                // the pointer strays far enough from the press, take over.
                if (!_drag_enabled) break;
                if (event.button == mb_none) break;
                if (max_scroll_x() <= 0 && max_scroll_y() <= 0) break;

                if (point_distance(event.press_x, event.press_y, event.x, event.y) >= _drag_threshold) {
                    _begin_drag();
                    event.steal();
                }
                break;

            case PaxEventType.PointerReleased:
                if (!_dragging) break;
                _end_drag();
                event.consume();
                break;

            case PaxEventType.PointerCancelled:
                // Our own gesture was stolen or the window lost focus.
                if (_dragging) _end_drag();
                break;

            case PaxEventType.Scroll:
                _velocity_x = 0;
                _velocity_y = 0;
                var amount = event.scroll * _scroll_speed;
                if (max_scroll_x() > 0)
                    smooth_scroll_by(amount, 0);
                else if (max_scroll_y() > 0)
                    smooth_scroll_by(0, amount);

                event.consume();
                break;
        }
    }

    /// @ignore
    static _begin_drag = function() {
        _dragging = true;
        _raw_x = scroll_x;
        _raw_y = scroll_y;
        _sample_x = _raw_x;
        _sample_y = _raw_y;
        _velocity_x = 0;
        _velocity_y = 0;
    }

    /// @ignore
    static _end_drag = function() {
        _dragging = false;
        _target_x = clamp(_raw_x, 0, max_scroll_x());
        _target_y = clamp(_raw_y, 0, max_scroll_y());
    }

    /// @ignore
    /// @param {Real} dt
    static _update_momentum = function(dt) {
        var max_x = max_scroll_x();
        var max_y = max_scroll_y();

        if (max_x <= 0) _velocity_x = 0;
        if (max_y <= 0) _velocity_y = 0;

        if (abs(_velocity_x) <= _min_velocity && abs(_velocity_y) <= _min_velocity) {
            _velocity_x = 0;
            _velocity_y = 0;
            return;
        }

        _target_x -= _velocity_x * dt;
        _target_y -= _velocity_y * dt;

        _velocity_x = _decay(_velocity_x, _friction, dt);
        _velocity_y = _decay(_velocity_y, _friction, dt);

        // momentum dies fast once past an edge
        if (_target_x < 0 || _target_x > max_x) _velocity_x = _decay(_velocity_x, _friction, dt);
        if (_target_y < 0 || _target_y > max_y) _velocity_y = _decay(_velocity_y, _friction, dt);
    }

    /// @ignore
    /// @param {Real} dt
    static _update_smoothing = function(dt) {
        _target_x = _ease_to_bounds(_target_x, 0, max_scroll_x(), dt);
        _target_y = _ease_to_bounds(_target_y, 0, max_scroll_y(), dt);

        var nx = _damp(scroll_x, _target_x, _smoothing, dt);
        var ny = _damp(scroll_y, _target_y, _smoothing, dt);

        if (abs(nx - _target_x) < 0.1) nx = _target_x;
        if (abs(ny - _target_y) < 0.1) ny = _target_y;
        _apply_scroll(nx, ny);
    }

    /// @ignore
    /// @param {Real} sx
    /// @param {Real} sy
    static _apply_scroll = function(sx, sy) {
        if (sx == scroll_x && sy == scroll_y) return;
        scroll_x = sx;
        scroll_y = sy;
        _content.translate(-scroll_x, -scroll_y);
        scrolled.emit(self);
    }

    /// @ignore
    /// @param {Real} distance
    /// @param {Real} dimension
    /// @returns {Real}
    static _resist = function(distance, dimension) {
        var s = sign(distance);
        var d = abs(distance);
        return s * (1 - 1 / (d * _overscroll / dimension + 1)) * dimension;
    }

    /// @ignore
    /// @param {Real} pos
    /// @param {Real} max_scroll
    /// @param {Real} dimension
    /// @returns {Real}
    static _damp_to_bounds = function(pos, max_scroll, dimension) {
        if (pos < 0) return _resist(pos, dimension);
        if (pos > max_scroll) return max_scroll + _resist(pos - max_scroll, dimension);
        return pos;
    }

    /// @ignore
    /// @param {Real} value
    /// @param {Real} lo
    /// @param {Real} hi
    /// @param {Real} dt
    /// @returns {Real}
    static _ease_to_bounds = function(value, lo, hi, dt) {
        if (value < lo) return _damp(value, lo, _spring_back, dt);
        if (value > hi) return _damp(value, hi, _spring_back, dt);
        return value;
    }

    /// @ignore
    /// @param {Real} value
    /// @param {Real} target
    /// @param {Real} rate
    /// @param {Real} dt
    /// @returns {Real}
    static _damp = function(value, target, rate, dt) {
        return lerp(value, target, 1 - exp(-rate * dt));
    }

    /// @ignore
    /// @param {Real} value
    /// @param {Real} rate
    /// @param {Real} dt
    /// @returns {Real}
    static _decay = function(value, rate, dt) {
        return value * exp(-rate * dt);
    }
}
