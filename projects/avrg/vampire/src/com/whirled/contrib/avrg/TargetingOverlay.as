package com.whirled.contrib.avrg
{
import com.threerings.util.ArrayUtil;
import com.threerings.util.HashMap;
import com.whirled.contrib.simplegame.SimObject;
import com.whirled.contrib.simplegame.objects.SceneObject;

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.geom.Rectangle;

/**
 * Generic room targeting overlay.  May delete this class in the future.
 */
public class TargetingOverlay extends SceneObject
{
    /**
    *
    * callback(playerIdSelected), callback(0) for no player clicked
    */
    public function TargetingOverlay(playerIds :Array, screenCoordsCenter :Array,
          screenDimensions :Array, targetClickedCallback :Function = null,
          mouseOverTarget :Function  = null)
    {
        _displaySprite  = new Sprite();
        _paintableOverlay = new Sprite();

        _displaySprite.addChild(_paintableOverlay);
        _paintableOverlay.mouseChildren = true;
        _paintableOverlay.mouseEnabled = false;


        _targetClickedCallback = targetClickedCallback;
        _mouseOverCallback = mouseOverTarget;

        if(_targetClickedCallback == null) {
            _targetClickedCallback = function (...ignored) :void {
                trace("Target Clicked, should replace targetClickedCallback");}
        }

//        registerListener(_displaySprite, MouseEvent.MOUSE_MOVE, handleMouseMove);
//        registerListener(_displaySprite, MouseEvent.CLICK, handleMouseClick);

        _rects = new HashMap();

        reset(playerIds, screenCoordsCenter, screenDimensions);
    }

    public function reset(playerIds :Array, screenCoordsCenter :Array, screenDimensions :Array) :void
    {
        _rects.clear();

        for(var i :int = 0;
            i < playerIds.length && i < screenCoordsCenter.length && i < screenDimensions.length;
            i++) {

            _rects.put(playerIds[i], new Rectangle(
                screenCoordsCenter[i][0] - screenDimensions[i][0]/2,
                screenCoordsCenter[i][1] - screenDimensions[i][1]/2,
                screenDimensions[i][0],
                screenDimensions[i][1]
               ));
        }


    }

    override public function get displayObject () :DisplayObject
    {
        return _displaySprite;
    }

    protected function handleMouseMove(e :MouseEvent) :void
    {
        var mouseMovedOverPlayerId :int = 0;
        var mouseOverRect :Rectangle;

        _rects.forEach(function(playerId :int, rect :Rectangle) :void {
            if(mouseMovedOverPlayerId) {
                return;
            }

            if(rect.contains(e.localX, e.localY)) {
                mouseMovedOverPlayerId = playerId;
                mouseOverRect = rect;
            }

        });
        if(_mouseOverCallback != null && mouseMovedOverPlayerId > 0) {
            _mouseOverCallback(mouseMovedOverPlayerId, mouseOverRect, _paintableOverlay);
        }
        else {
            _paintableOverlay.graphics.clear();
        }
    }

    protected function handleMouseClick(e :MouseEvent) :void
    {
        trace("test1111");
        var mouseClickedPlayerId :int = 0;
        var mouseClickedRect :Rectangle;

        _rects.forEach(function(playerId :int, rect :Rectangle) :void {
            if(mouseClickedPlayerId) {
                return;
            }

            if(rect.contains(e.localX, e.localY)) {
                mouseClickedPlayerId = playerId;
                mouseClickedRect = rect;
            }

        });

        if(_targetClickedCallback != null && mouseClickedPlayerId > 0) {
            _targetClickedCallback(mouseClickedPlayerId, mouseClickedRect, _paintableOverlay);
        }
        else {
            _paintableOverlay.graphics.clear();
        }
    }







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

//    override public function get displayObject () :DisplayObject
//    {
//        return _displaySprite;
//    }

    protected var _displaySprite :Sprite = new Sprite();
    protected var _subObjects :Array = new Array();
    protected var _yetToAddToDB :Array = new Array();








    /**
    * Another sprite is used to paint on, so it can be detached from the _displaySprite if neccesary.
    */
    protected var _paintableOverlay :Sprite;

    protected var _targetClickedCallback :Function;
    protected var _mouseOverCallback :Function;

    protected var _rects :HashMap;

}
}