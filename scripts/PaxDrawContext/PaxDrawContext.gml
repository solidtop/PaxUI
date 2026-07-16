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
    sprite = function(sprite, subimg, x, y, width, height, colour = c_white) {
        draw_sprite_stretched_ext(sprite, subimg, x, y, width, height, colour, alpha);
    }
}