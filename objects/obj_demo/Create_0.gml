root = new PaxRoot();

widget = new PaxWidget().fill().background(c_blue);

label = new PaxLabel("Label").align_self(PaxAlign.Center);
widget.add(label);

root.add(widget);
