/// @desc Standard easing functions for PaxTween.ease().
function PaxEase() constructor {
    /// @desc Accelerates from rest.
    static in_quad = function(t) {
        return t * t;
    }

    /// @desc Decelerates to rest.
    static out_quad = function(t) {
        return 1 - (1 - t) * (1 - t);
    }

    /// @desc Accelerates then decelerates.
    static in_out_quad = function(t) {
        return t < 0.5 ? 2 * t * t : 1 - power(-2 * t + 2, 2) * 0.5;
    }

    /// @desc Accelerates from rest, more sharply than quad.
    static in_cubic = function(t) {
        return t * t * t;
    }

    /// @desc Decelerates to rest, more sharply than quad.
    static out_cubic = function(t) {
        return 1 - power(1 - t, 3);
    }

    /// @desc Accelerates then decelerates, more sharply than quad.
    static in_out_cubic = function(t) {
        return t < 0.5 ? 4 * t * t * t : 1 - power(-2 * t + 2, 3) * 0.5;
    }

    /// @desc Overshoots the end slightly, then settles back.
    static out_back = function(t) {
        var c1 = 1.70158;
        var c3 = c1 + 1;
        return 1 + c3 * power(t - 1, 3) + c1 * power(t - 1, 2);
    }

    /// @desc Springs past the end and oscillates to rest.
    static out_elastic = function(t) {
        if (t <= 0) return 0;
        if (t >= 1) return 1;
        var c4 = (2 * pi) / 3;
        return power(2, -10 * t) * sin((t * 10 - 0.75) * c4) + 1;
    }

    /// @desc Bounces against the end like a dropped ball.
    static out_bounce = function(t) {
        var n1 = 7.5625;
        var d1 = 2.75;

        if (t < 1 / d1) return n1 * t * t;
        if (t < 2 / d1) {
            t -= 1.5 / d1;
            return n1 * t * t + 0.75;
        }
        if (t < 2.5 / d1) {
            t -= 2.25 / d1;
            return n1 * t * t + 0.9375;
        }
        t -= 2.625 / d1;
        return n1 * t * t + 0.984375;
    }
}

new PaxEase();