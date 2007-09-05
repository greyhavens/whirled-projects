package com.threerings.defense {

import flash.events.Event;
import flash.geom.Point;    
import flash.geom.Rectangle;

import com.whirled.WhirledGameControl;

import com.threerings.defense.units.Tower;
import com.threerings.defense.units.Unit;

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

    public function addTower (tower :Tower) :void
    {        
        var serialized :Object = tower.serialize();
        serialized.guid = Unit.makeGuid(); // give the request a brand new guid
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
