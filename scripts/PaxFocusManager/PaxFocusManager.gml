/// @desc Manages which widget currently holds keyboard focus.
/// Focused widgets receive FocusEntered/FocusExited through _on_event.
function PaxFocusManager() constructor {
    focused = undefined;

    /// @ignore
    _focus_event = new PaxEvent();

    /// @desc Sets focus to the given widget, unfocusing any previous target.
    /// @param {Struct.PaxWidget} widget
    static focus = function(widget) {
        if (widget == focused) return;
        if (widget != undefined && !_can_focus(widget)) return;

        unfocus();

        focused = widget;
        if (focused != undefined) {
            focused.is_focused = true;
            _notify(focused, PaxEventType.FocusEntered);
            _reveal_in_scroll_ancestors(focused);
        }
    }

    /// @desc Clears focus from the current widget, if any.
    static unfocus = function() {
        if (focused == undefined) return;
        focused.is_focused = false;
        _notify(focused, PaxEventType.FocusExited);
        focused = undefined;
    }

    /// @desc Moves focus to the next focusable widget in tree order.
    /// @param {Struct.PaxWidget} root
    static focus_next = function(root) {
        _step_focus(root, 1);
    }

    /// @desc Moves focus to the previous focusable widget in tree order.
    /// @param {Struct.PaxWidget} root
    static focus_prev = function(root) {
        _step_focus(root, -1);
    }

    /// @desc Moves focus to the nearest focusable widget in the given direction
    /// from the currently focused widget.
    /// @param {Struct.PaxWidget} root
    /// @param {Real} dir_x -1 left, +1 right, 0 none
    /// @param {Real} dir_y -1 up, +1 down, 0 none
    static focus_direction = function(root, dir_x, dir_y) {
        var list = _build_focus_order(root);
        var count = array_length(list);
        if (count == 0) return;

        if (focused == undefined) {
            focus(list[0]);
            return;
        }

        var from = focused.bounds;
        var fx = from.x + from.width  * 0.5;
        var fy = from.y + from.height * 0.5;

        var best = undefined;
        var best_score = infinity;

        for (var i = 0; i < count; i++) {
            var candidate = list[i];
            if (candidate == focused) continue;

            var bounds = candidate.bounds;
            var cx = bounds.x + bounds.width  * 0.5;
            var cy = bounds.y + bounds.height * 0.5;

            var to_x = cx - fx;
            var to_y = cy - fy;

            var along = to_x * dir_x + to_y * dir_y;
            if (along <= 0) continue; // not in this direction at all

            // perpendicular offset — how far off-axis the candidate is
            var perp = abs(to_x * dir_y - to_y * dir_x);

            // score: primarily distance along the axis, penalized by drift
            // off-axis. The perp weight makes it prefer straight-ahead targets.
            var _score = along + perp * 2;

            if (_score < best_score) {
                best_score = _score;
                best = candidate;
            }
        }

        if (best != undefined) focus(best);
    }

    /// @param {Struct.PaxWidget} root
    static focus_left = function(root) { focus_direction(root, -1, 0); }
    /// @param {Struct.PaxWidget} root
    static focus_right = function(root) { focus_direction(root, 1, 0); }
    /// @param {Struct.PaxWidget} root
    static focus_up = function(root) { focus_direction(root, 0, -1); }
    /// @param {Struct.PaxWidget} root
    static focus_down = function(root) { focus_direction(root, 0, 1); }

    /// @ignore
    /// @param {Struct.PaxWidget} widget
    /// @returns {Bool}
    static _can_focus = function(widget) {
        return widget.focus_mode != PaxFocusMode.None
            && widget.enabled && widget.visible;
    }

    /// @ignore 
    /// @param {Struct.PaxWidget} widget
    /// @param {Enum.PaxEventType} type
    static _notify = function(widget, type) {
        _focus_event.reset(type);
        widget._on_event(_focus_event);
    }

    /// @ignore
    /// @param {Struct.PaxWidget} root
    /// @param {Real} dir
    static _step_focus = function(root, dir) {
        var list = _build_focus_order(root);
        var count = array_length(list);
        if (count == 0) return;

        var current = -1;
        for (var i = 0; i < count; i++) {
            if (list[i] == focused) { current = i; break; }
        }

        var next;
        if (current == -1) {
            next = (dir > 0) ? 0 : count - 1;
        } else {
            next = (current + dir + count) % count;
        }

        focus(list[next]);
    }

    /// @ignore
    /// @param {Struct.PaxWidget} root
    /// @returns {Array<Struct.PaxWidget>}
    static _build_focus_order = function(root) {
        var entries = [];
        _collect_focusable(root, entries);

        // stable sort: primary key focus_index, tiebreak by tree position
        array_sort(entries, function(a, b) {
            if (a.index != b.index) return a.index - b.index;
            return a.order - b.order; // preserve tree order on ties
        });

        // unwrap to plain widget list
        var result = [];
        for (var i = 0; i < array_length(entries); i++) {
            array_push(result, entries[i].widget);
        }
        return result;
    }

    /// @ignore
    /// @param {Struct.PaxWidget} widget
    /// @param {Array} entries
    static _collect_focusable = function(widget, entries) {
        if (!widget.visible) return;

        // only All participates in keyboard traversal; Click is pointer-only
        if (widget.focus_mode == PaxFocusMode.All && widget.enabled)
            array_push(entries, {
                widget,
                index: widget.focus_index,
                order: array_length(entries)
            });

        var children = widget.children;
        for (var i = 0; i < array_length(children); i++)
        	_collect_focusable(children[i], entries);
    }

    /// @ignore
    /// @param {Struct.PaxWidget} widget
    static _reveal_in_scroll_ancestors = function(widget) {
        var ancestor = widget.parent;
        while (ancestor != undefined) {
            if (is_instanceof(ancestor, PaxScrollView))
                ancestor.scroll_into_view(widget);
            ancestor = ancestor.parent;
        }
    }
}

/// @desc Returns the focus manager singleton.
/// @returns {Struct.PaxFocusManager}
function pax_focus() {
    static manager = new PaxFocusManager();
    return manager;
}
