/// @desc Visual transform (translation, rotation, scale) applied around a pivot.
function PaxTransform() constructor {
    /// @ignore
    _m_to_pivot = matrix_build_identity();
    /// @ignore
    _m_transform = matrix_build_identity();
    /// @ignore
    _m_from_pivot = matrix_build_identity();
    
    x = 0; 
    y = 0; 
    z = 0;
    angle_x = 0; 
    angle_y = 0; 
    angle_z = 0;
    scale_x = 1; 
    scale_y = 1; 
    scale_z = 1; 
    origin_x = 0.5; 
    origin_y = 0.5; 
    origin_z = 0; 
    
    /// @desc Returns whether this transform has no effect.
    /// @returns {Bool}
    is_identity = function() {
        return x == 0 && y == 0 && z == 0 && is_translation_only();
    }

    /// @desc Returns whether this transform only translates (no rotation or scale).
    /// @returns {Bool}
    is_translation_only = function() {
        return angle_x == 0 && angle_y == 0 && angle_z == 0
            && scale_x == 1 && scale_y == 1 && scale_z == 1;
    }

    /// @desc Builds the transform matrix, pivoting within the given rect.
    /// @param {Struct.PaxRect} rect
    /// @returns {Array<Real>}
    build_matrix = function(rect) {
        var px = rect.x + rect.width * origin_x;
        var py = rect.y + rect.height * origin_y;
        var pz = origin_z;
        
        matrix_build(-px, -py, -pz, 0, 0, 0, 1, 1, 1, _m_to_pivot);
        matrix_build(x, y, z, angle_x, angle_y, angle_z, scale_x, scale_y, scale_z, _m_transform);
        matrix_build(px, py, pz,  0, 0, 0, 1, 1, 1, _m_from_pivot); 
        
        matrix_multiply(_m_transform, _m_from_pivot, _m_from_pivot);   
        matrix_multiply(_m_to_pivot,  _m_from_pivot, _m_to_pivot);    
        
        return _m_to_pivot;
    }
}