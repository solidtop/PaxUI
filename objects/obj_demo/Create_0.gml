display_set_gui_maximise();
updater = new PaxUpdater();
renderer = new PaxRenderer();
root = new PaxWidget();

widget = new PaxWidget().size(400, 400).clip().background(c_gray);

repeat (40) {
	widget.add(
        new PaxWidget().size(100, 100).background(c_green).clip().add(
            new PaxWidget().size(200, 50).background(c_red)
        )
    )
}

root.add(widget);