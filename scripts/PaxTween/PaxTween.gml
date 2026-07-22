/// @desc  Animates a numeric property of a struct to a value over a duration.
/// @param {Struct} target 
/// @param {String} property 
/// @param {Real} to 
/// @param {Real} duration 
function PaxTween(target, property, to, duration) constructor {
    /// @ignore
    _target = target;
    /// @ignore
    _property = property;
    /// @ignore
    _from = undefined;
    /// @ignore
    _to = to;
    /// @ignore
    _duration = max(duration, 0.0001);
    /// @ignore
    _delay = 0;
    /// @ignore
    _wait = 0;
    /// @ignore
    _play_from = 0;
    /// @ignore
    _ease = undefined;
    /// @ignore
    _elapsed = 0;
    /// @ignore
    _started = false;
    /// @ignore
    _done = false;
    /// @ignore
    _next = undefined;

    pax_tweens()._add(self);
    
    finished = new PaxSignal();

    /// @desc Sets the starting value explicitly.
    /// @param {Real} value
    /// @returns {Struct.PaxTween}
    static from = function(value) {
        _from = value;
        return self;
    }

    /// @desc Delays the start by the given seconds.
    /// @param {Real} seconds
    /// @returns {Struct.PaxTween}
    static delay = function(seconds) {
        _delay = seconds;
        _wait = seconds;
        return self;
    }

    /// @desc Shapes the tween with an animation curve channel, or a
    /// function mapping progress 0-1 to eased progress (see PaxEase).
    /// @param {Asset.GMAnimCurve | Function} curve_or_function
    /// @returns {Struct.PaxTween}
    static ease = function(curve_or_function) {
        _ease = curve_or_function;
        return self;
    }

    /// @desc Connects a handler to the finished signal.
    /// @param {Function} handler
    /// @returns {Struct.PaxTween}
    static on_finished = function(handler) {
        finished.connect(handler);
        return self;
    }

    /// @desc Chains a follow-up tween that begins when this one finishes.
    /// @param {Struct} target
    /// @param {String} property
    /// @param {Real} to
    /// @param {Real} duration
    /// @returns {Struct.PaxTween}
    static chain = function(target, property, to, duration) {
        var segment = new PaxTween(target, property, to, duration);
        segment.stop(); // dormant until this tween completes
        _next = segment;
        return segment;
    }

    /// @desc Stops the tween where it is, without finishing. Cascades to any
    /// queued segments, ending the whole chain.
    /// @returns {Struct.PaxTween}
    static stop = function() {
        _done = true;
        if (_next != undefined) _next.stop();
        return self;
    }

    /// @desc Restarts from the beginning, including any delay.
    /// @returns {Struct.PaxTween}
    static restart = function() {
        _elapsed = 0;
        _wait = _delay;
        _started = false;
        _done = false;
        pax_tweens()._add(self);
        return self;
    }

    /// @desc Jumps to the end value and emits finished.
    /// @returns {Struct.PaxTween}
    static complete = function() {
        if (_done) return self;
        _target[$ _property] = _to;
        _done = true;
        finished.emit(self);
        if (_next != undefined) _next.restart();
        return self;
    }

    /// @ignore Advances the tween; returns true while still running.
    /// @param {Real} dt
    /// @returns {Bool}
    static _update = function(dt) {
        if (_done) return false;

        if (_wait > 0) {
            _wait -= dt;
            if (_wait > 0) return true;
            dt = -_wait;
            _wait = 0;
        }

        if (!_started) {
            _started = true;
            _play_from = _from ?? _target[$ _property];
        }

        _elapsed += dt;
        if (_elapsed >= _duration) {
            complete();
            return false;
        }

        var t = _elapsed / _duration;
        if (_ease != undefined)
            t = is_callable(_ease) ? _ease(t) : animcurve_channel_evaluate(_ease, t);

        _target[$ _property] = lerp(_play_from, _to, t);
        return true;
    }
}

/// @desc Ticks active tweens; accessed through pax_tweens().
function PaxTweenManager() constructor {
    /// @ignore
    _tweens = [];

    /// @desc Advances all active tweens, removing finished ones.
    /// @param {Real} dt
    static update = function(dt) {
        for (var i = array_length(_tweens) - 1; i >= 0; i--) {
            if (!_tweens[i]._update(dt))
                array_delete(_tweens, i, 1);
        }
    }

    /// @desc Stops every tween animating the given struct.
    /// @param {Struct} target
    static stop_target = function(target) {
        for (var i = array_length(_tweens) - 1; i >= 0; i--) {
            if (_tweens[i]._target == target) {
                _tweens[i].stop();
                array_delete(_tweens, i, 1);
            }
        }
    }

    /// @ignore
    /// @param {Struct.PaxTween} tween
    static _add = function(tween) {
        if (array_get_index(_tweens, tween) == -1)
            array_push(_tweens, tween);
    }
}

/// @desc Returns the tween manager singleton.
/// @returns {Struct.PaxTweenManager}
function pax_tweens() {
    static manager = new PaxTweenManager();
    return manager;
}
