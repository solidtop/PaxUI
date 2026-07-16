/// @desc Bridges Pax layout styles to the underlying flexpanel node.
function PaxLayout() constructor {
    /// @ignore
    _node = flexpanel_create_node();
    
    /// @desc Inserts a child layout at the given index in this node's children.
    /// @param {Struct.PaxLayout} child_layout
    /// @param {Real} index
    insert_child = function(child_layout, index) {
        flexpanel_node_insert_child(_node, child_layout._node, index);
    }
    
    /// @desc Detaches a child layout from this node. The child itself is not destroyed.
    /// @param {Struct.PaxLayout} child_layout
    remove_child = function(child_layout) {
        flexpanel_node_remove_child(_node, child_layout._node);
    }
    
    /// @desc Destroys the underlying node. The layout is unusable afterwards.
    destroy = function() {
        flexpanel_delete_node(_node);
        _node = undefined;
    }
    
    /// @desc Sets the preferred width of the node.
    /// @param {Struct.PaxDimension} dimension
    set_width = function(dimension) {
        flexpanel_node_style_set_width(_node, dimension.value, _to_flexpanel_unit(dimension.unit));
    }
    
    /// @desc Sets the preferred height of the node.
    /// @param {Struct.PaxDimension} dimension
    set_height = function(dimension) {
        flexpanel_node_style_set_height(_node, dimension.value, _to_flexpanel_unit(dimension.unit));
    }
    
    /// @desc Sets the minimum width the node can shrink to. Does not accept "auto".
    /// @param {Struct.PaxDimension} dimension
    set_min_width = function(dimension) {
        _assert_not_auto(dimension, "min_width");
        flexpanel_node_style_set_min_width(_node, dimension.value, _to_flexpanel_unit(dimension.unit));
    }
    
    /// @desc Sets the minimum height the node can shrink to. Does not accept "auto".
    /// @param {Struct.PaxDimension} dimension
    set_min_height = function(dimension) {
        _assert_not_auto(dimension, "min_height");
        flexpanel_node_style_set_min_height(_node, dimension.value, _to_flexpanel_unit(dimension.unit));
    }
    
    /// @desc Sets the maximum width the node can grow to. Does not accept "auto".
    /// @param {Struct.PaxDimension} dimension
    set_max_width = function(dimension) {
        _assert_not_auto(dimension, "max_width");
        flexpanel_node_style_set_max_width(_node, dimension.value, _to_flexpanel_unit(dimension.unit));
    }
    
    /// @desc Sets the maximum height the node can grow to. Does not accept "auto".
    /// @param {Struct.PaxDimension} dimension
    set_max_height = function(dimension) {
        _assert_not_auto(dimension, "max_height");
        flexpanel_node_style_set_max_height(_node, dimension.value, _to_flexpanel_unit(dimension.unit));
    }
    
    /// @desc Sets the outer spacing on one edge (or edge group) of the node.
    /// @param {Enum.PaxEdge} edge
    /// @param {Struct.PaxDimension} dimension
    set_margin = function(edge, dimension) {
        flexpanel_node_style_set_margin(_node, _to_flexpanel_edge(edge), dimension.value, _to_flexpanel_unit(dimension.unit));
    }
    
    /// @desc Sets the inner spacing on one edge (or edge group) of the node. Does not accept "auto".
    /// @param {Enum.PaxEdge} edge
    /// @param {Struct.PaxDimension} dimension
    set_padding = function(edge, dimension) {
        _assert_not_auto(dimension, "padding");
        flexpanel_node_style_set_padding(_node, _to_flexpanel_edge(edge), dimension.value, _to_flexpanel_unit(dimension.unit));
    }
    
    /// @desc Sets the spacing between children along one axis.
    /// @param {Enum.PaxAxis} axis
    /// @param {Real} pixels
    set_gap = function(axis, pixels) {
        flexpanel_node_style_set_gap(_node, _to_flexpanel_gutter(axis), pixels);
    }
    
    /// @desc Sets which axis children are laid out along, and in which order.
    /// @param {Enum.PaxDirection} direction
    set_direction = function(direction) {
        flexpanel_node_style_set_flex_direction(_node, _to_flexpanel_direction(direction));
    }
    
    /// @desc Sets how children are distributed along the main axis.
    /// @param {Enum.PaxJustify} justify
    set_justify = function(justify) {
        flexpanel_node_style_set_justify_content(_node, _to_flexpanel_justify(justify));
    }
    
    /// @desc Sets the default cross-axis alignment of children.
    /// @param {Enum.PaxAlign} align
    set_align_items = function(align) {
        flexpanel_node_style_set_align_items(_node, _to_flexpanel_align(align));
    }
    
    /// @desc Overrides the cross-axis alignment set by this node's parent, for this node only.
    /// @param {Enum.PaxAlign} align
    set_align_self = function(align) {
        flexpanel_node_style_set_align_self(_node, _to_flexpanel_align(align));
    }
    
    /// @desc Sets whether children wrap onto multiple lines when they overflow the main axis.
    /// @param {Enum.PaxWrap} wrap
    set_wrap = function(wrap) {
        flexpanel_node_style_set_flex_wrap(_node, _to_flexpanel_wrap(wrap));
    }
    
    /// @desc Shorthand for grow=factor, shrink=1, basis=0: siblings share space proportionally.
    /// @param {Real} factor
    set_flex = function(factor) {
        flexpanel_node_style_set_flex(_node, factor);
    }
    
    /// @desc Sets the grow factor: how much free space this node takes relative to siblings.
    /// @param {Real} factor
    set_flex_grow = function(factor) {
        flexpanel_node_style_set_flex_grow(_node, factor);
    }
    
    /// @desc Sets the shrink factor: how much this node contracts relative to siblings when space runs out.
    /// @param {Real} factor
    set_flex_shrink = function(factor) {
        flexpanel_node_style_set_flex_shrink(_node, factor);
    }
    
    /// @desc Sets the starting main-axis size of the node, before grow/shrink are applied.
    /// @param {Struct.PaxDimension} dimension
    set_flex_basis = function(dimension) {
        flexpanel_node_style_set_flex_basis(_node, dimension.value, _to_flexpanel_unit(dimension.unit));
    }
    
    /// @desc Includes or excludes the node from layout. Excluded nodes take up no space.
    /// @param {Bool} included
    set_display = function(included) {
        var display = included ? flexpanel_display.flex : flexpanel_display.none;
        flexpanel_node_style_set_display(_node, display);
    }
    
    /// @desc Sets whether the node follows flow layout (Relative) or is taken out of it (Absolute).
    /// @param {Enum.PaxPosition} position
    set_position_type = function(position) {
        flexpanel_node_style_set_position_type(_node, _to_flexpanel_position_type(position));
    }
    
    /// @desc Anchors one edge of the node at an offset from the matching edge of its parent.
    /// Used with Absolute positioning (inset).
    /// @param {Enum.PaxEdge} edge
    /// @param {Struct.PaxDimension} dimension
    set_position = function(edge, dimension) {
        flexpanel_node_style_set_position(
            _node, 
            _to_flexpanel_edge(edge), 
            dimension.value, 
            _to_flexpanel_unit(dimension.unit)
        );
    }
    
    /// @desc Computes the layout of this node and its entire subtree.
    /// @param {Real} width
    /// @param {Real} height
    calculate = function(width, height) {
        flexpanel_calculate_layout(_node, width, height, flexpanel_direction.LTR);
    }
    
    /// @desc Writes the computed bounds of this node into the given rect.
    /// @param {Struct.PaxRect} out_rect
    get_bounds = function(out_rect) {
        var position = flexpanel_node_layout_get_position(_node, false);
        out_rect.set(position.left, position.top, position.width, position.height);
    }
    
    /// @ignore
    /// @param {Enum.PaxUnit} unit
    /// @returns {Real}
    static _to_flexpanel_unit = function(unit) {
        switch (unit) {
            case PaxUnit.Pixel: return flexpanel_unit.point;
            case PaxUnit.Percent: return flexpanel_unit.percent;
            case PaxUnit.Auto: return flexpanel_unit.auto;
        }
    }
    
    /// @ignore
    /// @param {Enum.PaxEdge} edge
    /// @returns {Real}
    static _to_flexpanel_edge = function(edge) {
        switch (edge) {
            case PaxEdge.Left: return flexpanel_edge.left;
            case PaxEdge.Top: return flexpanel_edge.top;
            case PaxEdge.Right: return flexpanel_edge.right;
            case PaxEdge.Bottom: return flexpanel_edge.bottom;
            case PaxEdge.Horizontal: return flexpanel_edge.horizontal;
            case PaxEdge.Vertical: return flexpanel_edge.vertical;
            case PaxEdge.All: return flexpanel_edge.all_edges;
        }
    }
    
    /// @ignore
    /// @param {Enum.PaxDirection} direction
    /// @returns {Real}
    static _to_flexpanel_direction = function(direction) {
        switch (direction) {
            case PaxDirection.Row: return flexpanel_flex_direction.row;
            case PaxDirection.Column: return flexpanel_flex_direction.column;
            case PaxDirection.RowReverse: return flexpanel_flex_direction.row_reverse;
            case PaxDirection.ColumnReverse: return flexpanel_flex_direction.column_reverse;
        }
    }
    
    /// @ignore
    /// @param {Enum.PaxJustify} justify
    /// @returns {Real}
    static _to_flexpanel_justify = function(justify) {
        switch (justify) {
            case PaxJustify.Start: return flexpanel_justify.start;
            case PaxJustify.Center: return flexpanel_justify.center;
            case PaxJustify.End: return flexpanel_justify.flex_end;
            case PaxJustify.SpaceBetween: return flexpanel_justify.space_between;
            case PaxJustify.SpaceAround: return flexpanel_justify.space_around;
            case PaxJustify.SpaceEvenly: return flexpanel_justify.space_evenly;
        }
    }
    
    /// @ignore
    /// @param {Enum.PaxAlign} align
    /// @returns {Real}
    static _to_flexpanel_align = function(align) {
        switch (align) {
            case PaxAlign.Auto: return flexpanel_align.auto;
            case PaxAlign.Start: return flexpanel_align.flex_start;
            case PaxAlign.Center: return flexpanel_align.center;
            case PaxAlign.End: return flexpanel_align.flex_end;
            case PaxAlign.Stretch: return flexpanel_align.stretch;
            case PaxAlign.Baseline: return flexpanel_align.baseline;
        }
    }
    
    /// @ignore
    /// @param {Enum.PaxWrap} wrap
    /// @returns {Real}
    static _to_flexpanel_wrap = function(wrap) {
        switch (wrap) {
            case PaxWrap.NoWrap: return flexpanel_wrap.no_wrap;
            case PaxWrap.Wrap: return flexpanel_wrap.wrap;
            case PaxWrap.WrapReverse: return flexpanel_wrap.reverse;
        }
    }
    
    /// @ignore
    /// @param {Enum.PaxAxis} axis
    /// @returns {Real}
    static _to_flexpanel_gutter = function(axis) {
        switch (axis) {
            case PaxAxis.Horizontal: return flexpanel_gutter.column;
            case PaxAxis.Vertical: return flexpanel_gutter.row;
            case PaxAxis.Both: return flexpanel_gutter.all_gutters;
        }
    }
    
    /// @ignore
    /// @param {Enum.PaxPosition} position
    /// @returns {Real}
    static _to_flexpanel_position_type = function(position) {
        switch (position) {
            case PaxPosition.Relative: return flexpanel_position_type.relative;
            case PaxPosition.Absolute: return flexpanel_position_type.absolute;
        }
    }
    
    /// @ignore
    /// @param {Struct.PaxDimension} dimension
    /// @param {String} property_name
    static _assert_not_auto = function(dimension, property_name) {
        if (dimension.unit == PaxUnit.Auto) {
            show_error($"PaxUI: \"auto\" is not a valid value for {property_name}.", true);
        }
    }
}