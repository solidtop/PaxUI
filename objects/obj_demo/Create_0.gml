display_set_gui_maximise();

root = new PaxRoot();

default_slider = new PaxSlider()
    .width(300)
    .range(0, 100)
    .value(40)
    .on_change(function(new_value) {
        show_debug_message("default: " + string(new_value));
    });

var custom_styles = new PaxSliderStyles();
custom_styles.track = PaxStyle.build_solid(#1E293B);  
custom_styles.fill = PaxStyle.build_solid(#22C55E);   
custom_styles.handle = PaxStyle.build_solid(#FACC15);  
custom_styles.handle_hovered = PaxStyle.build_solid(#FDE047);
custom_styles.handle_focused = PaxStyle.build_solid(#FEF08A);
custom_styles.track_height = 14;                       
custom_styles.handle_size  = 30;                     

custom_slider = new PaxSlider()
    .width(300)
    .range(0, 1)
    .value(0.25)
    .step(0.1)                                        
    .styled(custom_styles)
    .transition(15)
    .on_change(function(new_value) {
        show_debug_message("custom: " + string(new_value));
    });

root.column().gap(30).center();
root.add(default_slider);
root.add(custom_slider);

root.add(new PaxButton().size(300, 100).text("Button"))
