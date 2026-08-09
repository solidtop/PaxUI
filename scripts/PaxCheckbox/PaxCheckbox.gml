/// @desc A checkbox that toggles between checked and unchecked.
function PaxCheckbox() : PaxCheckable() constructor {
    /// @ignore
    _box_transition = undefined;
    /// @ignore
    _check_transition = undefined;

    size(24, 24);

    /// @desc [Override] Uses a per-state style set in place of the theme's. The set is linked, not copied.
    /// @param {Struct.PaxCheckboxStyles} preset_styles
    /// @returns {Struct.PaxCheckbox}
    static styled = function(preset_styles) {
        styles = preset_styles;
        return self;
    }

    /// @ignore [Override] Draws the box, and the check mark when checked.
    /// @param {Struct.PaxDrawContext} ctx
    static _draw = function(ctx) {
        var checkbox_styles = _get_styles();
        var box = _resolve_style(_box_target_style(checkbox_styles), _box_transition);

        if (box.sprite != undefined) 
            ctx.sprite(box.sprite, box.subimg,
                bounds.x, bounds.y, bounds.width, bounds.height, box.colour);

        if (!_checked) return;

        var check_style = _resolve_style(checkbox_styles.check, _check_transition);
        if (check_style.sprite == undefined) return;

        var inset = checkbox_styles.check_inset;
        ctx.sprite(check_style.sprite, check_style.subimg,
            bounds.x + inset, bounds.y + inset,
            max(0, bounds.width - inset * 2), max(0, bounds.height - inset * 2),
            check_style.colour);
    }

    /// @ignore [Override] Advances the box and check mark transitions.
    /// @param {Real} dt
    static _update_transitions = function(dt) {
        if (_transition == undefined) return;
        _transition.update(_get_target_style(), dt);

        var checkbox_styles = _get_styles();
        _box_transition = _part_transition(_box_transition);
        _check_transition = _part_transition(_check_transition);

        _box_transition.update(_box_target_style(checkbox_styles), dt);
        _check_transition.update(checkbox_styles.check, dt);
    }

    /// @ignore
    /// @param {Struct.PaxCheckboxStyles} checkbox_styles
    /// @returns {Struct.PaxStyle}
    static _box_target_style = function(checkbox_styles) {
        if (!enabled) return checkbox_styles.box_disabled;
        if (_checked) return is_hovered ? checkbox_styles.box_checked_hovered : checkbox_styles.box_checked;
        if (is_hovered) return checkbox_styles.box_hovered;
        if (is_focused) return checkbox_styles.box_focused;
        return checkbox_styles.box;
    }

    /// @ignore
    /// @returns {Struct.PaxCheckboxStyles}
    static _get_styles = function() {
        return styles ?? pax_theme().checkbox;
    }
}
