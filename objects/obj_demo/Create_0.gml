display_set_gui_maximise();

root = new PaxRoot();

panel = new PaxWidget().size("30%", 500).background(c_gray);

label = new PaxLabel("This is a test label").colour(c_red).align_text(fa_center);

panel.add(label);
root.add(panel);