/// @desc Visual appearance of a widget.
function PaxStyle() constructor {
    sprite = spr_pax_pixel;
    subimg = 0;
    colour = c_white;
    alpha = 1;

    /// @desc Copies all fields from another style.
    /// @param {Struct.PaxStyle} style
    static copy_from = function(style) {
        sprite = style.sprite;
        subimg = style.subimg;
        colour = style.colour;
        alpha = style.alpha;
    }
}

