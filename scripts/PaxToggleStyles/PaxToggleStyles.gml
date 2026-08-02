/// @desc Per-state styles for toggles, plus the knob's inset and slide timing.
function PaxToggleStyles() constructor {
    track = PaxStyle.build_solid(#3F3F46);
    track_hovered = PaxStyle.build_solid(#52525B);
    track_focused = PaxStyle.build_solid(#72525D);
    track_disabled = PaxStyle.build_solid(#3F3F46, 0.5);
    track_checked = PaxStyle.build_solid(#22C55E);
    track_checked_hovered = PaxStyle.build_solid(#4ADE80);
    knob = PaxStyle.build_solid(#E4E4E7);
    knob_hovered = PaxStyle.build_solid(#FFFFFF);
    knob_inset = 3;
    slide_duration = 0.18;
}
