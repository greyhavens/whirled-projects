package com.whirled.contrib.simplegame.objects
{
import com.threerings.util.ArrayUtil;
import com.whirled.contrib.DisplayUtil;
import com.whirled.contrib.simplegame.SimObject;
import com.whirled.contrib.simplegame.components.SceneComponent;

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.Sprite;


/**
 * A SceneObject with children SimObjects.  The children use the db, but are destroyed
 * with the parent.
 */
public class SceneObjectParent extends SceneObject
{
    override protected function addedToDB () :void
    {
        super.addedToDB();
        for each (var sim :SimObject in _yetToAddToDB) {
            if (sim.db == null) {
                db.addObject(sim);
            }
        }
        _yetToAddToDB = null;
    }

    protected function addSimObjectInternal (s :SimObject) :void
    {
        if (db != null) {
            if (s.db == null) {
                db.addObject(s);
            }
        }
        else {
            _yetToAddToDB.push(s);
        }
        if (!ArrayUtil.contains(_subObjects, s)) {
            _subObjects.push(s);
        }
    }

    public function addSceneObject (obj :SimObject, displayParent :DisplayObjectContainer = null) :void
    {
        if (obj is SceneComponent) {
            // Attach the object to a display parent.
            var disp :DisplayObject = (obj as SceneComponent).displayObject;
            if (null == disp) {
                throw new Error("obj must return a non-null displayObject to be attached " +
                                "to a display parent");
            }

            if (displayParent == null) {
                displayParent = _displaySprite;
            }
            displayParent.addChild(disp);
        }
        addSimObjectInternal(obj);
    }

    public function addSimObject (obj :SimObject) :void
    {
        addSimObjectInternal(obj);
    }

    protected function destroySimObject (s :SimObject) :void
    {
        if (s == null) {
            return;
        }
        if (s.isLiveObject) {
            s.destroySelf();
        }
        else if (s is SceneObject) {
            DisplayUtil.detach(SceneObject(s).displayObject);
        }

        ArrayUtil.removeAll(_subObjects, s);

    }

    override protected function destroyed () :void
    {
        super.destroyed();
        for each (var child :SimObject in _subObjects) {
            if (child.isLiveObject) {
                child.destroySelf();
            }
        }
    }

    override public function get displayObject () :DisplayObject
    {
        return _displaySprite;
    }

    protected function destroyChildren () :void
    {
        for each (var child :SimObject in _subObjects) {
            if (child.isLiveObject) {
                child.destroySelf();
            }
        }
        _subObjects = [];
    }


    protected var _displaySprite :Sprite = new Sprite();
    protected var _subObjects :Array = new Array();
    protected var _yetToAddToDB :Array = new Array();
}
}