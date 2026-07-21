display_set_gui_maximise();
updater = new PaxUpdater();
renderer = new PaxRenderer();
input = new PaxInputManager();
root = new PaxWidget();

button = new PaxButton().size(200, 50).background(c_red).transition(15);

button.focus_mode = PaxFocusMode.None;

root.add(button);