package vampire.avatar
{
import com.threerings.util.ArrayUtil;
import com.threerings.util.HashSet;
import com.whirled.avrg.AVRGameControl;
import com.whirled.avrg.AVRGamePlayerEvent;
import com.whirled.avrg.AVRGameRoomEvent;
import com.whirled.contrib.avrg.AvatarHUD;
import com.whirled.contrib.avrg.TargetingOverlayAvatars;
import com.whirled.contrib.simplegame.objects.SimpleTimer;
import com.whirled.net.ElementChangedEvent;

import flash.events.MouseEvent;

import vampire.client.ClientContext;
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

    protected var p1 :VampireAvatarHUD;

    public function VampireAvatarHUDOverlay(ctrl:AVRGameControl)
    {
        super(ctrl);

//        _vampireAvatarManager = avatarManager;

        registerListener( _ctrl.room, AVRGameRoomEvent.PLAYER_ENTERED, reapplyDisplayMode);
        registerListener( _ctrl.player, AVRGamePlayerEvent.ENTERED_ROOM, reapplyDisplayMode);

        //If somebody changes an action, make sure we are updated.
        registerListener( _ctrl.room.props, ElementChangedEvent.ELEMENT_CHANGED,
            function( e :ElementChangedEvent ) :void {
                if( e.index == Codes.ROOM_PROP_PLAYER_DICT_INDEX_CURRENT_ACTION ) {
                    reapplyDisplayMode();
                }
            }
        );

        //If an avatar changes state, make sure we are updated.
        registerListener( _ctrl.room.props, ElementChangedEvent.ELEMENT_CHANGED,
            function( e :ElementChangedEvent ) :void {
                if( e.index == Codes.ROOM_PROP_PLAYER_DICT_INDEX_AVATAR_STATE) {
                    reapplyDisplayMode();
                }
            }
        );






        if( VConstants.LOCAL_DEBUG_MODE) {
            p1 = new VampireAvatarHUD(ctrl,  1 );
            _avatars.put( p1.playerId, p1 );
            p1.isPlayer = true;
            p1.setHotspot( [100, 200] );
            p1.setLocation( [0.6, 0, 0.5], 2 );

            var p2 :VampireAvatarHUD = new VampireAvatarHUD(ctrl,  2 );
            _avatars.put( p2.playerId, p2 );
            p2.isPlayer = true;
            p2.setHotspot( [100, 200] );
            p2.setLocation( [0.3, 0, 1.0], 3 );

            var p3 :VampireAvatarHUD = new VampireAvatarHUD(ctrl,  3 );
            _avatars.put( p3.playerId, p3 );
            p3.isPlayer = true;
            p3.setHotspot( [100, 200] );
            p3.setLocation( [0.9, 0, 0.7], 3 );
        }
//        trace(_avatars.size() );

//        setDisplayMode( DISPLAY_MODE_SHOW_VALID_TARGETS );
//        registerListener(_paintableOverlay, MouseEvent.CLICK, function(...ignored) :void {
            setDisplayMode( DISPLAY_MODE_OFF );
//        });
    }

    protected function reapplyDisplayMode( ...ignored ) :void
    {
        setDisplayMode( _displayMode );
    }
    override protected function addedToDB():void
    {
        super.addedToDB();
        if( VConstants.LOCAL_DEBUG_MODE) {

            for each( var p :AvatarHUD in _avatars.values()) {
                db.addObject( p, _paintableOverlay );
            }

//            db.addObject(new SimpleTimer(10, function (...ignored) :void {
//                p1.setLocation( [0.6, 0, 0.1], 6 );
//            }));
        }

        var updateDisplayTimer :SimpleTimer = new SimpleTimer(1, reapplyDisplayMode, true,
            UPDATE_DISPLAY_TIMER_NAME );
//        db.addObject( updateDisplayTimer );
    }

    override protected function destroyed():void
    {
        super.destroyed();
        if( db != null && db.getObjectNamed( UPDATE_DISPLAY_TIMER_NAME ) != null) {
            db.getObjectNamed( UPDATE_DISPLAY_TIMER_NAME ).destroySelf();
        }
    }



    override protected function createPlayerAvatar( userId :int ) :AvatarHUD
    {
        var av :VampireAvatarHUD = new VampireAvatarHUD( _ctrl, userId );

        if( userId == _ctrl.player.getPlayerId() ) {
            av.setDisplayModeInvisible();
        }

        return av;
    }

    public function getVampireAvatar( playerId :int ) :VampireAvatarHUD
    {
        return getAvatar( playerId ) as VampireAvatarHUD;
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
//        _avatars.forEach( function( playerId :int, avatar :VampireAvatarHUD) :void {
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
//            _avatars.forEach( function( playerId :int, avatar :VampireAvatarHUD) :void {
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


    protected function getValidPlayerIdTargets() :HashSet
    {

        if( VConstants.LOCAL_DEBUG_MODE) {
            var a :HashSet = new HashSet();
            a.add(1);
            a.add(2);
            return a;
        }

        var validIds :HashSet = new HashSet();

        var playerIds :Array = _ctrl.room.getPlayerIds();

        var validCHatTargets :Array = ClientContext.model.validNonPlayerTargetsFromChatting;

        //Add the nonplayers
        _avatars.forEach( function( playerId :int, ...ignored) :void {
            if( !ArrayUtil.contains(playerIds, playerId )) {
                if( isNaN(SharedPlayerStateClient.getBlood( playerId )) || SharedPlayerStateClient.getBlood( playerId ) > 1 ) {
                    //Check if they have chatted enough
                    if( ArrayUtil.contains( validCHatTargets, playerId) ) {
                        validIds.add( playerId );
                    }
                }
            }
        });

        //Add players in 'bare' mode
        for each( var playerId :int in playerIds ) {

            if( playerId == _ctrl.player.getPlayerId() ) {
                continue;
            }

            var action :String = SharedPlayerStateClient.getCurrentAction( playerId );
            if( action != null && action == VConstants.GAME_MODE_BARED
                && SharedPlayerStateClient.getBlood( playerId ) > 1 ) {

                validIds.add( playerId );
            }
        }

        return validIds;
    }

    protected function getPotentialPredatorIds() :HashSet
    {

        if( VConstants.LOCAL_DEBUG_MODE) {
            var a :HashSet = new HashSet();
            a.add(1);
            a.add(2);
            return a;
        }

        var preds :HashSet = new HashSet();

        var playerIds :Array = _ctrl.room.getPlayerIds();
        for each( var playerId :int in playerIds ) {
            if( SharedPlayerStateClient.isVampire( playerId )
                && SharedPlayerStateClient.getCurrentAction( playerId ) != VConstants.GAME_MODE_BARED ) {
                preds.add( playerId );
            }
        }

        return preds;

    }

    public function get displayMode() :int
    {
        return _displayMode;
    }
    public function setDisplayMode( mode :int, selectedPlayer :int = 0, multiPredators :Boolean = false ) :void
    {
        _displayMode = mode;
        var validIds :HashSet;
        var predators :HashSet;

        switch( mode ) {
            case DISPLAY_MODE_SHOW_INFO_ALL_AVATARS:
//                trace("DISPLAY_MODE_SHOW_INFO_ALL_AVATARS");
                _displaySprite.addChild( _paintableOverlay );
//                trace("avatars=" + _avatars.size());
                _avatars.forEach( function( id :int, avatar :VampireAvatarHUD) :void {
                    avatar.setDisplayModeShowInfo();
                });


                break;
            case DISPLAY_MODE_SHOW_FEED_TARGET:
//                trace("DISPLAY_MODE_SHOW_FEED_TARGET");
                _displaySprite.addChild( _paintableOverlay );

                if( !ClientContext.model.isVampire() && !VConstants.LOCAL_DEBUG_MODE) {
                    break;
                }
                predators = getPotentialPredatorIds();
                _avatars.forEach( function( id :int, avatar :VampireAvatarHUD) :void {
                    if( selectedPlayer == avatar.playerId ) {
//                        avatar.selected = true;
                        avatar.setSelectedForFeed( predators.size() > 1 );
                    }
                    else {
                        avatar.setDisplayModeInvisible();
                    }
                });
                break;
            case DISPLAY_MODE_SHOW_VALID_TARGETS:
//                trace("DISPLAY_MODE_SHOW_VALID_TARGETS");
                _displaySprite.addChild( _paintableOverlay );

                if( !ClientContext.model.isVampire() && !VConstants.LOCAL_DEBUG_MODE) {
//                    trace("no vampire");
                    break;
                }
                validIds = getValidPlayerIdTargets();
                predators = getPotentialPredatorIds();
//                trace("validIds=" + validIds.toArray());
                _avatars.forEach( function( id :int, avatar :VampireAvatarHUD) :void {
                    if( validIds.contains( avatar.playerId ) ) {
//                        trace("  selectable " + avatar);
                        avatar.setDisplayModeSelectableForFeed( predators.size() > 1 );
                    }
                    else {
//                        trace("  Invisible " + avatar);
//                        avatar.setDisplayModeInvisible();
                        avatar.setDisplayModeShowInfo();
                    }
                });
                break;
//            case DISPLAY_MODE_SHOW_FEED_TARGET:
//                _displaySprite.addChild( _paintableOverlay );
//
//                _avatars.forEach( function( id :int, avatar :VampireAvatarHUD) :void {
//                    if( selectedPlayer == avatar.playerId ) {
//                        avatar.setSelectedForFeed( multiPredators );
//                    }
//                    else {
//                        avatar.setDisplayModeInvisible();
//                    }
//                });
//                break;
//
            default://Off

//                trace("DISPLAY_MODE_OFF");
                _avatars.forEach( function( id :int, avatar :VampireAvatarHUD) :void {
                    avatar.setDisplayModeInvisible();
                });

//                if( _displaySprite.contains( _paintableOverlay ) ) {
//                    _displaySprite.removeChild( _paintableOverlay );
//                }
                _displayMode = DISPLAY_MODE_OFF;

        }

        var myAvatarHUD :VampireAvatarHUD = getVampireAvatar( _ctrl.player.getPlayerId() );
        if( myAvatarHUD != null ) {
            myAvatarHUD.setDisplayModeInvisible();
        }

    }

    override protected function update(dt:Number):void
    {
        super.update(dt);

        //Check for vampire/human colors
        //Get our vampire level, and compare with the color state of the avatar.
        _ctrl.room.getPlayerIds().forEach( function( playerId :int, ...ignored) :void {
           var level :int = SharedPlayerStateClient.getLevel( playerId );

           var colorScheme :String = (level < VConstants.MINIMUM_VAMPIRE_LEVEL ?
               VConstants.COLOR_SCHEME_HUMAN : VConstants.COLOR_SCHEME_VAMPIRE);

           var entityId :String = ClientContext.getPlayerEntityId( playerId );

           if( entityId == null ) {
               return;
           }

           var currentColorCheme :String = _ctrl.room.getEntityProperty(
               AvatarGameBridge.ENTITY_PROPERTY_CURRENT_COLOR_SCHEME, entityId ) as String;

           if( currentColorCheme == null || colorScheme != currentColorCheme ) {
               var colorFunction :Function = _ctrl.room.getEntityProperty(
               AvatarGameBridge.ENTITY_PROPERTY_CHANGE_COLOR_SCHEME_FUNCTION, entityId ) as Function;
               if( colorFunction != null ) {
                   colorFunction( colorScheme );
               }

           }
        });

//        setDisplayMode( _displayMode );


    }

    protected var _displayMode :int = 0;

    public static const DISPLAY_MODE_OFF :int = 0;
    public static const DISPLAY_MODE_SHOW_INFO_ALL_AVATARS :int = 1;
    public static const DISPLAY_MODE_SHOW_VALID_TARGETS :int = 2;
    public static const DISPLAY_MODE_SHOW_FEED_TARGET :int = 3;

    protected static const UPDATE_DISPLAY_TIMER_NAME :String = "updateVampireHUDTimer";


//    protected var _vampireAvatarManager :VampireAvatarHUDManager;
}
}