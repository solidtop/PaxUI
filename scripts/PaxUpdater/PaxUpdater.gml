/// @desc Updates widget trees.
function PaxUpdater() constructor {
    
    /// @desc Updates the widget tree.
    /// @param {Struct.PaxWidget} root
    /// @param {Real} dt Delta time in seconds
    update = function(root, dt) {
        var gui_width = display_get_gui_width();
        var gui_height = display_get_gui_height();
        root.layout.calculate(gui_width, gui_height);
        
        _update_widget_tree(root, dt);
    }
    
    /// @ignore
    /// @param {Struct.PaxWidget} widget 
    /// @param {Real} dt
    _update_widget_tree = function(widget, dt) {
        widget._update(dt);
        
        var children = widget.children;
        for (var i = 0; i < array_length(children); i++) {
        	_update_widget_tree(children[i], dt);
        }
    }
}