/// @desc Visual appearance of a widget.
function PaxStyle() constructor {
    sprite = undefined;
    subimg = 0;
    colour = c_white;
    alpha = 1;
    font = -1; 
    line_height = -1;

    /// @desc Copies all fields from another style.
    /// @param {Struct.PaxStyle} style
    static copy_from = function(style) {
        sprite = style.sprite;
        subimg = style.subimg;
        colour = style.colour;
        alpha = style.alpha;
        font = style.font;
        line_height = style.line_height;
    }

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

    /// @desc Builds a text style, which draws no background.
    /// @param {Constant.Colour} colour
    /// @param {Asset.GMFont} font
    /// @returns {Struct.PaxStyle}
    static build_text = function(colour, font = -1) {
        var style = new PaxStyle();
        style.colour = colour;
        style.font = font;
        return style;
    }
}

new PaxStyle();

