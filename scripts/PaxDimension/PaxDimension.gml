/// @desc Value object representing a dimension (pixels, percent, or auto).
/// @param {Real} value
/// @param {Enum.PaxUnit} unit 
function PaxDimension(value, unit) constructor {
    self.value = value;
    self.unit = unit;
    
    /// @desc Parses a raw input (real, "N%", or "auto") into a PaxDimension
    /// @param {Real | String} input
    /// @returns {Struct.PaxDimension}
    static parse = function(input) {
        if (is_real(input)) 
            return new PaxDimension(input, PaxUnit.Pixel);
            
        if (is_string(input)) {
            if (input == "auto") 
                return new PaxDimension(0, PaxUnit.Auto);
            
            if (string_ends_with(input, "%")) {
                var number = real(string_copy(input, 1, string_length(input) - 1));
                return new PaxDimension(number, PaxUnit.Percent);
            }
            
            return new PaxDimension(real(input), PaxUnit.Pixel);
        }
        
        show_debug_message($"PaxUI: invalid dimension '{input}'. Expected a number, \"N%\", or \"auto\".");
    }    
}

new PaxDimension(0, PaxUnit.Pixel);
