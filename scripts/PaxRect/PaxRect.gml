/// @desc An axis-aligned rectangle defined by a position and size.
/// @param {Real} x 
/// @param {Real} y 
/// @param {Real} width 
/// @param {Real} height
function PaxRect(x, y, width, height) constructor {
    self.x = x;
    self.y = y;
    self.width = width;
    self.height = height;
    
    /// @desc Returns the right edge.
    /// @returns {Real}
    right = function() {
        return x + width;
    }
    
    /// @desc Returns the bottom edge.
    /// @returns {Real}
    bottom = function() {
        return y + height;
    }
    
    /// @desc Overwrites all fields in place, avoiding a new allocation.
    /// @param {Real} x
    /// @param {Real} y 
    /// @param {Real} width 
    /// @param {Real} height 
    set = function(x, y, width, height) {
        self.x = x;
        self.y = y;
        self.width = width;
        self.height = height;
    }
    
    /// @desc Returns the intersection of this rect with another rect.
    /// @param {Struct.PaxRect} rect
    /// @returns {Struct.PaxRect}
    intersect = function(rect) {
        return intersect_into(rect, new PaxRect(0, 0, 0, 0));
    }

    /// @desc Writes the intersection of this rect and another into an existing rect.
    /// @param {Struct.PaxRect} rect
    /// @param {Struct.PaxRect} out
    /// @returns {Struct.PaxRect}
    intersect_into = function(rect, out) {
        var x1 = max(x, rect.x);
        var y1 = max(y, rect.y);
        var x2 = min(x + width,  rect.x + rect.width);
        var y2 = min(y + height, rect.y + rect.height);

        if (x2 <= x1 || y2 <= y1) 
            out.set(0, 0, 0, 0);
        else 
            out.set(x1, y1, x2 - x1, y2 - y1);
        
        return out;
    }
}