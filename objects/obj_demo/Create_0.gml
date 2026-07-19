display_set_gui_maximise();
updater = new PaxUpdater();
renderer = new PaxRenderer();
input = new PaxInputManager();
root = new PaxWidget();

scroll = new PaxScrollView().size("50%", "50%").background(c_gray).gap(10).padding(20).wrap()

repeat (50) {
	scroll.add(
        new PaxButton().size(200, 200).on_clicked(function() {
          show_debug_message("click");  
        })
    )
}

root.add(scroll);