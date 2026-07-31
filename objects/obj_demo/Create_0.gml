display_set_gui_maximise();

root = new PaxRoot();

// --- a themed slider (uses pax_theme().slider) ---
default_slider = new PaxSlider()
    .width(300)
    .range(0, 100)
    .value(40)
    .on_change(function(new_value) {
        show_debug_message("default: " + string(new_value));
    });

// --- a custom-styled slider: parts, colours, and sizes ---
var custom_style = new PaxSliderStyle();
custom_style.track  = PaxStyle.build_solid(#1E293B);   // dark slate track
custom_style.fill   = PaxStyle.build_solid(#22C55E);   // green fill
custom_style.handle = PaxStyle.build_solid(#FACC15);   // yellow handle
custom_style.track_height = 14;                          // thicker track
custom_style.handle_size  = 30;                          // bigger grabber

custom_slider = new PaxSlider()
    .width(300)
    .range(0, 1)
    .value(0.25)
    .step(0.1)                                           // arrow keys nudge by 0.1
    .styled_parts(custom_style)
    .on_change(function(new_value) {
        show_debug_message("custom: " + string(new_value));
    });

root.column().gap(30).center();
root.add(default_slider);
root.add(custom_slider);
