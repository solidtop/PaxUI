enum PaxUnit {
    Pixel,
    Percent,
    Auto
}

enum PaxEdge {
    Left,
    Top,
    Right,
    Bottom,
    Horizontal,
    Vertical,
    All
}

enum PaxDirection {
    Row,
    Column,
    RowReverse,
    ColumnReverse
}

enum PaxJustify {
    Start,
    Center,
    End,
    SpaceBetween,
    SpaceAround,
    SpaceEvenly
}

enum PaxAlign {
    Auto,
    Start,
    Center,
    End,
    Stretch,
    Baseline
}

enum PaxWrap {
    NoWrap,
    Wrap,
    WrapReverse
}

enum PaxAxis {
    Horizontal,
    Vertical,
    Both
}

enum PaxPosition {
    Relative,
    Absolute
}

enum PaxEventType {
    PointerPressed,
    PointerReleased,
    PointerMoved,
    PointerEntered,
    PointerExited,
    PointerCancelled,
    Scroll,
    KeyPressed,
    KeyReleased,
    FocusEntered,
    FocusExited,
    Accept
}

enum PaxPointerFilter {
    Stop,
    Pass,
    Ignore
}

enum PaxFocusMode {
    None,   
    Pointer,
    All   
}