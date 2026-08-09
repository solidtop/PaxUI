/// @desc Per-state box styles for a text input, plus the text, placeholder,
/// caret colour and inner padding.
function PaxTextInputStyles() constructor {
    box = PaxStyle.build_solid(#27272A);
    box_hovered = PaxStyle.build_solid(#3F3F46);
    box_focused = PaxStyle.build_solid(#3F3F46);
    box_disabled = PaxStyle.build_solid(#27272A, 0.5);
    text = PaxStyle.build_text(#E4E4E7);
    placeholder = PaxStyle.build_text(#71717A);
    caret_colour = #E4E4E7;
    selection_colour = #3B5BDB;
    padding = 10;
}
