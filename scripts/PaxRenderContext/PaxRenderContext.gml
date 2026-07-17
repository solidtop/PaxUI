/// @desc Manages render state during a render pass.
function PaxRenderContext() constructor {
    /// @ignore
    _alpha_stack = [1];
    /// @ignore
    _identity = matrix_build_identity();
    /// @ignore
    _clip_stack = new PaxClipStack();

    /// @desc Clears all state, ready for a new render pass.
    reset = function() {
        _alpha_stack = [1];
        matrix_stack_clear();
        matrix_set(matrix_world, _identity);
        _clip_stack.clear();
    }

    /// @desc Multiplies an alpha onto the effective alpha until the matching pop_alpha().
    /// @param {Real} alpha
    /// @returns {Real} The new effective alpha.
    push_alpha = function(alpha) {
        var effective = array_last(_alpha_stack) * alpha;
        array_push(_alpha_stack, effective);
        return effective;
    }
    
    /// @desc Restores the effective alpha.
    pop_alpha = function() {
        array_pop(_alpha_stack);
    }
    
    /// @desc Applies a transform to everything drawn until the matching
    /// pop_transform(). Composes with the current transform, so nesting works.
    /// @param {Array<Real>} matrix
    push_transform = function(matrix) {
        matrix_stack_push(matrix);
        matrix_set(matrix_world, matrix_stack_top());
    }

    /// @desc Removes the most recent transform, restoring the previous one.
    /// Every push_transform() must be balanced by exactly one pop_transform().
    pop_transform = function() {
        matrix_stack_pop();
    }
    
    /// @desc Clips everything drawn to the given rect until the matching pop_clip().
    /// Nested clips are intersected with the enclosing region.
    /// @param {Struct.PaxRect} rect
    push_clip = function(rect) {
        _clip_stack.push(rect);
    }

    /// @desc Removes the most recent clip, restoring the enclosing region.
    pop_clip = function() {
        _clip_stack.pop();
    }

    /// @desc Returns whether a rect, shifted by an offset, is fully outside the visible region.
    /// @param {Struct.PaxRect} rect
    /// @param {Real} offset_x
    /// @param {Real} offset_y
    /// @returns {Bool}
    is_culled = function(rect, offset_x, offset_y) {
        return _clip_stack.is_culled(rect, offset_x, offset_y);
    }
}