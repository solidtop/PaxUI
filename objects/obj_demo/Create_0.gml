updater = new PaxUpdater();
renderer = new PaxRenderer();
root = new PaxWidget();

root.add(new PaxWidget().size(200, 200).background(c_blue).add(
    new PaxWidget().size("50%", "50%").background(c_red)
));
