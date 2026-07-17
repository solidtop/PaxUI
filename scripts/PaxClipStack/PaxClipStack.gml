/// @desc Stack of nested clip regions, applied as GPU scissor rects.
function PaxClipStack() constructor {
    /// @ignore
    _stack = array_create(32);
    /// @ignore
    _depth = 0;
    
    /// @desc Pushes a clip rect, intersected with the current region.
    /// @param {Struct.PaxRect} rect
    push = function(rect) {
        var region = _ensure_slot();

        if (_depth > 0) 
            rect.intersect_into(_stack[_depth - 1], region);
        else 
            region.set(rect.x, rect.y, rect.width, rect.height);

        _depth++;
        _apply();
    }
    
    /// @desc Pops the current clip region, restoring the previous one.
    pop = function() {
        _depth--;
        _apply();
    }
    
    /// @desc Returns the active clip rect
    /// @returns {Struct.PaxRect}
    current = function() {
        return (_depth > 0) ? _stack[_depth - 1] : undefined;
    }
    
    /// @desc Empties the stack, removing all clipping.
    clear = function() {
        _depth = 0;
    }
    
    /// @desc Returns whether a rect, shifted by an offset, lies fully outside the
    /// active clip region. Nothing is culled while the stack is empty.
    /// @param {Struct.PaxRect} rect
    /// @param {Real} offset_x
    /// @param {Real} offset_y
    /// @returns {Bool}
    is_culled = function(rect, offset_x, offset_y) {
        var region = current();
        if (region == undefined) return false;

        var rx = rect.x + offset_x;
        var ry = rect.y + offset_y;
        return rx >= region.right()
            || ry >= region.bottom()
            || rx + rect.width  <= region.x
            || ry + rect.height <= region.y;
    }
    
    /// @ignore
    /// @returns {Struct.PaxRect}
    _ensure_slot = function() {
        if (_depth >= array_length(_stack) || !is_struct(_stack[_depth])) 
            _stack[_depth] = new PaxRect(0, 0, 0, 0);
        
        return _stack[_depth];
    }

    /// @ignore
    _apply = function() {
        var region = current();
        
        if (region == undefined) {
            gpu_set_scissor(0, 0, display_get_gui_width(), display_get_gui_height());
            return;
        }
        
        gpu_set_scissor(region.x, region.y, region.width, region.height);
    }
}