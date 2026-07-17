display_set_gui_maximise();
updater = new PaxUpdater();
renderer = new PaxRenderer();
root = new PaxWidget();

widget = new PaxWidget().size(400, 400).padding(40).clip().background(c_gray);

repeat (100) {
	widget.add(
        new PaxWidget().size(100, 100).background(c_green)
    )
}

root.add(widget);