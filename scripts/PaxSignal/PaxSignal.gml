/// @desc A signal: an observable event that widgets declare and emit.
function PaxSignal() constructor {
    /// @ignore
    _handlers = undefined;
    
    /// @desc Connects a handler.
    /// @param {Function} handler
    static connect = function(handler) {
        _handlers ??= [];
        array_push(_handlers, handler);
    }
    
    /// @desc Disconnects a handler.
    /// @param {Function} handler
    static disconnect = function(handler) {
        if (_handlers == undefined) return;
        var index = array_get_index(_handlers, handler);
        if (index != -1) array_delete(_handlers, index, 1);
    }
    
    /// @desc Emits the signal, invoking all handlers with the given payload
    /// @param {Any} payload
    static emit = function(payload) {
        if (_handlers == undefined) return;
        for (var i = 0; i < array_length(_handlers); i++) 
            _handlers[i](payload);
    }
}