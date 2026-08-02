/// @desc Keeps a set of radios mutually exclusive.
function PaxRadioGroup() constructor {
    /// @ignore
    _radios = [];
    /// @ignore
    _selected = undefined;

    changed = new PaxSignal();

    /// @desc Returns the selected radio, or undefined when none is.
    /// @returns {Struct.PaxRadio}
    static selected = function() {
        return _selected;
    }

    /// @desc Connects a handler to changed.
    /// @param {Function} handler
    /// @returns {Struct.PaxRadioGroup}
    static on_change = function(handler) {
        changed.connect(handler);
        return self;
    }

    /// @ignore 
    /// @param {Struct.PaxRadio} radio
    static _register = function(radio) {
        if (array_get_index(_radios, radio) == -1)
            array_push(_radios, radio);

        if (radio.is_checked()) _select(radio);
    }

    /// @ignore
    /// @param {Struct.PaxRadio} radio
    static _unregister = function(radio) {
        var index = array_get_index(_radios, radio);
        if (index != -1) array_delete(_radios, index, 1);
        if (_selected == radio) _selected = undefined;
    }

    /// @ignore 
    /// @param {Struct.PaxRadio} radio
    static _select = function(radio) {
        if (_selected == radio) return;
        _selected = radio;

        for (var i = array_length(_radios) - 1; i >= 0; i--) {
            var member = _radios[i];
            if (member.is_destroyed()) {
                array_delete(_radios, i, 1);
                continue;
            }

            if (member != radio) member.uncheck();
        }

        changed.emit(radio);
    }
}
