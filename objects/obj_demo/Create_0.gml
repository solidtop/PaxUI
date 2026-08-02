display_set_gui_maximise();

root = new PaxRoot().row();

// sidebar: a scrollable column of demo buttons
sidebar = new PaxScrollView().width(200).background(#18181B).padding(12).gap(8).column();

// content: fills the rest, repopulated when a demo is picked
content = new PaxWidget().expand().padding(28);

root.add(sidebar).add(content);

demos = [
    { name: "Buttons", build: demo_buttons },
    { name: "Sliders", build: demo_sliders },
    { name: "Labels", build: demo_labels },
    { name: "Checkboxes", build: demo_checkbox },
    { name: "Toggles", build: demo_toggle },
    { name: "Radios", build: demo_radios },
    { name: "Layout", build: demo_layout },
    { name: "Animation", build: demo_animation },
];

// one nav button per demo; clicking swaps the content
for (var i = 0; i < array_length(demos); i++) {
    var demo = demos[i];
    var nav_button = new PaxButton().text(demo.name).height(40);
    nav_button.on_clicked(method({ content: content, demo: demo }, function(sender) {
        content.clear();
        demo.build(content);
    }));
    sidebar.add(nav_button);
}

// show the first demo on start
demos[0].build(content);
