package com.whirled.contrib.simplegame.objects
{
import com.whirled.contrib.EventHandlerManager;
import com.whirled.contrib.simplegame.ObjectDB;
import com.whirled.contrib.simplegame.SimObject;
import com.whirled.contrib.simplegame.SimObjectRef;
import com.whirled.contrib.simplegame.components.SceneComponent;

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.Sprite;
import flash.events.Event;
import flash.utils.getTimer;

/**
 * Mostly for debugging.
 *
 */
public class SpriteObjectDB extends Sprite
{
    public function SpriteObjectDB ()
    {
        _events.registerListener(this, Event.ADDED, handleAdded);
    }

    protected function handleAdded (e :Event) :void
    {
        _events.registerListener(this, Event.ENTER_FRAME, handleEnterFrame);
        _events.registerListener(this, Event.REMOVED, handleRemoved);
    }

    /**
    * If we are removed, destroy ourselved completely.
    */
    protected function handleRemoved (e :Event) :void
    {
        shutdown();
    }

    protected function handleEnterFrame (e :Event) :void
    {
        // how much time has elapsed since last frame?
        var newTime :Number = this.elapsedSeconds;
        var dt :Number = newTime - _lastTime;
        _db.update(dt);
        _lastTime = newTime;
    }

    /** Returns the number of seconds that have elapsed since the application started. */
    public function get elapsedSeconds () :Number
    {
        return (getTimer() / 1000); // getTimer() returns a value in milliseconds
    }

    public function addSimObject (obj :SimObject,
        displayParent :DisplayObjectContainer = null) :SimObjectRef
    {
        if (obj is SceneComponent) {
            // Attach the object to a display parent.
            var disp :DisplayObject = (obj as SceneComponent).displayObject;
            if (null == disp) {
                throw new Error("obj must return a non-null displayObject to be attached " +
                                "to a display parent");
            }

            if (displayParent == null) {
                displayParent = this;
            }
            displayParent.addChild(disp);
        }
        return _db.addObject(obj);
    }

    public function shutdown () :void
    {
        _events.freeAllHandlers();
        _db.shutdown();
        if (this.parent != null) {
            this.parent.removeChild(this);
        }
    }

    public function destroyObject (ref :SimObjectRef) :void
    {
        if (null != ref && null != ref.object) {
            // if the object is attached to a DisplayObject, and if that
            // DisplayObject is in a display list, remove it from the display list
            // so that it will no longer be drawn to the screen
            var sc :SceneComponent = (ref.object as SceneComponent);
            if (null != sc) {
                var displayObj :DisplayObject = sc.displayObject;
                if (null != displayObj) {
                    var parent :DisplayObjectContainer = displayObj.parent;
                    if (null != parent) {
                        parent.removeChild(displayObj);
                    }
                }
            }
        }

        _db.destroyObject(ref);
    }

    public function get db () :ObjectDB
    {
        return _db;
    }

    protected var _lastTime :Number;
    protected var _db :ObjectDB = new ObjectDB();
    protected var _events :EventHandlerManager = new EventHandlerManager();
}
}