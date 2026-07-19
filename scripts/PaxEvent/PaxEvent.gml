/// @desc Base class for all UI input events.
/// Events are pooled and reused across frames — handlers must not retain them.
/// Call consume() to stop propagation.
function PaxEvent() constructor {
    type = undefined;
    consumed = false;
    stolen = false;

    /// @desc Marks this event as consumed — stops further propagation.
    static consume = function() {
        consumed = true;
    }

    /// @desc Requests ownership of the active pointer gesture for the widget currently handling this event. 
    static steal = function() {
        stolen = true;
    }

    /// @desc Prepares this event for redispatch as the given type.
    /// @param {Enum.PaxEventType} type
    static reset = function(type) {
        self.type = type;
        consumed = false;
        stolen = false;
    }
}

/// @desc A pointer event: press, release, move, enter, exit, cancel or scroll.
/// press_x/press_y hold the gesture origin — valid while a button is held.
function PaxPointerEvent() : PaxEvent() constructor {
    x = 0;
    y = 0;
    press_x = 0;
    press_y = 0;
    button = mb_none;
    delta_x = 0;
    delta_y = 0;
    scroll = 0;
}

/// @desc A keyboard event: key press or release.
function PaxKeyEvent() : PaxEvent() constructor {
    key = vk_nokey;
    char = "";
}
