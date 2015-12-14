package com.threerings.flashbang.objects
{
import com.threerings.flashbang.GameObject;
import com.threerings.flashbang.GameObjectRef;
import com.threerings.flashbang.components.SceneComponent;
import com.threerings.ui.DisplayUtils;
import com.threerings.util.ArrayUtil;

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.Sprite;


/**
 * A SceneObject with children GameObjects.  The children use the db, but are destroyed
 * with the parent.
 */
public class SceneObjectParent extends SceneObject
{
    override protected function addedToDB () :void
    {
        super.addedToDB();
        for each (var sim :GameObject in _yetToAddToDB) {
            if (sim.db == null) {
                db.addObject(sim);
            }
            _subObjects.push(sim.ref);
        }
        _yetToAddToDB = null;
    }

    protected function addGameObjectInternal (s :GameObject) :void
    {
        if (db != null) {
            if (s.db == null) {
                db.addObject(s);
            }
            _subObjects.push(s.ref);
        }
        else {
            _yetToAddToDB.push(s);
        }
    }

    public function addSceneObject (obj :GameObject, displayParent :DisplayObjectContainer = null) :void
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
        addGameObjectInternal(obj);
    }

    public function addGameObject (obj :GameObject) :void
    {
        addGameObjectInternal(obj);
    }

    protected function destroyGameObject (s :GameObject) :void
    {
        ArrayUtil.removeAll(_subObjects, s.ref);

        if (s == null) {
            return;
        }
        if (s.isLiveObject) {
            s.destroySelf();
        }
        else if (s is SceneObject) {
            DisplayUtils.detach(SceneObject(s).displayObject);
        }
    }

    override protected function destroyed () :void
    {
        super.destroyed();
        destroyChildren();
    }

    override public function get displayObject () :DisplayObject
    {
        return _displaySprite;
    }

    protected function destroyChildren () :void
    {
        for each (var child :GameObjectRef in _subObjects) {
            if (child != null && child.object.isLiveObject) {
                child.object.destroySelf();
            }
        }
        _subObjects = [];
    }


    protected var _displaySprite :Sprite = new Sprite();
    protected var _subObjects :Array = new Array();
    protected var _yetToAddToDB :Array = new Array();
}
}
