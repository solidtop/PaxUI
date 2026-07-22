//display_set_gui_maximise();
updater = new PaxUpdater();
renderer = new PaxRenderer();
input = new PaxInputManager();
root = new PaxWidget();

widget = new PaxWidget().size(500, 500).background(c_blue);

new PaxTween(widget.transform(), "x", 500, 4).chain(widget.transform(), "x", 200, 3);

root.add(widget);