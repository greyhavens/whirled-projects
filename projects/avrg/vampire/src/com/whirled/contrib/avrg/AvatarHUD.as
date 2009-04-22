package com.whirled.contrib.avrg
{
import com.threerings.util.ArrayUtil;
import com.threerings.util.ClassUtil;
import com.threerings.util.Hashable;
import com.threerings.util.Log;
import com.whirled.EntityControl;
import com.whirled.avrg.AVRGameControl;
import com.whirled.avrg.AVRGameRoomEvent;
import com.whirled.contrib.simplegame.AppMode;
import com.whirled.contrib.simplegame.objects.SceneObject;

import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.geom.Point;

import vampire.client.ClientContext;
import vampire.data.VConstants;

/**
 * The sprite is centered on the top-middle of the avatar hotspot, presumably this will
 * be close to where you place avatar HUD info.
 *
 *
 */
public class AvatarHUD extends SceneObject
    implements Hashable
{
    public function AvatarHUD(ctrl :AVRGameControl, userId :int)//,  updateCallback :Function)//roomCtrl :RoomSubControlBase,
    {
        if(ctrl == null) {
            throw new Error("AVRGameControl cannot be null");
        }

        _ctrl = ctrl;
        _isPlayer = true;
        _userId = userId;


        _displaySprite = new Sprite();

        registerListener(_ctrl.room, AVRGameRoomEvent.AVATAR_CHANGED, avatarChanged);
        updateHotspot();
    }

    protected function get mode() :AppMode
    {
        return db as AppMode;
    }

    protected function avatarChanged(...ignored) :void
    {
        _entityId = null;
        updateHotspot();
    }

    protected function updateHotspot () :void
    {
        var newHotspot :Array = _ctrl.room.getEntityProperty(
            EntityControl.PROP_HOTSPOT, entityId) as Array;
        setHotspot(newHotspot);
    }

    override protected function update(dt:Number) :void
    {
        super.update(dt);

        if(_ctrl == null || !_ctrl.isConnected()) {
            return;
        }


        //We don't need to update every frame.
//        _timeSinceLastUpdate += dt;


        var newLocation :Array = _ctrl.room.getEntityProperty(
            EntityControl.PROP_LOCATION_LOGICAL, entityId) as Array;

        if(newLocation == null) {
            return;
        }


        setLocation(newLocation, UPDATE_INTERVAL_SECONDS);

        //If we don't yet have a location, make us invisible
        visible = location != null;

    }

    override public function toString () :String
    {
        return "NonPlayer [userId=" + _userId
            + ", roomId="
//            (_roomCtrl != null ? _roomCtrl.getRoomId() : "null")
//            + ", blood=" + blood + "/" + maxBlood
            + ", loc=" + _location
            + ", hs=" + _hotspot
            + "]";
    }

    public function setHotspot (hotspot :Array) :void
    {
        _hotspot = hotspot;
    }

    public function setLocation (location :Array, dt :Number) :void
    {
        updateHotspot();

        _location = location;
        var newXY :Point = locationToRoomCoords(_ctrl, location, hotspot, _displaySprite);

        if(newXY == null) {
            log.debug("setLocation(" + location + ") returns null point");
            return;
        }

        this.x = newXY.x;
        this.y = newXY.y;
    }


    /**
    * The point is the middle-top of the hotspot.
    *
    */
    protected static function locationToRoomCoords (ctrl :AVRGameControl, location :Array, hotspot :Array, s :Sprite = null) :Point
    {
        if(location == null
            || ctrl == null
            || ctrl.local == null
            || ctrl.local.locationToRoom(0, 0, 0) == null) {
            return null;
        }

        if(hotspot == null || hotspot.length < 2) {
            hotspot = [0,0];
        }


        var heightLogical :Number = hotspot[1]/ctrl.local.getRoomBounds()[1];


        var fuckedPoint :Point = ClientContext.ctrl.local.locationToPaintable(location[0], heightLogical, location[2]);

       return fuckedPoint;

    }


    public function get playerId () :int
    {
        return _userId;
    }

    public function get location () :Array
    {
        return _location;
    }
    public function get hotspot () :Array
    {
        return _hotspot;
    }

    public function equals (other :Object) :Boolean
    {
        if (this == other) {
            return true;
        }
        if (other == null || !ClassUtil.isSameClass(this, other)) {
            return false;
        }
        return AvatarHUD(other).hashCode() == this.hashCode();
    }

    public function hashCode () :int
    {
        return _userId;
    }


    public function get isPlayer () :Boolean
    {

        return _isPlayer;
    }

    public function set isPlayer (p :Boolean) :void
    {
        _isPlayer = p;
    }




    public function get sprite (): Sprite
    {
        return _displaySprite;
    }

    override public function get displayObject () :DisplayObject
    {
        return _displaySprite;
    }


    public function get entityId () :String
    {
        if(_entityId == null) {
            for each(var entityId :String in _ctrl.room.getEntityIds(EntityControl.TYPE_AVATAR)) {

                var entityUserId :int = int(_ctrl.room.getEntityProperty(EntityControl.PROP_MEMBER_ID, entityId));

                if(entityUserId == _userId) {
                    _entityId = entityId;
                    break;
                }
            }
        }
        return _entityId;
    }

    protected var _displaySprite :Sprite;




    protected var _userId :int;
    protected var _entityId :String;
    protected var _location :Array;
    protected var _hotspot :Array;

    protected var _isPlayer :Boolean;

    protected var _ctrl :AVRGameControl;
    protected var _timeSinceLastUpdate :Number = 0;
    protected static const UPDATE_INTERVAL_SECONDS :Number = 0.01;
    protected static const EMPTY_LOCATION :Array = [0,0,0,0];
    protected static const log :Log = Log.getLog(AvatarHUD);
}
}