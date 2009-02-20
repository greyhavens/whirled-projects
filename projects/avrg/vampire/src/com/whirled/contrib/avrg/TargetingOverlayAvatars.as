package com.whirled.contrib.avrg
{
import com.threerings.util.ArrayUtil;
import com.threerings.util.HashSet;
import com.threerings.util.Log;
import com.whirled.avrg.AVRGameControl;
import com.whirled.avrg.AVRGameRoomEvent;

import flash.display.Sprite;
import flash.geom.Point;

import vampire.data.VConstants;

//import vampire.data.Codes;
//import vampire.data.Constants;

/**
 * Paints the individual AvatarHUD elements when e.g. locations change.
 * 
 */
public class TargetingOverlayAvatars extends TargetingOverlay
{
    public function TargetingOverlayAvatars( ctrl :AVRGameControl,  avatarManager :AvatarHUDManager, targetClickedCallback:Function = null)
    {
        super([], [], [], targetClickedCallback, null);
        
        _ctrl = ctrl;
        _avatarManager = avatarManager;
        _avatarManager.setAvatarsUpdatedCallback( dirty );
//        registerListener( _avatarManager, AvatarUpdatedEvent.LOCATION_CHANGED, handleAvatarUpdated);
        
        
        //These are actually unnecesary since we get the events from the avatarmanager now
//        registerListener( ctrl.room, AVRGameRoomEvent.SIGNAL_RECEIVED, handleSignalReceived );
        registerListener( ctrl.room, AVRGameRoomEvent.PLAYER_MOVED, dirty );
        registerListener( ctrl.room, AVRGameRoomEvent.PLAYER_ENTERED, dirty );
        registerListener( ctrl.room, AVRGameRoomEvent.PLAYER_LEFT, dirty );
        registerListener( ctrl.room, AVRGameRoomEvent.AVATAR_CHANGED, dirty );
        
        
        
        //Temporary, until we wait till Zells fixes client room signals.
//        registerListener( ctrl.room, MessageReceivedEvent.MESSAGE_RECEIVED, dirty);
        
        dirty();
        
    }
    
    
    
    
    
    
    protected function getValidPlayerIdTargets() :HashSet
    {
        var validIds :HashSet = new HashSet();
        
        var playerIds :Array = _ctrl.room.getPlayerIds();
        
        //Add the nonplayers
        _avatarManager.avatarMap.forEach( function( playerId :int, ...ignored) :void {
            if( !ArrayUtil.contains(playerIds, playerId )) {
                validIds.add( playerId );
            }
        });
        
        
        return validIds;
    }
    
    

        
    
//    protected function handleAvatarUpdated( e :AvatarUpdatedEvent ) :void
//    {
//        _dirty = true;
//        
//        if( !_playerId2Sprite.containsKey(e.playerId)  ) {
//            _playerId2Sprite.put( e.playerId, createSprite( e.hotspot ));
//        }
//    }
    
    protected function dirty( ...ignored ) :void
    {
        _dirty = true;
    }
    
//    protected function handleSignalReceived( e :AVRGameRoomEvent ) :void
//    {
//        log.debug("TargetingOverlayAvatars got signal");
//        if( e.name == Constants.SIGNAL_AVATAR_MOVED ) {
//            dirty();
//        }
//    }
    
//    protected function handlePlayerMoved( e :AVRGameRoomEvent ) :void
//    {
//        _dirty = true;
//    }
//    
//    protected function handlePlayerEntered( e :AVRGameRoomEvent ) :void
//    {
//        _dirty = true;
//    }
//    
//    protected function handlePlayerLeft( e :AVRGameRoomEvent ) :void
//    {
//        _dirty = true;
//    }
//    
//    protected function mouseOverTarget() :void
//    {
//        _dirty = true;
//    }
    
    override protected function update(dt:Number):void
    {
//        if( _ctrl.room.getEntityProperty( AvatarGameBridge.ENTITY_PROPERTY_IS_LOCATIONS_CHANGED, 
//            ClientContext.playerEntityId) ) {
//               
//               
//            //Get the locations from the game avatar
//            
//            log.debug("_ctrl.room.getEntityProperty( "
//                + "AvatarGameBridge.ENTITY_PROPERTY_AVATAR_LOCATIONS, ClientContext.playerEntityId)=" + _ctrl.room.getEntityProperty( 
//                AvatarGameBridge.ENTITY_PROPERTY_AVATAR_LOCATIONS, ClientContext.playerEntityId));
//            
////            log.debug("_ctrl.room.getEntityProperty( "
////                + "AvatarGameBridge.ENTITY_PROPERTY_AVATAR_LOCATIONS)=" + _ctrl.room.getEntityProperty( 
////                AvatarGameBridge.ENTITY_PROPERTY_AVATAR_LOCATIONS));
//                
//            var locationsObject :Object = _ctrl.room.getEntityProperty( 
//                AvatarGameBridge.ENTITY_PROPERTY_AVATAR_LOCATIONS, ClientContext.playerEntityId);
//                
//            log.debug("What class is the locationsObject=" + ClassUtil.getClassName( locationsObject ));
//                
////            if( locationsObject is HashMap ) {
//                var locationsAndHotspots :Array = locationsObject as Array; 
//                log.debug("update(), locations changed, locationsAndHotspots=" + locationsAndHotspots)
//                
//                log.debug("update(), locations changed, Array(locationsObject)=" + (locationsObject as Array)) 
//                updateAvatarManagerWithLocations( locationsObject );
////            }    
////            else {
////                log.warning("Not updating locations...");
////            }
//            
//        }
        
        if( _dirty ) {
            redraw();
//            _dirty = false;
        }
    }
    
//    protected function updateAvatarManagerWithLocations( dataFromAvatar :Object ) :void
//    {
//        if( dataFromAvatar == null) {
//            log.error("updateAvatarManagerWithLocations(null)");
//            return;
//        }
//        
//        log.debug("updateAvatarManagerWithLocations, updating")
//        
//        var locationsAndHotspots :HashMap = new HashMap();
//        
//        for( var i :int = 0; i < dataFromAvatar.length; i++) {
//            var locaData :Array = dataFromAvatar[i] as Array;
//            locationsAndHotspots.put( locaData[0], locaData[1] );
//        }
//        
////        for each( var locaData :Array in dataFromAvatar ) {
////            locationsAndHotspots.put( locaData[0], locaData[1] );
////        }
//        
//        
//        //Add player avatars not in locations and update
//        locationsAndHotspots.forEach( function( userId :int, data :Array) :void {
//            
//            
//            
//            var playerAvatar :PlayerAvatar;
//            if( !_avatarManager.isAvatar(userId) ) {
//                var isPlayer :Boolean = ArrayUtil.contains( _ctrl.room.getPlayerIds(), userId );
//                playerAvatar = new PlayerAvatar( isPlayer, userId );
//                playerAvatar.setLocation( data[0] );
//                playerAvatar.setHotspot( data[1] );
//                _avatarManager.addAvatar( playerAvatar );
//            }
//            else {
//                playerAvatar = _avatarManager.getAvatar( userId );
//            }
//            
//            playerAvatar.setLocation( data[0] );
//            playerAvatar.setHotspot( data[1] );
//            
//        });
//        
//        //Remove player avatars not in the location data
//        for each( var pa :PlayerAvatar in _avatarManager.avatars) {
//            if( !locationsAndHotspots.containsKey(pa.playerId) ) {
//                _avatarManager.removeAvatar( pa.playerId );
//                var s :Sprite = _playerId2Sprite.get( pa.playerId ) as Sprite;
//                if( s != null) {
//                    if( _paintableOverlay.contains( s ) ) {
//                        _paintableOverlay.removeChild( s );
//                    }
//                }
//                _playerId2Sprite.remove( pa.playerId );
//            }
//        }
//        
//        //Then update locations/hotspots
//        
//        
//        _dirty = true;
//        
//    }
    
    
    protected function redraw() :void
    {
        if( _ctrl == null || _ctrl.local == null || _ctrl.local.locationToRoom(0, 0, 0) == null ) {
            return; 
        }
        log.debug(_ctrl.player.getPlayerId() + " Upon redraw" , "valid targets", getValidPlayerIdTargets().toArray());
//        trace("_ctrl.local.locationToRoom(0, 0.5, 0)=" + _ctrl.local.locationToRoom(0, 0.5, 0));
//        trace("_ctrl.local.locationToRoom(0, 0.5, 0.8)=" + _ctrl.local.locationToRoom(0, 0.5, 0.8));
//        trace("_ctrl.local.locationToPaintable(0, 0.5, 0)=" + _ctrl.local.locationToPaintable(0, 0.5, 0));
        var absoluteYardStickLength :Number = 0.5;
        var yardStickAtZ0 :Number = _ctrl.local.locationToRoom(0, 0, 0).y - _ctrl.local.locationToRoom(0, 0.5, 0).y;
        var yardStickAtZ1 :Number = _ctrl.local.locationToRoom(0, 0, 1).y - _ctrl.local.locationToRoom(0, 0.5, 1).y;
//        trace("yardStickAtZ0=" + yardStickAtZ0);
//        trace("yardStickAtZ1=" + yardStickAtZ1);
        var zScaleFactor :Number = 1.0 - yardStickAtZ1/yardStickAtZ0;
        
        if( VConstants.LOCAL_DEBUG_MODE ) {
            zScaleFactor = 0.5;
        }
        trace("zScaleFactor=" + zScaleFactor);
            
        var stayDirtyDueToIncompeteAvatarInfo :Boolean = false;
        var emptyLocation :Array = [0,0,0];
        
        

        
        for each( var avatar :AvatarHUD in _avatarManager.avatars) {
            
            var playerId :int = avatar.playerId;
            
            if( avatar.sprite != null && !_paintableOverlay.contains( avatar.sprite ) ) {
                _paintableOverlay.addChild( avatar.sprite );
                stayDirtyDueToIncompeteAvatarInfo = true;
            }
            
//            
//            //Make sure we have sprites for all avatars
//            if( !_playerId2Sprite.containsKey(playerId) ) {
//                var s :Sprite = createSprite( avatar.hotspot );
//                log.debug(_ctrl.player.getPlayerId() + "Created sprite with dimensions(" + s.width + ", " + s.height + ")"); 
//                        
//                if( playerId != _ctrl.player.getPlayerId() ) {
//                    _paintableOverlay.addChild( s );
//                }
//                _playerId2Sprite.put( playerId, s );
//                
//            }
            
            //Scale and position each sprite
            var avatarOverlay :Sprite = avatar.sprite;
            var hotspot :Array = avatar.hotspot;
            var location :Array = avatar.location;
            
            if( location == null || ArrayUtil.equals( location, emptyLocation ) || hotspot == null) {
                stayDirtyDueToIncompeteAvatarInfo = true;
            }
            
            avatarOverlay.visible = location != null;
            if( !avatarOverlay.visible) {
                continue;
            }
            
//            trace("avatar.location=" + avatar.location);
            
            function scaleHeightByZ( height :Number, z :Number) :Number
            {
//                trace("scaleHeightByZ(" + height + ", " + z + ")"); 
                        
                return (height - height * z * zScaleFactor) / height;
            }
            
            var scale :Number = scaleHeightByZ( hotspot[1], location[2] );
            
//            trace("scaling sprite by=" + scale);
            avatar.setZScaleFactor(scale);
//            avatarOverlay.scaleX = scale;
//            avatarOverlay.scaleY = scale;
            
            var screenPosition :Point = _ctrl.local.locationToRoom( location[0], 0, location[2] );
            avatarOverlay.x = screenPosition.x;
            avatarOverlay.y = screenPosition.y;
            
            
        }
        
        if( !stayDirtyDueToIncompeteAvatarInfo ) {
            _dirty = false;
        } 
        
    }
    
//    protected function createSprite( hotspot :Array) :Sprite
//    {
//        var s :Sprite = new Sprite();
//        drawNonSelectedSprite(s, hotspot );
//        s.mouseEnabled = false;
//        s.mouseChildren = false;
//        return s;
//    }
    
//    protected function drawNonSelectedSprite( s :Sprite, hotspot :Array ) :void
//    {
//        while( s.numChildren ) { s.removeChildAt(0);}
//        s.graphics.clear();
//        s.graphics.beginFill(0, 0);
//        s.graphics.drawRect( -hotspot[0]/2, -hotspot[1], hotspot[0], hotspot[1]);
//        s.graphics.endFill();
//        s.graphics.lineStyle(1, 0);
//        s.graphics.drawRect( -hotspot[0]/2, -hotspot[1], hotspot[0], hotspot[1]);
//    }
//    protected function drawSelectedSpriteSinglePredator( s :Sprite, hotspot :Array ) :void
//    {
//        while( s.numChildren ) { s.removeChildAt(0);}
//        s.graphics.clear();
//        s.graphics.beginFill(0, 0.3);
//        s.graphics.drawRect( -hotspot[0]/2, -hotspot[1], hotspot[0], hotspot[1]);
//        s.graphics.endFill();
//        s.addChild( TextFieldUtil.createField("Single Pred.", {scaleX:2, scaleY:2, textColor:0xffffff} ));
//    }
//    protected function drawSelectedSpriteFrenzyPredator( s :Sprite, hotspot :Array ) :void
//    {
//        while( s.numChildren ) { s.removeChildAt(0);}
//        s.graphics.clear();
//        s.graphics.beginFill(0, 0.3);
//        s.graphics.drawRect( -hotspot[0]/2, -hotspot[1], hotspot[0], hotspot[1]);
//        s.graphics.endFill();
//        
//        s.addChild( TextFieldUtil.createField("Frenzy", {scaleX:2, scaleY:2, textColor:0xffffff} ));
//    }
    
//    protected var _playerId2Sprite :HashMap = new HashMap();
    protected var _dirty :Boolean = true;
    
//    public addAvatarLocation
    protected var _ctrl :AVRGameControl;
    protected var _avatarManager :AvatarHUDManager;
    
    protected var _mouseOverPlayerId :int = 0;
    protected var _multiPred :Boolean = true;
    
    protected var _playerEntityId :String;
    
    
    
    protected static const log :Log = Log.getLog( TargetingOverlayAvatars );
    
}
}