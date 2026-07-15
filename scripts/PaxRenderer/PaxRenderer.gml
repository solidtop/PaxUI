/// @desc Draws widget trees.
function PaxRenderer() constructor {
    
    /// @desc Renders a widget tree, walking it depth-first.
    /// @param {Struct.PaxWidget} root
    /// @param {Struct.PaxRenderContext} context
    render = function(root, context) {
        _render_widget_tree(root, context);
    }  
    
    /// @ignore
    /// @param {Struct.PaxWidget} widget
    /// @param {Struct.PaxRenderContext} ctx
    _render_widget_tree = function(widget, ctx) {
        widget._draw();
        
        var children = widget.children;
        for (var i = 0; i < array_length(children); i++) {
        	_render_widget_tree(children[i], ctx);
        }
    }
}
