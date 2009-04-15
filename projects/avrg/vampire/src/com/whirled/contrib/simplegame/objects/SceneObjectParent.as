package com.whirled.contrib.simplegame.objects
{
import com.threerings.util.ArrayUtil;
import com.whirled.contrib.simplegame.SimObject;

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.Sprite;


/**
 * A SceneObject with children scene objects.  The children use the db, but need to be disposed
 * of with the parent.
 */
public class SceneObjectParent extends DraggableObject
{
    override protected function addedToDB () :void
    {
        super.addedToDB();
        for each (var sim :SimObject in _yetToAddToDB) {
            db.addObject(sim);
        }
        _yetToAddToDB = null;
    }

    protected function addSimObject (s :SimObject) :void
    {
        if (db != null) {
            db.addObject(s);
        }
        else {
            _yetToAddToDB.push(s);
        }
        _subObjects.push(s);
    }
    protected function addSceneObject (s :SceneObject, parent :DisplayObjectContainer = null) :void
    {
        if (parent != null) {
            parent.addChild(s.displayObject);
        }
        else {
            _displaySprite.addChild(s.displayObject);
        }
        addSimObject(s);
    }

    protected function destroySimObject (s :SimObject) :void
    {
        if (s.isLiveObject) {
            s.destroySelf();
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

    protected var _displaySprite :Sprite = new Sprite();
    protected var _subObjects :Array = new Array();
    protected var _yetToAddToDB :Array = new Array();
}
}