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
        _render_tree(root, _render_context, 0, 0, true);
    }

    /// @ignore
    /// @param {Struct.PaxWidget} widget
    /// @param {Struct.PaxRenderContext} ctx
    /// @param {Real} offset_x Accumulated ancestor translation.
    /// @param {Real} offset_y Accumulated ancestor translation.
    /// @param {Bool} cullable False under rotation/scale, where bounds no longer match pixels.
    _render_tree = function(widget, ctx, offset_x, offset_y, cullable) {
        if (!widget.visible) return;

        var transform = widget._transform;
        var transformed = transform != undefined && !transform.is_identity();
        if (transformed) {
            if (transform.is_translation_only()) {
                offset_x += transform.x;
                offset_y += transform.y;
            } else {
                cullable = false;
            }
        }

        var culled = cullable && ctx.is_culled(widget.bounds, offset_x, offset_y);
        if (culled && widget.clips_children) return;

        _draw_context.alpha = ctx.push_alpha(widget.style.alpha);

        if (transformed)
            ctx.push_transform(transform.build_matrix(widget.bounds));

        if (!culled)
            widget._draw(_draw_context);

        var clipped = widget.clips_children;
        if (clipped)
            ctx.push_clip(widget.bounds);

        var children = widget.children;
        for (var i = 0; i < array_length(children); i++)
        	_render_tree(children[i], ctx, offset_x, offset_y, cullable);

        if (clipped) ctx.pop_clip();
        if (transformed) ctx.pop_transform();
        ctx.pop_alpha();
    }
}
