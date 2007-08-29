package {

import flash.events.Event;
import flash.geom.Point;    
import flash.geom.Rectangle;

import com.whirled.WhirledGameControl;

public class Controller
{
    public function Controller (board :Board, whirled :WhirledGameControl)
    {
        _board = board;
        _whirled = whirled;
    }

    public function handleUnload (event : Event) :void
    {
        trace("CONTROLLER UNLOAD");
    }

    public function addTower (def :TowerDef) :void
    {
        var tower :Tower = new Tower(def, 42 /* todo */, Tower.makeGuid());
        var serialized :Object = Marshaller.serializeTower(tower);
        _whirled.sendMessage(Validator.REQUEST_ADD, serialized);
    }

    public function removeTower (/* def :Tower */) :void
    {
        // sends a request to everyone to remove a tower
    }

    public function updateTower (/* def :Tower */) :void
    {
        // sends a request to everyone to update a tower
    }

    protected var _board :Board;
    protected var _whirled :WhirledGameControl;
}
}
