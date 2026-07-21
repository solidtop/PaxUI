/// @desc Visual appearance of a widget.
function PaxStyle() constructor {
    sprite = undefined;
    subimg = 0;
    colour = c_white;
    alpha = 1;

    /// @desc Builds a solid-colour style.
    /// @param {Constant.Colour} colour
    /// @param {Real} alpha
    /// @returns {Struct.PaxStyle}
    static build_solid = function(colour, alpha = 1) {
        var style = new PaxStyle();
        style.sprite = spr_pax_pixel;
        style.colour = colour;
        style.alpha = alpha;
        return style;
    }

    /// @desc Copies all fields from another style.
    /// @param {Struct.PaxStyle} style
    static copy_from = function(style) {
        sprite = style.sprite;
        subimg = style.subimg;
        colour = style.colour;
        alpha = style.alpha;
    }
}

/// @desc Per-state style presets for buttons. Construct and override individual states to make a variant.
function PaxButtonStyle() constructor {
    normal = PaxStyle.build_solid(#3F3F46);
    hovered = PaxStyle.build_solid(#52525B);
    pressed = PaxStyle.build_solid(#27272A);
    disabled = PaxStyle.build_solid(#3F3F46, 0.5);
    focused = PaxStyle.build_solid(#72525D);
}

