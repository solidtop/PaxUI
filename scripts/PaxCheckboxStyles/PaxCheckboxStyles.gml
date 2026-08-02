/// @desc Per-state styles for checkboxes, plus the check mark's inset.
function PaxCheckboxStyles() constructor {
    box = PaxStyle.build_solid(#3F3F46);
    box_hovered = PaxStyle.build_solid(#52525B);
    box_focused = PaxStyle.build_solid(#72525D);
    box_disabled = PaxStyle.build_solid(#3F3F46, 0.5);
    box_checked = PaxStyle.build_solid(#6366F1);
    box_checked_hovered = PaxStyle.build_solid(#818CF8);
    check = PaxStyle.build_solid(#FFFFFF);
    check_inset = 6;
}
