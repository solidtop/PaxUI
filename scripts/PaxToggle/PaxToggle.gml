/// @desc A switch whose knob slides between off and on.
function PaxToggle() : PaxCheckable() constructor {
    /// @ignore 
    _knob_fraction = 0;
    /// @ignore 
    _ready = false;
    /// @ignore
    _track_transition = undefined;
    /// @ignore
    _knob_transition = undefined;

    size(56, 30);

    /// @desc [Override] Uses a per-state style set in place of the theme's. The set is linked, not copied.
    /// @param {Struct.PaxToggleStyles} preset_styles
    /// @returns {Struct.PaxToggle}
    static styled = function(preset_styles) {
        styles = preset_styles;
        return self;
    }

    /// @ignore [Override] Marks the toggle ready to animate after its first frame.
    /// @param {Real} dt
    static _update = function(dt) {
        _ready = true;
    }

    /// @ignore [Override] Draws the track, then the knob at its slid position.
    /// @param {Struct.PaxDrawContext} ctx
    static _draw = function(ctx) {
        var toggle_styles = _get_styles();
        var track = _resolve_style(_track_target_style(toggle_styles), _track_transition);
        var knob = _resolve_style(_knob_target_style(toggle_styles), _knob_transition);

        if (track.sprite != undefined) {
            ctx.sprite(track.sprite, track.subimg,
                bounds.x, bounds.y, bounds.width, bounds.height, track.colour);
        }

        if (knob.sprite == undefined) return;

        var inset = toggle_styles.knob_inset;
        var knob_size = max(0, bounds.height - inset * 2);
        var travel = max(0, bounds.width - knob_size - inset * 2);

        ctx.sprite(knob.sprite, knob.subimg,
            bounds.x + inset + travel * _knob_fraction, bounds.y + inset,
            knob_size, knob_size, knob.colour);
    }

    /// @ignore [Override] Advances the track and knob transitions.
    /// @param {Real} dt
    static _update_transitions = function(dt) {
        if (_transition == undefined) return;
        _transition.update(_get_target_style(), dt);

        var toggle_styles = _get_styles();
        _track_transition = _part_transition(_track_transition);
        _knob_transition = _part_transition(_knob_transition);

        _track_transition.update(_track_target_style(toggle_styles), dt);
        _knob_transition.update(_knob_target_style(toggle_styles), dt);
    }

    /// @ignore [Override] Slides the knob to its new end.
    static _on_checked_changed = function() {
        pax_tweens().stop_target(self);

        var destination = _checked ? 1 : 0;
        var duration = _get_styles().slide_duration;

        if (!_ready || duration <= 0) {
            _knob_fraction = destination;
            return;
        }

        new PaxTween(self, "_knob_fraction", destination, duration).ease(PaxEase.out_cubic);
    }

    /// @ignore
    /// @param {Struct.PaxToggleStyles} toggle_styles
    /// @returns {Struct.PaxStyle}
    static _track_target_style = function(toggle_styles) {
        if (!enabled) return toggle_styles.track_disabled;
        if (_checked) return is_hovered ? toggle_styles.track_checked_hovered : toggle_styles.track_checked;
        if (is_hovered) return toggle_styles.track_hovered;
        if (is_focused) return toggle_styles.track_focused;
        return toggle_styles.track;
    }

    /// @ignore
    /// @param {Struct.PaxToggleStyles} toggle_styles
    /// @returns {Struct.PaxStyle}
    static _knob_target_style = function(toggle_styles) {
        return is_hovered ? toggle_styles.knob_hovered : toggle_styles.knob;
    }

    /// @ignore
    /// @returns {Struct.PaxToggleStyles}
    static _get_styles = function() {
        return styles ?? pax_theme().toggle;
    }
}
