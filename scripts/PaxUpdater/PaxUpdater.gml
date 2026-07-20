/// @desc Updates widget trees.
function PaxUpdater() constructor {
    
    /// @desc Updates the widget tree.
    /// @param {Struct.PaxWidget} root
    /// @param {Real} dt Delta time in seconds
    static update = function(root, dt) {
        var gui_width = display_get_gui_width();
        var gui_height = display_get_gui_height();
        root._layout.calculate(gui_width, gui_height);
        _update_tree(root, dt);
    }

    /// @ignore
    /// @param {Struct.PaxWidget} widget
    /// @param {Real} dt
    static _update_tree = function(widget, dt) {
        widget._layout.read_bounds(widget.bounds, widget.content_bounds);
        widget._update(dt);

        var children = widget.children;
        for (var i = 0; i < array_length(children); i++) 
        	_update_tree(children[i], dt);
    }
}