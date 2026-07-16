/// @desc Draws widget trees.
function PaxRenderer() constructor {
    /// @ignore
    _render_context = new PaxRenderContext();
    /// @ignore
    _draw_context = new PaxDrawContext();

    /// @desc Renders a widget tree, walking it depth-first.
    /// @param {Struct.PaxWidget} root
    render = function(root) {
        _render_context.reset();
        _render_tree(root, _render_context);
    }
    
    /// @ignore
    /// @param {Struct.PaxWidget} widget
    /// @param {Struct.PaxRenderContext} ctx
    _render_tree = function(widget, ctx) {
        if (!widget.visible) return;
            
        _draw_context.alpha = ctx.push_alpha(widget.style.alpha);
        
        var transform = widget._transform;
        var transformed = transform != undefined && !transform.is_identity();
        if (transformed) 
            ctx.push_transform(transform.build_matrix(widget.bounds));
        
        widget._draw(_draw_context);
        
        var clipped = widget.clips_children; 
        if (clipped) 
            ctx.push_clip(widget.bounds);
        
        var children = widget.children;
        for (var i = 0; i < array_length(children); i++) 
        	_render_tree(children[i], ctx);
        
        ctx.pop_alpha();
        if (transformed) ctx.pop_transform();
        if (clipped) ctx.pop_clip();    
    }
}
