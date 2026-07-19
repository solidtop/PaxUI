/// @desc Base widget and fluent public API for building UI trees.
function PaxWidget() constructor {
    /// @ignore
    _layout = new PaxLayout();
    /// @ignore
    _transform = undefined;
    
    children = [];
    parent = undefined;
    name = "";
    bounds = new PaxRect(0, 0, 0, 0);
    content_bounds = new PaxRect(0, 0, 0, 0);
    style = undefined; 
    
    visible = true;
    enabled = true;
    clips_children = false;
    pointer_filter = PaxPointerFilter.Pass;
    focus_mode = PaxFocusMode.None;
    focus_index = 0;
    is_focused = false;
    
    /// @desc Adds a child widget.
    /// @param {Struct.PaxWidget} child
    /// @returns {Struct.PaxWidget} 
    static add = function(child) {
        _layout.insert_child(child._layout, array_length(children));
        array_push(children, child);
        child.parent = self;
        return self;
    }
    
    /// @desc Removes a child widget without destroying it.
    /// @param {Struct.PaxWidget} child
    /// @returns {Struct.PaxWidget} 
    static remove = function(child) {
        var index = array_get_index(children, child);
        if (index == -1) return self;
        array_delete(children, index, 1);
        child.parent = undefined;
        _layout.remove_child(child._layout);
        return self;
    }
    
    /// @desc Destroys this widget and all descendants, freeing native resources.
    static destroy = function() {
        if (parent != undefined) 
            parent.remove(self);
        
        for (var i = array_length(children) - 1; i >= 0; i--)
            children[i].destroy();
        
        _layout.destroy();
    }

    /// @desc Returns whether the widget has been destroyed.
    /// @returns {Bool}
    static is_destroyed = function() {
        return _layout.is_destroyed();
    }

    /// @desc Assigns a name for later lookup via find().
    /// @param {String} value
    /// @returns {Struct.PaxWidget}
    static named = function(value) {
        name = value;
        return self;
    }
    
    /// @desc Recursively searches descendants for a widget by name.
    /// @param {String} name
    /// @returns {Struct.PaxWidget}
    static find = function(name) { 
        for (var i = 0; i < array_length(children); i++) {
           var child = children[i];
           if (child.name == name) return child;
           var found = child.find(name);
           if (found != undefined) return found;
        }
        return undefined;
    }
    
    /// @desc Sets the width of the widget. Accepts pixels, "N%" or "auto".
    /// @param {Real | String} value
    /// @returns {Struct.PaxWidget}
    static width = function(value) {
        _layout.set_width(PaxDimension.parse(value));
        return self;
    }
    
    /// @desc Sets the height of the widget. Accepts pixels, "N%" or "auto".
    /// @param {Real | String} value
    /// @returns {Struct.PaxWidget}
    static height = function(value) {
        _layout.set_height(PaxDimension.parse(value));
        return self;
    }
    
    /// @desc Sets the width and height of the widget. Accepts pixels, "N%" or "auto".
    /// @param {Real | String} width_value
    /// @param {Real | String} height_value
    /// @returns {Struct.PaxWidget}
    static size = function(width_value, height_value) {
        width(width_value);
        height(height_value);
        return self;
    }
    
    /// @desc Sets the minimum width the widget can shrink to. Accepts pixels, or "N%".
    /// @param {Real | String} value
    /// @returns {Struct.PaxWidget}
    static min_width = function(value) {
        _layout.set_min_width(PaxDimension.parse(value));
        return self;
    }
 
    /// @desc Sets the minimum height the widget can shrink to. Accepts pixels, or "N%".
    /// @param {Real | String} value
    /// @returns {Struct.PaxWidget}
    static min_height = function(value) {
        _layout.set_min_height(PaxDimension.parse(value));
        return self;
    }
 
    /// @desc Sets the maximum width the widget can grow to. Accepts pixels, or "N%".
    /// @param {Real | String} value
    /// @returns {Struct.PaxWidget}
    static max_width = function(value) {
        _layout.set_max_width(PaxDimension.parse(value));
        return self;
    }
 
    /// @desc Sets the maximum height the widget can grow to. Accepts pixels, or "N%".
    /// @param {Real | String} value
    /// @returns {Struct.PaxWidget}
    static max_height = function(value) {
        _layout.set_max_height(PaxDimension.parse(value));
        return self;
    }
    
    /// @desc Sizes the widget to fill all available space on both axes.
    /// @returns {Struct.PaxWidget}
    static fill = function() {
        var dimension = new PaxDimension(100, PaxUnit.Percent);
        _layout.set_width(dimension);
        _layout.set_height(dimension);
        return self;
    }
    
    /// @desc Shares space with siblings proportionally by factor.
    /// @param {Real} factor
    /// @returns {Struct.PaxWidget}
    static flex = function(factor = 1) {
        _layout.set_flex(factor);
        return self;
    }
    
    /// @desc Grows the widget to take up remaining space along the parent's main axis.
    /// @returns {Struct.PaxWidget}
    static expand = function() {
        _layout.set_flex_grow(1);
        _layout.set_flex_shrink(1);
        return self;
    }
    
    /// @desc Sets the grow factor: how this widget expands relative to siblings.
    /// @param {Real} factor
    /// @returns {Struct.PaxWidget}
    static grow = function(factor = 1) {
        _layout.set_flex_grow(factor);
        return self;
    }
    
    /// @desc Sets the shrink factor: how this widget contracts relative to siblings.
    /// @param {Real} factor
    /// @returns {Struct.PaxWidget}
    static shrink = function(factor = 1) {
        _layout.set_flex_shrink(factor);
        return self;
    }
    
    /// @desc Sets the outer spacing around the widget. Accepts pixels, "N%" or "auto".
    /// 1 arg = all, 2 = vertical/horizontal, 4 = top/right/bottom/left
    /// @param {Real | String} top
    /// @param {Real | String} right
    /// @param {Real | String} bottom
    /// @param {Real | String} left
    /// @returns {Struct.PaxWidget}
    static margin = function(top, right = undefined, bottom = undefined, left = undefined) {
        _apply_to_edges(method(_layout, _layout.set_margin), top, right, bottom, left);
        return self;
    }
    
    /// @desc Sets the inner spacing between the widget's edges and its children. Accepts pixels, or "N%".
    /// 1 arg = all, 2 = vertical/horizontal, 4 = top/right/bottom/left
    /// @param {Real | String} top
    /// @param {Real | String} right 
    /// @param {Real | String} bottom
    /// @param {Real | String} left
    /// @returns {Struct.PaxWidget}
    static padding = function(top, right = undefined, bottom = undefined, left = undefined) {
        _apply_to_edges(method(_layout, _layout.set_padding), top, right, bottom, left);
        return self;
    }
    
    /// @desc Sets the spacing between children.
    /// @param {Real} pixels
    /// @returns {Struct.PaxWidget}
    static gap = function(pixels) {
        _layout.set_gap(PaxAxis.Both, pixels);
        return self;
    }
    
    /// @desc Lays out children horizontally.
    /// @returns {Struct.PaxWidget}
    static row = function() {
        _layout.set_direction(PaxDirection.Row);
        return self;
    }
    
    /// @desc Lays out children vertically.
    /// @returns {Struct.PaxWidget}
    static column = function() {
        _layout.set_direction(PaxDirection.Column);
        return self;
    }
    
    /// @desc Enables wrapping of children onto multiple lines.
    /// @returns {Struct.PaxWidget}
    static wrap = function() {
        _layout.set_wrap(PaxWrap.Wrap);
        return self;
    }
    
    /// @desc Sets main-axis distribution of children.
    /// @param {Enum.PaxJustify} value
    /// @returns {Struct.PaxWidget}
    static justify = function(value) {
        _layout.set_justify(value);
        return self;
    }
    
    /// @desc Sets cross-axis aligment of children.
    /// @param {Enum.PaxAlign} value
    /// @returns {Struct.PaxWidget}
    static align = function(value) {
        _layout.set_align_items(value);
        return self;
    }
    
    /// @desc Overrides the cross-axis alignment set by the parent, for this widget only.
    /// @param {Enum.PaxAlign} value
    /// @returns {Struct.PaxWidget}
    static align_self = function(value) {
        _layout.set_align_self(value);
        return self;
    }
    
    /// @desc Centers children on both axis.
    /// @returns {Struct.PaxWidget}
    static center = function() {
        _layout.set_justify(PaxJustify.Center);
        _layout.set_align_items(PaxAlign.Center);
        return self;
    }
    
    /// @desc Removes the widget from flow layout. Accepts pixels, "N%" or "auto".
    /// @param {Real | String} left
    /// @param {Real | String} top
    /// @returns {Struct.PaxWidget}
    static absolute = function(left = undefined, top = undefined) {
        _layout.set_position_type(PaxPosition.Absolute);
        if (left != undefined)
            _layout.set_position(PaxEdge.Left, PaxDimension.parse(left));
        if (top != undefined)
            _layout.set_position(PaxEdge.Top, PaxDimension.parse(top));
        return self;   
    }
    
    /// @desc Sets a position inset on one edge.
    /// @param {Enum.PaxEdge} edge
    /// @param {Real | String} value
    /// @returns {Struct.PaxWidget}
    static inset = function(edge, value) {
        _layout.set_position(edge, PaxDimension.parse(value));
        return self;
    }
    
    /// @desc Makes the widget visible and included in layout.
    /// @returns {Struct.PaxWidget}
    static show = function() {
        visible = true;
        _layout.set_display(true);
        return self;
    }
    
    /// @desc Hides the widget and removes it from layout.
    /// @returns {Struct.PaxWidget}
    static hide = function() {
        visible = false;
        _layout.set_display(false);
        return self;
    }
    
    /// @desc Toggles between shown and hidden.
    /// @returns {Struct.PaxWidget}
    static toggle = function() {
        return visible ? hide() : show();
    }
    
    /// @desc Enables interaction with the widget.
    /// @returns {Struct.PaxWidget}
    static enable = function() {
        enabled = true;
        return self;
    }
 
    /// @desc Disables interaction; the widget stays visible but ignores input.
    /// @returns {Struct.PaxWidget}
    static disable = function() {
        enabled = false;
        return self;
    }

    /// @desc Sets how the widget participates in pointer input.
    /// @param {Enum.PaxPointerFilter} value
    /// @returns {Struct.PaxWidget}
    static pointer = function(value) {
        pointer_filter = value;
        return self;
    }

    /// @desc Makes the widget transparent to pointer input. Children are unaffected.
    /// @returns {Struct.PaxWidget}
    static pass_through = function() {
        pointer_filter = PaxPointerFilter.Ignore;
        return self;
    }

    /// @desc Gives this widget keyboard focus, if its focus_mode allows it.
    /// @returns {Struct.PaxWidget}
    static focus = function() {
        pax_focus().focus(self);
        return self;
    }

    /// @desc Removes keyboard focus from this widget, if it holds it.
    /// @returns {Struct.PaxWidget}
    static unfocus = function() {
        if (is_focused) pax_focus().unfocus();
        return self;
    }

    /// @desc Sets the widget's background sprite.
    /// @param {Asset.GMSprite} sprite
    /// @param {Real} subimg
    /// @returns {Struct.PaxWidget}
    static sprite = function(sprite, subimg = 0) {
        var current = _ensure_style();
        current.sprite = sprite;
        current.subimg = subimg;
        return self;
    }

    /// @desc Fills the widget's background with a solid colour.
    /// @param {Constant.Colour} colour
    /// @returns {Struct.PaxWidget}
    static background = function(colour) {
        var current = _ensure_style();
        current.sprite = spr_pax_pixel;
        current.colour = colour;
        return self;
    }

    /// @desc Copies a style preset into this widget's style override.
    /// @param {Struct.PaxStyle} preset
    /// @returns {Struct.PaxWidget}
    static styled = function(preset) {
        _ensure_style().copy_from(preset);
        return self;
    }

    /// @desc Tints the widget's sprite.
    /// @param {Constant.Colour} colour
    /// @returns {Struct.PaxWidget}
    static tint = function(colour) {
        _ensure_style().colour = colour;
        return self;
    }

    /// @desc Sets the opacity of the widget and its descendants.
    /// @param {Real} value
    /// @returns {Struct.PaxWidget}
    static alpha = function(value) {
        _ensure_style().alpha = value;
        return self;
    }
    
    /// @desc Moves the widget visually without affecting layout.
    /// @param {Real} x
    /// @param {Real} y
    /// @param {Real} z
    /// @returns {Struct.PaxWidget}
    static translate = function(x, y, z = 0) {
        var transform = _ensure_transform();
        transform.x = x;
        transform.y = y;
        transform.z = z;
        return self;
    }
    
    /// @desc Rotates the widget and its descendants around its center. Does not affect layout.
    /// @param {Real} degrees
    /// @returns {Struct.PaxWidget}
    static rotate = function(degrees) {
        _ensure_transform().angle_z = degrees;
        return self;
    }
    
    /// @desc Scales the widget and its descendants from its center. Does not affect layout.
    /// @param {Real} scale_x
    /// @param {Real} scale_y Defaults to scale_x for uniform scaling.
    /// @param {Real} scale_z
    /// @returns {Struct.PaxWidget}
    static scale = function(scale_x, scale_y = undefined, scale_z = 1) {
        var transform = _ensure_transform();
        transform.scale_x = scale_x;
        transform.scale_y = scale_y ?? scale_x;
        transform.scale_z = scale_z;
        return self;
    }
    
    /// @desc Clips children that overflow the widget's content bounds.
    /// @returns {Struct.PaxWidget}
    static clip = function() {
        clips_children = true;
        return self;
    }
    
    /// @desc [Virtual] Updates this widget for the current frame. Override in subclasses.
    /// @param {Real} dt  Delta time in seconds.
    static _update = function(dt) {}

    /// @desc [Virtual] Handles an input event dispatched by PaxInput. Override in subclasses.
    /// @param {Struct.PaxEvent} event
    static _on_event = function(event) {}
    
    /// @desc [Virtual] Draws this widget; by default the active style's background sprite.
    /// @param {Struct.PaxDrawContext} ctx
    static _draw = function(ctx) {
        var current = _get_active_style();
        if (current.sprite == undefined) return;
        ctx.sprite(
            current.sprite, current.subimg,
            bounds.x, bounds.y, bounds.width, bounds.height,
            current.colour
        );
    }
    
    /// @desc [Virtual] Returns whether a point (in widget space) hits this widget.
    /// @param {Real} point_x
    /// @param {Real} point_y
    /// @returns {Bool}
    static _hit_test = function(point_x, point_y) {
        return point_x >= bounds.x && point_y >= bounds.y
            && point_x < bounds.x + bounds.width
            && point_y < bounds.y + bounds.height;
    }
    
    /// @desc [Virtual] Returns the style to draw with this frame. Override to swap styles by state.
    /// @returns {Struct.PaxStyle}
    static _get_active_style = function() {
        return style ?? pax_theme().widget;
    }

    /// @ignore
    /// @returns {Struct.PaxTransform}
    static _ensure_transform = function() {
        _transform ??= new PaxTransform();
        return _transform;
    }
    
    /// @ignore 
    /// @returns {Struct.PaxStyle}
    static _ensure_style = function() {
        if (style == undefined) {
            var current = _get_active_style();
            style = new PaxStyle();
            style.copy_from(current);
        }
        
        return style;
    }

    /// @ignore
    /// @param {Function} setter
    /// @param {Real | String} top
    /// @param {Real | String} right
    /// @param {Real | String} bottom
    /// @param {Real | String} left
    static _apply_to_edges = function(setter, top, right, bottom, left) {
        if (right == undefined) {
            setter(PaxEdge.All, PaxDimension.parse(top));
        } else if (bottom == undefined) {
            setter(PaxEdge.Vertical, PaxDimension.parse(top));
            setter(PaxEdge.Horizontal, PaxDimension.parse(right));
        } else {
            setter(PaxEdge.Top, PaxDimension.parse(top));
            setter(PaxEdge.Right, PaxDimension.parse(right));
            setter(PaxEdge.Bottom, PaxDimension.parse(bottom));
            setter(PaxEdge.Left, PaxDimension.parse(left ?? right));
        }
    }
}