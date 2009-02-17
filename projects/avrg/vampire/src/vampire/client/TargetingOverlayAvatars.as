package vampire.client
{
import com.threerings.util.HashMap;
import com.whirled.avrg.AVRGameControl;
import com.whirled.avrg.AVRGameRoomEvent;

import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.geom.Point;

import vampire.client.events.AvatarUpdatedEvent;
import vampire.data.AvatarManager;
import vampire.data.Constants;

public class TargetingOverlayAvatars extends TargetingOverlay
{
    public function TargetingOverlayAvatars( ctrl :AVRGameControl,  avatarManager :AvatarManager, targetClickedCallback:Function = null)
    {
        super([], [], [], targetClickedCallback, mouseOverTarget);
        
        _ctrl = ctrl;
        _avatarManager = avatarManager;
//        registerListener( _avatarManager, AvatarUpdatedEvent.LOCATION_CHANGED, handleAvatarUpdated);
        
        registerListener( ctrl.room, AVRGameRoomEvent.SIGNAL_RECEIVED, handleSignalReceived );
        registerListener( ctrl.room, AVRGameRoomEvent.PLAYER_MOVED, handlePlayerMoved );
        registerListener( ctrl.room, AVRGameRoomEvent.PLAYER_ENTERED, handlePlayerEntered );
        registerListener( ctrl.room, AVRGameRoomEvent.PLAYER_LEFT, handlePlayerLeft );
        
        
    }
    
    
    override protected function handleMouseMove( e :MouseEvent ) :void
    {
//        trace("Mouse move e=" + e);
        var previousMouseOverPlayer :int = _mouseOverPlayerId;
        _mouseOverPlayerId = 0;
        
        _playerId2Sprite.forEach( function( playerId :int, s :Sprite) :void {
            if( _mouseOverPlayerId ) {
                return;
            }
            
            if( s.hitTestPoint( e.stageX, e.stageY )) {
                _mouseOverPlayerId = playerId;
            }
            
        });
        
        if( previousMouseOverPlayer == _mouseOverPlayerId) {
            return;
        }
        else {
            _dirty = true;
            
            if( previousMouseOverPlayer > 0) {
                drawNonSelectedSprite( (_playerId2Sprite.get( previousMouseOverPlayer ) as Sprite), 
                    _avatarManager.getAvatar( previousMouseOverPlayer ).hotspot);
            }
            
            if( _mouseOverPlayerId > 0) {
                drawSelectedSprite( (_playerId2Sprite.get( _mouseOverPlayerId ) as Sprite), 
                    _avatarManager.getAvatar( _mouseOverPlayerId ).hotspot);
            }
        }
        
    }
    
    override protected function handleMouseClick( e :MouseEvent ) :void
    {
        trace("handleMouseClick");
        //Send the feed request here
        _displaySprite.parent.removeChild( _displaySprite );
////        trace("Mouse move e=" + e);
//        var previousMouseOverPlayer :int = _mouseOverPlayerId;
//        _mouseOverPlayerId = 0;
//        
//        _playerId2Sprite.forEach( function( playerId :int, s :Sprite) :void {
//            if( _mouseOverPlayerId ) {
//                return;
//            }
//            
//            if( s.hitTestPoint( e.stageX, e.stageY )) {
//                _mouseOverPlayerId = playerId;
//            }
//            
//        });
//        
//        if( previousMouseOverPlayer == _mouseOverPlayerId) {
//            return;
//        }
//        else {
//            _dirty = true;
//            
//            if( previousMouseOverPlayer > 0) {
//                drawNonSelectedSprite( (_playerId2Sprite.get( previousMouseOverPlayer ) as Sprite), 
//                    _avatarManager.getAvatar( previousMouseOverPlayer ).hotspot);
//            }
//            
//            if( _mouseOverPlayerId > 0) {
//                drawSelectedSprite( (_playerId2Sprite.get( _mouseOverPlayerId ) as Sprite), 
//                    _avatarManager.getAvatar( _mouseOverPlayerId ).hotspot);
//            }
//        }
        
    }
        
    
    protected function handleAvatarUpdated( e :AvatarUpdatedEvent ) :void
    {
        _dirty = true;
        
        if( !_playerId2Sprite.containsKey(e.playerId) ) {
            _playerId2Sprite.put( e.playerId, createSprite( e.hotspot ));
        }
    }
    
    
    protected function handleSignalReceived( e :AVRGameRoomEvent ) :void
    {
        trace("TargetingOverlayAvatars got signal");
        if( e.name == Constants.SIGNAL_AVATAR_MOVED ) {
            _dirty = true;
        }
    }
    
    protected function handlePlayerMoved( e :AVRGameRoomEvent ) :void
    {
        _dirty = true;
    }
    
    protected function handlePlayerEntered( e :AVRGameRoomEvent ) :void
    {
        _dirty = true;
    }
    
    protected function handlePlayerLeft( e :AVRGameRoomEvent ) :void
    {
        _dirty = true;
    }
    
    protected function mouseOverTarget() :void
    {
        _dirty = true;
    }
    
    override protected function update(dt:Number):void
    {
        if( _dirty ) {
            redraw();
            _dirty = false;
        }
    }
    
    
    protected function redraw() :void
    {
//        trace("_ctrl.local.locationToRoom(0, 0.5, 0)=" + _ctrl.local.locationToRoom(0, 0.5, 0));
//        trace("_ctrl.local.locationToRoom(0, 0.5, 0.8)=" + _ctrl.local.locationToRoom(0, 0.5, 0.8));
//        trace("_ctrl.local.locationToPaintable(0, 0.5, 0)=" + _ctrl.local.locationToPaintable(0, 0.5, 0));
        var absoluteYardStickLength :Number = 0.5;
        var yardStickAtZ0 :Number = _ctrl.local.locationToRoom(0, 0, 0).y - _ctrl.local.locationToRoom(0, 0.5, 0).y;
        var yardStickAtZ1 :Number = _ctrl.local.locationToRoom(0, 0, 1).y - _ctrl.local.locationToRoom(0, 0.5, 1).y;
//        trace("yardStickAtZ0=" + yardStickAtZ0);
//        trace("yardStickAtZ1=" + yardStickAtZ1);
        var zScaleFactor :Number = 1.0 - yardStickAtZ1/yardStickAtZ0;
//        trace("zScaleFactor=" + zScaleFactor);
            
        for each( var avatar :PlayerAvatar in _avatarManager.avatars) {
            
            var playerId :int = avatar.playerId;
            //Make sure we have sprites for all avatars
            if( !_playerId2Sprite.containsKey(playerId) ) {
                var s :Sprite = createSprite( avatar.hotspot );
//                trace("Created sprite with dimensions(" + s.width + ", " + s.height + ")"); 
                        
                _paintableOverlay.addChild( s );
                _playerId2Sprite.put( playerId, s );
                
            }
            
            //Scale and position each sprite
            var avatarOverlay :Sprite = _playerId2Sprite.get( playerId ) as Sprite;
            var hotspot :Array = avatar.hotspot;
            var location :Array = avatar.location;
            
//            trace("avatar.location=" + avatar.location);
            
            function scaleHeightByZ( height :Number, z :Number) :Number
            {
//                trace("scaleHeightByZ(" + height + ", " + z + ")"); 
                        
                return (height - height * z * zScaleFactor) / height;
            }
            
            var scale :Number = scaleHeightByZ( hotspot[1], location[2] );
            
//            trace("scaling sprite by=" + scale);
            avatarOverlay.scaleX = scale;
            avatarOverlay.scaleY = scale;
            
            var screenPosition :Point = _ctrl.local.locationToRoom( location[0], 0, location[2] );
            avatarOverlay.x = screenPosition.x;
            avatarOverlay.y = screenPosition.y;
            
            
        }
        
    }
    
    protected function createSprite( hotspot :Array) :Sprite
    {
        var s :Sprite = new Sprite();
        drawNonSelectedSprite(s, hotspot );
        s.mouseEnabled = false;
        s.mouseChildren = false;
        return s;
    }
    
    protected function drawNonSelectedSprite( s :Sprite, hotspot :Array ) :void
    {
        s.graphics.clear();
        s.graphics.beginFill(0, 0);
        s.graphics.drawRect( -hotspot[0]/2, -hotspot[1], hotspot[0], hotspot[1]);
        s.graphics.endFill();
        s.graphics.lineStyle(1, 0);
        s.graphics.drawRect( -hotspot[0]/2, -hotspot[1], hotspot[0], hotspot[1]);
    }
    protected function drawSelectedSprite( s :Sprite, hotspot :Array ) :void
    {
        s.graphics.clear();
        s.graphics.beginFill(0, 0.3);
        s.graphics.drawRect( -hotspot[0]/2, -hotspot[1], hotspot[0], hotspot[1]);
        s.graphics.endFill();
    }
    
    protected var _playerId2Sprite :HashMap = new HashMap();
    protected var _dirty :Boolean = true;
    
//    public addAvatarLocation
    protected var _ctrl :AVRGameControl;
    protected var _avatarManager :AvatarManager;
    
    protected var _mouseOverPlayerId :int = 0;
    
}
}