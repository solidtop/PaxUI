/// @desc A text label. 
/// @param {String} text
function PaxLabel(text = "") : PaxWidget() constructor {
    /// @ignore
    _halign = fa_left;
    /// @ignore
    _valign = fa_top;
    
    self.text = text;
    pointer_filter = PaxPointerFilter.Ignore; 

    /// @desc Sets the font and re-measures.
    /// @param {Asset.GMFont} value
    /// @returns {Struct.PaxLabel}
    static font = function(value) {
        _ensure_style().font = value;
        return self;
    }

    /// @desc Sets the line separation for wrapped text, and re-measures.
    /// @param {Real} pixels -1 for the font's default.
    /// @returns {Struct.PaxLabel}
    static line_height = function(pixels) {
        _ensure_style().line_height = pixels;
        return self;
    }   
        
    /// @desc Sets the text alignment within the label's bounds.
    /// @param {Constant.HAlign} halign
    /// @param {Constant.VAlign} valign
    /// @returns {Struct.PaxLabel}
    static align_text = function(halign, valign = fa_top) {
        _halign = halign;
        _valign = valign;
        return self;
    }

    /// @desc [Override] Draws the text, aligned within bounds.
    /// @param {Struct.PaxDrawContext} ctx
    static _draw = function(ctx) {
        var style = _get_active_style();

        var ax = bounds.x + (_halign == fa_center ? bounds.width * 0.5
                          : (_halign == fa_right  ? bounds.width : 0));
        var ay = bounds.y + (_valign == fa_middle ? bounds.height * 0.5
                          : (_valign == fa_bottom ? bounds.height : 0));

        ctx.text(text, style.font, ax, ay, bounds.width, style.colour,
            _halign, _valign, style.line_height);
    }
    
    /// @desc [Override] Labels fall back to the theme's label style.
    /// @returns {Struct.PaxStyle}
    static _get_target_style = function() {
        return style ?? pax_theme().label;
    }

    /// @ignore 
    /// @param {Real} width
    /// @param {Real} width_mode 
    /// @param {Real} height
    /// @param {Real} height_mode
    /// @returns {Struct}
    static _measure = function(width, width_mode, height, height_mode) {
        var style = _get_active_style();
        draw_set_font(style.font);

        var max_width = (width_mode == 0) ? infinity : width;
        
        return {
            width:  string_width_ext(text, style.line_height, max_width),
            height: string_height_ext(text, style.line_height, max_width),
        };
    }
    
    _layout.set_measure(method(self, _measure));
}
