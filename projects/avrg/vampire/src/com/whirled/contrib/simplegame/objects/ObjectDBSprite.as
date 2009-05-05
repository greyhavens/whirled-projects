package com.whirled.contrib.simplegame.objects
{
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
 * Used for SceneObjects that themselves have sub-components.
 * Also for a stand-alone ObjectDB.  To get it updating, add it to the display hierarchy.
 *
 */
public class ObjectDBSprite extends ObjectDB
{
    public function ObjectDBSprite ()
    {

//        _events.registerListener(this, Event.ENTER_FRAME, handleEnterFrame);
        _events.registerListener(_displaySprite, Event.ADDED, handleAdded);
        _events.registerListener(_displaySprite, Event.REMOVED, handleRemoved)
    }

    protected function handleRemoved (e :Event) :void
    {
        _events.unregisterListener(_displaySprite, Event.ENTER_FRAME, handleEnterFrame);
    }

//    /**
//    * If we are updated from a parent ObjectDB, don't listen to enterFrame events.
//    */
//    override protected function addedToDB () :void
//    {
//        super.addedToDB();
//        _events.unregisterListener(_displaySprite, Event.ENTER_FRAME, handleEnterFrame);
//    }

    public function get sprite () :Sprite
    {
        return _displaySprite;
    }

    /**
     * A convenience function that adds the given SceneObject to the mode and attaches its
     * DisplayObject to the display list.
     *
     * @param displayParent the parent to attach the DisplayObject to, or null to attach
     * directly to the AppMode's modeSprite.
     */
    public function addSceneObject (obj :SimObject, displayParent :DisplayObjectContainer = null)
        :SimObjectRef
    {
        if (!(obj is SceneComponent)) {
            throw new Error("obj must implement SceneComponent");
        }

        // Attach the object to a display parent.
        // (This is purely a convenience - the client is free to do the attaching themselves)
        var disp :DisplayObject = (obj as SceneComponent).displayObject;
        if (null == disp) {
            throw new Error("obj must return a non-null displayObject to be attached " +
                            "to a display parent");
        }

        if (displayParent == null) {
            displayParent = _displaySprite;
        }
        displayParent.addChild(disp);

        return addObject(obj);
    }

    override public function destroyObject (ref :SimObjectRef) :void
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

        super.destroyObject(ref);
    }



    protected function handleAdded (e :Event) :void
    {
        _lastTime = elapsedSeconds;
        _events.registerListener(_displaySprite, Event.ENTER_FRAME, handleEnterFrame);
//        if (db == null) {
//        }
//        _events.registerListener(this, Event.REMOVED, handleRemoved);
    }

    protected function handleEnterFrame (e :Event) :void
    {
        // how much time has elapsed since last frame?
        var newTime :Number = this.elapsedSeconds;
        var dt :Number = newTime - _lastTime;
        update(dt);
        _lastTime = newTime;
    }

//    /** Returns the number of seconds that have elapsed since the application started. */
    public function get elapsedSeconds () :Number
    {
        return (getTimer() / 1000); // getTimer() returns a value in milliseconds
    }

    override protected function shutdown () :void
    {
        if (sprite.parent != null) {
            sprite.parent.removeChild(sprite);
        }
        super.shutdown();
    }

    public function destroySelf () :void
    {
        shutdown();
    }

    protected var _displaySprite :Sprite = new Sprite();

    protected var _lastTime :Number = 0;
}
}