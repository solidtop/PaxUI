/// @desc Builds the buttons showcase into the given container.
/// @param {Struct.PaxWidget} container
function demo_buttons(container) {
    container.column().gap(16);

    container.add(new PaxLabel("Buttons"));

    container.add(new PaxButton().text("Default").width(200).height(44)
        .on_clicked(function() { show_debug_message("clicked Default"); }));

    container.add(new PaxButton().text("Disabled").width(200).height(44).disable());

    var button_row = new PaxWidget().row().gap(12);
    button_row.add(new PaxButton().text("One").width(90).height(40));
    button_row.add(new PaxButton().text("Two").width(90).height(40));
    button_row.add(new PaxButton().text("Three").width(90).height(40));
    container.add(button_row);
}

/// @desc Builds the sliders showcase into the given container.
/// @param {Struct.PaxWidget} container
function demo_sliders(container) {
    container.column().gap(28);

    container.add(new PaxLabel("Sliders"));

    container.add(new PaxSlider().width(320).range(0, 100).value(50));

    var custom_styles = new PaxSliderStyles();
    custom_styles.track = PaxStyle.build_solid(#1E293B);  
    custom_styles.fill = PaxStyle.build_solid(#22C55E);   
    custom_styles.handle = PaxStyle.build_solid(#FACC15);  
    custom_styles.handle_hovered = PaxStyle.build_solid(#FDE047);
    custom_styles.handle_focused = PaxStyle.build_solid(#FEF08A);
    custom_styles.track_height = 14;                       
    custom_styles.handle_size  = 30;         
    container.add(new PaxSlider().width(320).range(0, 1).value(0.3).step(0.1)
        .styled(custom_styles));
}

/// @desc Builds the labels showcase into the given container.
/// @param {Struct.PaxWidget} container
function demo_labels(container) {
    container.column().gap(16);

    container.add(new PaxLabel("Labels"));
    container.add(new PaxLabel("Left aligned").width(420).align_text(fa_left));
    container.add(new PaxLabel("Centered").width(420).align_text(fa_center));
    container.add(new PaxLabel("Right aligned").width(420).align_text(fa_right));
    container.add(new PaxLabel(
        "A longer paragraph that wraps across several lines within the width "
      + "given to it, so you can see how measured text flows in the layout.")
        .width(420));
}

/// @desc A control paired with a label, vertically centred in a row.
/// @param {Struct.PaxWidget} control
/// @param {String} text
/// @returns {Struct.PaxWidget}
function labeled_control(control, text) {
    var row = new PaxWidget().row().gap(12).align(PaxAlign.Center);
    row.add(control);
    row.add(new PaxLabel(text));
    return row;
}

/// @desc Builds the checkbox showcase into the given container.
/// @param {Struct.PaxWidget} container
function demo_checkbox(container) {
    container.column().gap(16);

    container.add(new PaxLabel("Checkboxes"));

    container.add(labeled_control(new PaxCheckbox().check(), "Checked"));
    container.add(labeled_control(new PaxCheckbox(), "Unchecked"));
    container.add(labeled_control(
        new PaxCheckbox().on_toggled(function(is_checked) {
            show_debug_message("checkbox: " + string(is_checked));
        }),
        "With handler (see console)"));
    container.add(labeled_control(new PaxCheckbox().disable(), "Disabled"));
}

/// @desc Builds the toggle showcase into the given container.
/// @param {Struct.PaxWidget} container
function demo_toggle(container) {
    container.column().gap(16);

    container.add(new PaxLabel("Toggles"));

    container.add(labeled_control(new PaxToggle().check(), "On"));
    container.add(labeled_control(new PaxToggle(), "Off"));
    container.add(labeled_control(
        new PaxToggle().on_toggled(function(is_on) {
            show_debug_message("toggle: " + string(is_on));
        }),
        "With handler (see console)"));
    container.add(labeled_control(new PaxToggle().disable(), "Disabled"));
}

/// @desc Builds the radio buttons showcase into the given container.
/// @param {Struct.PaxWidget} container
function demo_radios(container) {
    container.column().gap(16);

    container.add(new PaxLabel("Radios"));

    // one group keeps the options mutually exclusive
    var size_group = new PaxRadioGroup();

    container.add(labeled_control(
        new PaxRadio().named("Small").group(size_group).check(), "Small"));
    container.add(labeled_control(
        new PaxRadio().named("Medium").group(size_group), "Medium"));
    container.add(labeled_control(
        new PaxRadio().named("Large").group(size_group), "Large"));
    container.add(labeled_control(
        new PaxRadio().named("Disabled").group(size_group).disable(), "Disabled"));

    // connect after the initial .check() so only user selections log
    size_group.on_change(function(selected) {
        show_debug_message("selected: " + selected.name);
    });
}

/// @desc Builds the text input showcase into the given container.
/// @param {Struct.PaxWidget} container
function demo_text_input(container) {
    container.column().gap(16);

    container.add(new PaxLabel("Text Input"));

    container.add(new PaxTextInput().width(340).placeholder("Type your name..."));

    container.add(new PaxTextInput().width(340).text("Editable text")
        .on_changed(function(value) { show_debug_message("changed: " + value); }));

    container.add(new PaxTextInput().width(340).placeholder("Press Enter to submit")
        .on_submitted(function(value) { show_debug_message("submitted: " + value); }));

    container.add(new PaxTextInput().width(340).text("Disabled").disable());
}

/// @desc A coloured box of the given size, for the layout demos.
/// @param {Constant.Colour} colour
/// @param {Real} box_width
/// @param {Real} box_height
/// @returns {Struct.PaxWidget}
function demo_box(colour, box_width, box_height) {
    return new PaxWidget().size(box_width, box_height).background(colour);
}

/// @desc Builds the layout showcase into the given container.
/// @param {Struct.PaxWidget} container
function demo_layout(container) {
    container.column().gap(18);

    container.add(new PaxLabel("Layout"));

    container.add(new PaxLabel("Row with gap"));
    var gapped_row = new PaxWidget().row().gap(8).height(48);
    repeat (4) gapped_row.add(demo_box(#6366F1, 48, 48));
    container.add(gapped_row);

    container.add(new PaxLabel("Justify: space-between"));
    var spaced_row = new PaxWidget().row().width(420).height(48).justify(PaxJustify.SpaceBetween);
    repeat (3) spaced_row.add(demo_box(#22C55E, 48, 48));
    container.add(spaced_row);

    container.add(new PaxLabel("Align: centre (uneven heights)"));
    var aligned_row = new PaxWidget().row().gap(8).width(420).height(80).align(PaxAlign.Center);
    aligned_row.add(demo_box(#F59E0B, 40, 40));
    aligned_row.add(demo_box(#F59E0B, 40, 70));
    aligned_row.add(demo_box(#F59E0B, 40, 55));
    container.add(aligned_row);

    container.add(new PaxLabel("Flex: 1 / 2 / 1"));
    var flex_row = new PaxWidget().row().gap(8).width(420).height(48);
    flex_row.add(new PaxWidget().height(48).background(#EF4444).flex(1));
    flex_row.add(new PaxWidget().height(48).background(#3B82F6).flex(2));
    flex_row.add(new PaxWidget().height(48).background(#8B5CF6).flex(1));
    container.add(flex_row);

    container.add(new PaxLabel("Nested: column inside a row"));
    var nested_row = new PaxWidget().row().gap(8).width(420).height(100);
    nested_row.add(demo_box(#EC4899, 60, 100));
    var inner_column = new PaxWidget().column().gap(8).expand();
    inner_column.add(new PaxWidget().background(#14B8A6).flex(1));
    inner_column.add(new PaxWidget().background(#F97316).flex(1));
    nested_row.add(inner_column);
    container.add(nested_row);
}

/// @desc Builds the animation showcase into the given container.
/// @param {Struct.PaxWidget} container
function demo_animation(container) {
    container.column().gap(20);

    container.add(new PaxLabel("Animation"));
    container.add(new PaxLabel("Click a control to animate the box."));

    var box = new PaxWidget().size(80, 80).background(#6366F1);
    var stage = new PaxWidget().width(420).height(140).padding(30);
    stage.add(box);
    container.add(stage);

    var controls = new PaxWidget().row().gap(10).wrap();

    controls.add(new PaxButton().text("Slide").height(40).padding(10).on_clicked(method({ box }, function() {
        var transform = box.transform();
        pax_tweens().stop_target(transform);
        transform.x = 0;
        new PaxTween(transform, "x", 220, 0.5).ease(PaxEase.out_cubic)
            .chain(transform, "x", 0, 0.5).ease(PaxEase.out_cubic);
    })));

    controls.add(new PaxButton().text("Pop").height(40).padding(10).on_clicked(method({ box }, function() {
        var transform = box.transform();
        pax_tweens().stop_target(transform);
        transform.scale_x = 1;
        transform.scale_y = 1;
        new PaxTween(transform, "scale_x", 1.4, 0.15).ease(PaxEase.out_back)
            .chain(transform, "scale_x", 1, 0.25);
        new PaxTween(transform, "scale_y", 1.4, 0.15).ease(PaxEase.out_back)
            .chain(transform, "scale_y", 1, 0.25);
    })));

    controls.add(new PaxButton().text("Spin").height(40).padding(10).on_clicked(method({ box }, function() {
        var transform = box.transform();
        pax_tweens().stop_target(transform);
        transform.angle_z = 0;
        new PaxTween(transform, "angle_z", 360, 0.6).ease(PaxEase.out_cubic);
    })));

    controls.add(new PaxButton().text("Shake").height(40).padding(10).on_clicked(method({ box }, function() {
        var transform = box.transform();
        pax_tweens().stop_target(transform);
        transform.x = 0;
        new PaxTween(transform, "x", -12, 0.05)
            .chain(transform, "x", 12, 0.1)
            .chain(transform, "x", -8, 0.1)
            .chain(transform, "x", 8, 0.1)
            .chain(transform, "x", 0, 0.05);
    })));

    controls.add(new PaxButton().text("Fade").height(40).padding(10).on_clicked(method({ box }, function() {
        pax_tweens().stop_target(box.style);
        box.style.alpha = 1;
        new PaxTween(box.style, "alpha", 0.2, 0.3)
            .chain(box.style, "alpha", 1, 0.4);
    })));

    container.add(controls);
}
