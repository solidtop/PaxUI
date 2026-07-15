/// @desc Manages render state during a render pass.
function PaxRenderContext() constructor {
    /// @desc Applies a transform to everything drawn until the matching
    /// pop_transform(). Pushes onto a stack, so nested transforms compose.
    /// @param {Array<Real>} matrix
    push_transform = function (matrix) {
        matrix_stack_push(matrix);
        matrix_set(matrix_world, matrix_stack_top());
    }

    /// @desc Removes the most recent transform, restoring the previous one.
    /// Every push_transform() must be balanced by exactly one pop_transform().
    pop_transform = function() {
        matrix_stack_pop();
    }
}