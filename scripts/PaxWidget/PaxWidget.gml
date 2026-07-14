function PaxWidget() constructor {
    children = [];
    parent = undefined;
    
    visible = true;
    enabled = true;
    
    /// @desc Adds a child widget.
    /// @param {Strcut.PaxWidget} child
    /// @returns {Struct.PaxWidget} 
    add = function(child) {
        return self;
    }
    
    /// @desc Removes a child widget without destroying it.
    /// @param {Strcut.PaxWidget} child
    /// @returns {Struct.PaxWidget} 
    remove = function(child) {
        return self;
    }
    
    /// @desc Destroys this widget and all descendants, freeing native resources.
    destroy = function() {
        
    }
    
    /// @desc Assigns a name for later lookup via find().
    /// @param {String} value
    /// @returns {Struct.PaxWidget}
    name = function(value) {
        return self;
    }
    
    /// @desc Recursively searches descendants for a widget by name.
    /// @param {String} name
    /// @returns {Struct.PaxWidget}
    find = function(name) {
        return undefined;
    }
    
    /// @desc Sets the width of the widget.
    /// @param {Real | String} value
    /// @returns {Struct.PaxWidget}
    width = function(value) {
        return self;
    }
    
    /// @desc Sets the height of the widget.
    /// @param {Real | String} value
    /// @returns {Struct.PaxWidget}
    height = function(value) {
        return self;
    }
    
    /// @desc Sets the width and height of the widget.
    /// @param {Real | String} width_value
    /// @param {Real | String} height_value
    /// @returns {Struct.PaxWidget}
    size = function(width_value, height_value) {
        return self;
    }
    
    /// @desc Sets the minimum width the widget can shrink to.
    /// @param {Real | String} value
    /// @returns {Struct.PaxWidget}
    min_width = function(value) {
        return self;
    }
 
    /// @desc Sets the minimum height the widget can shrink to.
    /// @param {Real | String} value
    /// @returns {Struct.PaxWidget}
    min_height = function(value) {
        return self;
    }
 
    /// @desc Sets the maximum width the widget can grow to.
    /// @param {Real | String} value
    /// @returns {Struct.PaxWidget}
    max_width = function(value) {
        return self;
    }
 
    /// @desc Sets the maximum height the widget can grow to.
    /// @param {Real | String} value
    /// @returns {Struct.PaxWidget}
    max_height = function(value) {
        return self;
    }
    
    /// @desc Sizes the widget to fill all available space on both axes.
    /// @returns {Struct.PaxWidget}
    fill = function() {
        return self;
    }
    
    /// @desc Grows the widget to take up remaining space along the parent's main axis.
    /// @returns {Struct.PaxWidget}
    expand = function() {
        return self;
    }
    
    /// @desc Sets the grow factor: how this widget expands relative to siblings.
    /// @param {Real} factor
    /// @returns {Struct.PaxWidget}
    flex = function(factor = 1) {
        return self;
    }
    
    /// @desc Sets the shrink factor: how this widget contracts relative to siblings.
    /// @param {Real} factor
    /// @returns {Struct.PaxWidget}
    shrink = function(factor = 1) {
        return self;
    }
    
    /// @desc Sets the outer spacing around the widget.
    /// 1 arg = all, 2 = vertical/horizontal, 4 = top/right/bottom/left
    /// @param {Real | String} top
    /// @param {Real | String} right
    /// @param {Real | String} bottom
    /// @param {Real | String} left
    /// @returns {Struct.PaxWidget}
    margin = function(top, right = undefined, bottom = undefined, left = undefined) {
        return self;
    }
    
    /// @desc Sets the inner spacing between the widget's edges and its children.
    /// 1 arg = all, 2 = vertical/horizontal, 4 = top/right/bottom/left
    /// @param {Real | String} top
    /// @param {Real | String} right 
    /// @param {Real | String} bottom
    /// @param {Real | String} left
    /// @returns {Struct.PaxWidget}
    padding = function(top, right = undefined, bottom = undefined, left = undefined) {
        return self;
    }
    
    /// @desc Sets the spacing between children along the main axis.
    /// @param {Real} pixels
    /// @returns {Struct.PaxWidget}
    gap = function(pixels) {
        return self;
    }
    
    /// @desc Lays out children horizontally.
    /// @returns {Struct.PaxWidget}
    row = function() {
        return self;
    }
    
    /// @desc Lays out children vertically.
    /// @returns {Struct.PaxWidget}
    column = function() {
        return self;
    }
    
    /// @desc Enables wrapping of children onto multiple lines.
    /// @returns {Struct.PaxWidget}
    wrap = function() {
        return self;
    }
    
    /// @desc Sets main-axis distribution of children.
    /// @param {Enum.PaxJustify} value
    /// @returns {Struct.PaxWidget}
    justify = function(value) {
        return self;
    }
    
    /// @desc Sets cross-axis aligment of children.
    /// @param {Enum.PaxAlign} value
    /// @returns {Struct.PaxWidget}
    align = function(value) {
        return self;
    }
    
    /// @desc Overrides the cross-axis alignment set by the parent, for this widget only.
    /// @param {Enum.PaxAlign} value
    /// @returns {Struct.PaxWidget}
    align_self = function(value) {
        return self;
    }
    
    /// @desc Centers children on both axis.
    /// @returns {Struct.PaxWidget}
    center = function() {
        return self;
    }
    
    /// @desc Removes the widget from flow layout.
    /// @param {Real | String} left
    /// @param {Real | String} top
    /// @returns {Struct.PaxWidget}
    absolute = function(left = undefined, top = undefined) {
        return self;   
    }
    
    /// @desc Sets a position inset on one edge.
    /// @param {Enum.PaxEdge} edge
    /// @param {Real | String} value
    /// @returns {Struct.PaxWidget}
    inset = function(edge, value) {
        return self;
    }
    
    /// @desc Makes the widget visible and included in layout.
    /// @returns {Struct.PaxWidget}
    show = function() {
        return self;
    }
    
    /// @desc Hides the widget and removes it from layout.
    /// @returns {Struct.PaxWidget}
    hide = function() {
        return self;
    }
    
    /// @desc Toggles between shown and hidden.
    /// @returns {Struct.PaxWidget}
    toggle = function() {
        return self;
    }
    
    /// @desc Enables interaction with the widget.
    /// @returns {Struct.PaxWidget}
    enable = function() {
        return self;
    }
 
    /// @desc Disables interaction; the widget stays visible but ignores input.
    /// @returns {Struct.PaxWidget}
    disable = function() {
        return self;
    }
}