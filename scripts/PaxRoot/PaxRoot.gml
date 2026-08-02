/// @desc The root of a UI tree and the driver of its frame. Create one, add
/// widgets to it, call step() from the Step event and render() from Draw GUI.
function PaxRoot() : PaxWidget() constructor {
    fill();                                     
    pointer_filter = PaxPointerFilter.Ignore;  

    /// @ignore
    _updater = new PaxUpdater();
    /// @ignore
    _renderer = new PaxRenderer();
    /// @ignore
    _input = new PaxInputManager();

    /// @desc Advances input and layout. Call from the Step event.
    /// @param {Real} dt  Delta time in seconds; defaults to real frame time.
    static step = function(dt = delta_time / 1_000_000) {
        _input.process(self);
        _updater.update(self, dt);
    }

    /// @desc Renders the tree. Call from the Draw GUI event.
    static render = function() {
        _renderer.render(self);
    }
    
    static _draw = function(ctx) {
        
    }
}
