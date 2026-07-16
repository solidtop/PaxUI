/// @desc Visual appearance of a widget.
function PaxStyle() constructor {
    sprite = spr_pax_pixel;
    subimg = 0;
    colour = c_white;
    alpha = 1;

    /// @desc Copies all fields from another style.
    /// @param {Struct.PaxStyle} style
    copy_from = function(style) {
        sprite = style.sprite;
        subimg = style.subimg;
        colour = style.colour;
        alpha = style.alpha;
    }
}

/// @desc Returns the shared 1x1 white sprite used for solid fills, creating it on first use.
/// @returns {Asset.GMSprite}
function pax_sprite_pixel() {
    static sprite = -1;
    if (sprite == -1) {
        var surface = surface_create(1, 1);
        surface_set_target(surface);
        draw_clear(c_white);
        surface_reset_target();
        sprite = sprite_create_from_surface(surface, 0, 0, 1, 1, false, false, 0, 0);
        surface_free(surface);
    }
    return sprite;
}
