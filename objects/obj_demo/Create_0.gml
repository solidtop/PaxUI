updater = new PaxUpdater();
renderer = new PaxRenderer();
root = new PaxWidget();

root.add(new PaxWidget().size(200, 200).background(c_blue).center().rotate(20).add(
    new PaxWidget().size("50%", "50%").background(c_red)
));