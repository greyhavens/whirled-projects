package vampire.avatar
{
import com.threerings.util.ArrayUtil;
import com.threerings.util.HashSet;
import com.whirled.avrg.AVRGameControl;
import com.whirled.contrib.avrg.TargetingOverlayAvatars;
import com.whirled.net.ElementChangedEvent;

import flash.events.MouseEvent;

import vampire.data.Codes;
import vampire.data.SharedPlayerStateClient;
import vampire.data.VConstants;


/**
 * Determines what/when to show over/on the avatars in the room. 
 * 
 * 
 */
public class VampireAvatarHUDOverlay extends TargetingOverlayAvatars
{
    public function VampireAvatarHUDOverlay(ctrl:AVRGameControl, avatarManager:VampireAvatarHUDManager)
    {
        super(ctrl, avatarManager);
        
        _vampireAvatarManager = avatarManager;
        
        registerListener( ctrl.room.props, ElementChangedEvent.ELEMENT_CHANGED, handleElementChanged );
        
        setDisplayMode( DISPLAY_MODE_OFF );
        
//        registerListener(_paintableOverlay, MouseEvent.CLICK, function(...ignored) :void {
//            setDisplayMode( DISPLAY_MODE_OFF );    
//        });
    }
    
    
    override protected function handleMouseMove( e :MouseEvent ) :void
    {
////        trace("Mouse move e=" + e);
//        var previousMouseOverPlayer :int = _mouseOverPlayerId;
//        var previousPredStatus :Boolean = _multiPred;
//        _mouseOverPlayerId = 0;
//        
//        var validTargetIds :HashSet = getValidPlayerIdTargets();
//        _multiPred = validTargetIds.size() > 1;
//        
//        _avatarManager.avatarMap.forEach( function( playerId :int, avatar :VampireAvatarHUD) :void {
//            
//            var s :Sprite = avatar.sprite;
//            if( !validTargetIds.contains(playerId)) {
//                return;
//            }
//            
//            if( _mouseOverPlayerId ) {
//                return;
//            }
//            
//            if( s.hitTestPoint( e.stageX, e.stageY )) {
//                _mouseOverPlayerId = playerId;
//                
//                
//                
////                _multiPred = e.localX < s.x;
//                
//            }
//            
//        });
//        
//        //Adjust the buttons etc visibility
//        var avatarMouseOver :AvatarHUD = _avatarManager.getAvatar( _mouseOverPlayerId );
//        if( avatarMouseOver != null ) {
//            avatarMouseOver.buttonFeed.visible = true;
////            avatarMouseOver.buttonFrenzy.visible = validTargetIds.size() > 1;
//        }
//        
//        
//        
//        if( previousMouseOverPlayer == _mouseOverPlayerId && previousPredStatus == _multiPred) {
//            return;
//        }
//        else {
//            log.debug( _ctrl.player.getPlayerId() + " mouse state changed", "_mouseOverPlayerId", 
//                _mouseOverPlayerId);
//            _dirty = true;
//            
//            if( previousMouseOverPlayer > 0) {
//                var previousAvatar :AvatarHUD = _avatarManager.getAvatar(previousMouseOverPlayer);
//                if(  previousAvatar != null ) {
//                    previousAvatar.buttonFeed.visible = false;
//                    previousAvatar.buttonFrenzy.visible = false;
////                    previousAvatar.buttonFrenzy.visible = false;
////                    previousAvatar.frenzyCountdown.visible = false;
////                    previousAvatar.drawNonSelectedSprite();
//                }
//                    
//            }
//            
//            if( _mouseOverPlayerId > 0) {
//                
//                if( _multiPred ) {
//                    _avatarManager.getAvatar(_mouseOverPlayerId).buttonFrenzy.visible = true;
////                    drawSelectedSpriteSinglePredator( (_playerId2Sprite.get( _mouseOverPlayerId ) as Sprite), 
////                        _avatarManager.getAvatar( _mouseOverPlayerId ).hotspot);
//                }
//                else {
//                    _avatarManager.getAvatar(_mouseOverPlayerId).buttonFrenzy.visible = false;
////                    _avatarManager.getAvatar(_mouseOverPlayerId).drawSelectedSpriteSinglePredator();
////                    drawSelectedSpriteFrenzyPredator( (_playerId2Sprite.get( _mouseOverPlayerId ) as Sprite), 
////                        _avatarManager.getAvatar( _mouseOverPlayerId ).hotspot);
//                }
//            }
//        }
        
    }
    
    override protected function handleMouseClick( e :MouseEvent ) :void
    {
//        //Remove ourselves from the display hierarchy
//        _displaySprite.parent.removeChild( _displaySprite );
//        
//        
//        var validTargetIds :HashSet = getValidPlayerIdTargets();
//        log.debug(_ctrl.player.getPlayerId() + " handleMouseClick, validTargetIds=" + validTargetIds.toArray());
//            
//        if( _targetClickedCallback != null) {
//            var _mouseOverPlayerId :int = 0;
//            
//            _multiPred = validTargetIds.size() > 1;
//            
//            _avatarManager.avatarMap.forEach( function( playerId :int, avatar :VampireAvatarHUD) :void {
//            
//                var s :Sprite = avatar.sprite;   
//                if( !validTargetIds.contains(playerId)) {
//                    return;
//                }
//            
//                if( _mouseOverPlayerId ) {
//                    return;
//                }
//                
//                if( s.hitTestPoint( e.stageX, e.stageY )) {
//                    _mouseOverPlayerId = playerId;
//                    //If on the left of the sprite, play with a single predator
//                    
//                    _multiPred = avatar.buttonFrenzy.hitTestPoint( e.stageX, e.stageY );
////                    _multiPred = e.localX < s.x;
//                }
//                
//            });
//            
//            if( _mouseOverPlayerId ) {
//                //Send the feed request
//                _targetClickedCallback(_mouseOverPlayerId, _multiPred);
//            }
//        }
    }
    
    protected function handleElementChanged( e :ElementChangedEvent ) :void
    {
        if( e.index == Codes.ROOM_PROP_PLAYER_DICT_INDEX_CURRENT_ACTION) {
            dirty();
        }
    }
    
    override protected function getValidPlayerIdTargets() :HashSet
    {
        var validIds :HashSet = new HashSet();
        
        var playerIds :Array = _ctrl.room.getPlayerIds();
        
        //Add the nonplayers
        _avatarManager.avatarMap.forEach( function( playerId :int, ...ignored) :void {
            if( !ArrayUtil.contains(playerIds, playerId )) {
                validIds.add( playerId );
            }
        });
        
        //Add players in 'bare' mode
        for each( var playerId :int in playerIds ) {
            
            if( playerId == _ctrl.player.getPlayerId() ) {
                continue;
            }
            
            var action :String = SharedPlayerStateClient.getCurrentAction( playerId );
            if( action != null && action == VConstants.GAME_MODE_BARED) {
                validIds.add( playerId );
            }
        }
        
        return validIds;
    }
    
    public function get displayMode() :int
    {
        return _displayMode;    
    }
    public function setDisplayMode( mode :int, selectedPlayer :int = 0, multiPredators :Boolean = false ) :void
    {
        _displayMode = mode;
        var validIds :HashSet;
        
        switch( mode ) {
            case DISPLAY_MODE_SHOW_INFO_ALL_AVATARS:
                _displaySprite.addChild( _paintableOverlay );
                
                _avatarManager.avatarMap.forEach( function( id :int, avatar :VampireAvatarHUD) :void {
                    avatar.setDisplayModeShowInfo();
                });
                
                
                break;
                
            case DISPLAY_MODE_SELECT_FEED_TARGET:
                _displaySprite.addChild( _paintableOverlay );
                
                trace("DISPLAY_MODE_SELECT_FEED_TARGET, validIds=" + validIds);
                validIds = getValidPlayerIdTargets();
                
                _avatarManager.avatarMap.forEach( function( id :int, avatar :VampireAvatarHUD) :void {
                    if( validIds.contains( avatar.playerId ) ) {
                        avatar.setDisplayModeSelectableForFeed( validIds.size() > 1 );
                    }
                    else {
                        avatar.setDisplayModeInvisible();
                    }        
                });
                break;
            case DISPLAY_MODE_SHOW_FEED_TARGET:
                _displaySprite.addChild( _paintableOverlay );
                
                _avatarManager.avatarMap.forEach( function( id :int, avatar :VampireAvatarHUD) :void {
                    if( selectedPlayer == avatar.playerId ) {
                        avatar.setSelectedForFeed( multiPredators );
                    }
                    else {
                        avatar.setDisplayModeInvisible();
                    }        
                });
                break;
                
            default://Off
                if( _displaySprite.contains( _paintableOverlay ) ) {
                    _displaySprite.removeChild( _paintableOverlay );
                }
                _displayMode = DISPLAY_MODE_OFF;
                
        }
    }
    
    protected var _displayMode :int = 0;
    
    public static const DISPLAY_MODE_OFF :int = 0;
    public static const DISPLAY_MODE_SHOW_INFO_ALL_AVATARS :int = 1;
    public static const DISPLAY_MODE_SELECT_FEED_TARGET :int = 2;
    public static const DISPLAY_MODE_SHOW_FEED_TARGET :int = 3;
    
    
    protected var _vampireAvatarManager :VampireAvatarHUDManager;
}
}