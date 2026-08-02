/// @desc A radio button; only one radio in a group can be selected.
function PaxRadio() : PaxCheckable() constructor {
    /// @ignore
    _group = undefined;
    /// @ignore
    _indicator_transition = undefined;
    /// @ignore
    _dot_transition = undefined;

    size(24, 24);

    /// @desc Joins a group, leaving any group already joined.
    /// @param {Struct.PaxRadioGroup} radio_group
    /// @returns {Struct.PaxRadio}
    static group = function(radio_group) {
        if (_group != undefined) _group._unregister(self);
        _group = radio_group;
        if (_group != undefined) _group._register(self);
        return self;
    }

    /// @desc [Override] Uses a per-state style set in place of the theme's. The set is linked, not copied.
    /// @param {Struct.PaxRadioStyles} preset_styles
    /// @returns {Struct.PaxRadio}
    static styled = function(preset_styles) {
        styles = preset_styles;
        return self;
    }

    /// @ignore [Override] Activating always selects; clicking a selected radio keeps it selected.
    static _activate = function() {
        _apply(true);
    }

    /// @ignore [Override] Hands the selection to the group, which clears the others.
    static _on_checked_changed = function() {
        if (_checked && _group != undefined) _group._select(self);
    }

    /// @ignore [Override] Draws the indicator, and the dot when selected.
    /// @param {Struct.PaxDrawContext} ctx
    static _draw = function(ctx) {
        var radio_styles = _get_styles();
        var indicator = _resolve_style(_indicator_target_style(radio_styles), _indicator_transition);

        if (indicator.sprite != undefined) {
            ctx.sprite(indicator.sprite, indicator.subimg,
                bounds.x, bounds.y, bounds.width, bounds.height, indicator.colour);
        }

        if (!_checked) return;

        var dot = _resolve_style(radio_styles.dot, _dot_transition);
        if (dot.sprite == undefined) return;

        var inset = radio_styles.dot_inset;
        ctx.sprite(dot.sprite, dot.subimg,
            bounds.x + inset, bounds.y + inset,
            max(0, bounds.width - inset * 2), max(0, bounds.height - inset * 2),
            dot.colour);
    }

    /// @ignore [Override] Advances the indicator and dot transitions.
    /// @param {Real} dt
    static _update_transitions = function(dt) {
        if (_transition == undefined) return;
        _transition.update(_get_target_style(), dt);

        var radio_styles = _get_styles();
        _indicator_transition = _part_transition(_indicator_transition);
        _dot_transition = _part_transition(_dot_transition);

        _indicator_transition.update(_indicator_target_style(radio_styles), dt);
        _dot_transition.update(radio_styles.dot, dt);
    }

    /// @ignore
    /// @param {Struct.PaxRadioStyles} radio_styles
    /// @returns {Struct.PaxStyle}
    static _indicator_target_style = function(radio_styles) {
        if (!enabled) return radio_styles.indicator_disabled;
        if (_checked) return is_hovered ? radio_styles.indicator_checked_hovered : radio_styles.indicator_checked;
        if (is_hovered) return radio_styles.indicator_hovered;
        if (is_focused) return radio_styles.indicator_focused;
        return radio_styles.indicator;
    }

    /// @ignore
    /// @returns {Struct.PaxRadioStyles}
    static _get_styles = function() {
        return styles ?? pax_theme().radio;
    }
}
