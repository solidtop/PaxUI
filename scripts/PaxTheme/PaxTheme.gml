/// @desc A theme: shared style presets that widgets reference by default.
function PaxTheme() constructor {
    widget = new PaxStyle();
    label = PaxStyle.build_text(c_black);
    button = new PaxButtonStyles();
    slider = new PaxSliderStyles();
    checkbox = new PaxCheckboxStyles();
    radio = new PaxRadioStyles();
    toggle = new PaxToggleStyles();
}

/// @desc Returns the active theme; pass one to make it active.
/// @param {Struct.PaxTheme} theme
/// @returns {Struct.PaxTheme}
function pax_theme(theme = undefined) {
    static current = new PaxTheme();
    if (theme != undefined) current = theme;
    return current;
}
