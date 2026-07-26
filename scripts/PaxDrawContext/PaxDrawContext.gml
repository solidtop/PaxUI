/// @desc Per-widget drawing state handed to _draw. Valid only during that call.
function PaxDrawContext() constructor {
    alpha = 1;

    /// @desc Draws a sprite stretched over a rect.
    /// @param {Asset.GMSprite} sprite
    /// @param {Real} subimg
    /// @param {Real} x
    /// @param {Real} y
    /// @param {Real} width
    /// @param {Real} height
    /// @param {Constant.Colour} colour
    static sprite = function(sprite, subimg, x, y, width, height, colour = c_white) {
        draw_sprite_stretched_ext(sprite, subimg, x, y, width, height, colour, alpha);
    }

    /// @desc Draws text anchored at (x, y), wrapped to width.
    /// @param {String} str
    /// @param {Asset.GMFont} font
    /// @param {Real} x
    /// @param {Real} y
    /// @param {Real} width
    /// @param {Constant.Colour} colour
    /// @param {Constant.HAlign} halign
    /// @param {Constant.VAlign} valign
    /// @param {Real} line_height  Line separation; -1 for the font's default.
    static text = function(str, font, x, y, width, colour, halign, valign, line_height = -1) {
        draw_set_font(font);
        draw_set_colour(colour);
        draw_set_alpha(alpha);
        draw_set_halign(halign);
        draw_set_valign(valign);
        draw_text_ext(x, y, str, line_height, width);
    }
}