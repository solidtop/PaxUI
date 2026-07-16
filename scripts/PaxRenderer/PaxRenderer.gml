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
            
        ctx.push_alpha(widget.style.alpha);
        _draw_context.alpha = ctx.get_alpha();
        
        widget._draw(_draw_context);
        
        var children = widget.children;
        for (var i = 0; i < array_length(children); i++) {
        	_render_tree(children[i], ctx);
        }
        
        ctx.pop_alpha();
    }
}
