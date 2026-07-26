/// @desc A theme: shared style presets that widgets reference by default.
function PaxTheme() constructor {
    widget = new PaxStyle();
    button = new PaxButtonStyle();

    label = new PaxStyle();
    label.colour = c_black;
}

/// @desc Returns the active theme; pass one to make it active.
/// @param {Struct.PaxTheme} theme
/// @returns {Struct.PaxTheme}
function pax_theme(theme = undefined) {
    static current = new PaxTheme();
    if (theme != undefined) current = theme;
    return current;
}
