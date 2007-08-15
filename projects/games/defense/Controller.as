package {

import flash.events.Event;
import flash.geom.Point;    

import com.whirled.WhirledGameControl;

public class Controller
{
    public function Controller (whirled :WhirledGameControl)
    {
        _whirled = whirled;
    }

    public function handleUnload (event : Event) :void
    {
        trace("CONTROLLER UNLOAD");
    }

    public function addTower (/* def :Tower */) :void
    {
        // sends a request to everyone to add a new tower
        _whirled.sendMessage(Validator.MSG_ADD, { foo: "bar" });
    }

    public function removeTower (/* def :Tower */) :void
    {
        // sends a request to everyone to remove a tower
    }

    public function updateTower (/* def :Tower */) :void
    {
        // sends a request to everyone to update a tower
    }
    
    protected var _whirled :WhirledGameControl;
}
}
