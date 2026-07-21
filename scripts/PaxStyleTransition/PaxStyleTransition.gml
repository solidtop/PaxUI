/// @desc Blends a displayed style toward a target style over time.
function PaxStyleTransition() constructor {
    /// @ignore
    _style = new PaxStyle();
    /// @ignore 
    _r = 0;
    /// @ignore
    _g = 0;
    /// @ignore
    _b = 0;
    /// @ignore
    _initialized = false;
    
    speed = 15;

    /// @desc Returns the blended style, snapping to the target on first use.
    /// @param {Struct.PaxStyle} target
    /// @returns {Struct.PaxStyle}
    static current = function(target) {
        if (!_initialized) _snap(target);
        return _style;
    }

    /// @desc Advances the blend toward the target style.
    /// @param {Struct.PaxStyle} target
    /// @param {Real} dt
    /// @returns {Struct.PaxStyle}
    static update = function(target, dt) {
        if (!_initialized || speed <= 0) {
            _snap(target);
            return _style;
        }

        var amount = 1 - exp(-speed * dt);
        _r = lerp(_r, colour_get_red(target.colour), amount);
        _g = lerp(_g, colour_get_green(target.colour), amount);
        _b = lerp(_b, colour_get_blue(target.colour), amount);

        _style.sprite = target.sprite;
        _style.subimg = target.subimg;
        _style.colour = make_colour_rgb(round(_r), round(_g), round(_b));
        _style.alpha = lerp(_style.alpha, target.alpha, amount);
        return _style;
    }

    /// @ignore 
    /// @param {Struct.PaxStyle} target
    static _snap = function(target) {
        _style.copy_from(target);
        _r = colour_get_red(target.colour);
        _g = colour_get_green(target.colour);
        _b = colour_get_blue(target.colour);
        _initialized = true;
    }
}
