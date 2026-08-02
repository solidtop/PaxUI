/// @desc Per-state styles for radios, plus the dot's inset.
function PaxRadioStyles() constructor {
    indicator = PaxStyle.build_solid(#3F3F46);
    indicator_hovered = PaxStyle.build_solid(#52525B);
    indicator_focused = PaxStyle.build_solid(#72525D);
    indicator_disabled = PaxStyle.build_solid(#3F3F46, 0.5);
    indicator_checked = PaxStyle.build_solid(#6366F1);
    indicator_checked_hovered = PaxStyle.build_solid(#818CF8);
    dot = PaxStyle.build_solid(#FFFFFF);
    dot_inset = 7;
}
