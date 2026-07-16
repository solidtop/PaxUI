/// @desc Manages render state during a render pass.
function PaxRenderContext() constructor {
    /// @ignore
    _alpha_stack = [1];
    /// @ignore
    _identity = matrix_build_identity();

    /// @desc Clears all state, ready for a new render pass.
    reset = function() {
        _alpha_stack = [1];
        matrix_stack_clear();
        matrix_set(matrix_world, _identity);
    }

    /// @desc Multiplies an alpha onto the effective alpha until the matching pop_alpha().
    /// @param {Real} alpha
    push_alpha = function(alpha) {
        array_push(_alpha_stack, get_alpha() * alpha);
    }
    
    /// @desc Restores the effective alpha.
    pop_alpha = function() {
        array_pop(_alpha_stack);
    }
    
    /// @desc Returns the current effective alpha.
    /// @returns {Real}
    get_alpha = function() {
        return _alpha_stack[array_length(_alpha_stack) - 1];
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
}