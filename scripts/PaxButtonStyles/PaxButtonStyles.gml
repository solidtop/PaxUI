/// @desc Per-state styles for buttons. Construct and override individual states to make a variant.
function PaxButtonStyles() constructor {
    normal = PaxStyle.build_solid(#3F3F46);
    hovered = PaxStyle.build_solid(#52525B);
    pressed = PaxStyle.build_solid(#27272A);
    disabled = PaxStyle.build_solid(#3F3F46, 0.5);
    focused = PaxStyle.build_solid(#72525D);
}