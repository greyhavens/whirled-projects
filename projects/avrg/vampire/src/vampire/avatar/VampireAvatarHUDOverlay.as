package vampire.avatar
{
import com.threerings.util.ArrayUtil;
import com.threerings.util.HashSet;
import com.whirled.EntityControl;
import com.whirled.avrg.AVRGameControl;
import com.whirled.avrg.AVRGameRoomEvent;
import com.whirled.contrib.avrg.AvatarHUD;
import com.whirled.contrib.avrg.TargetingOverlayAvatars;

import flash.events.MouseEvent;

import framework.FakeAVRGContext;

import vampire.client.ClientContext;
import vampire.client.LoadBalancerClient;
import vampire.data.VConstants;


/**
 * Determines what/when to show over/on the avatars in the room.
 *
 *
 */
public class VampireAvatarHUDOverlay extends TargetingOverlayAvatars
{


    public function VampireAvatarHUDOverlay(ctrl:AVRGameControl)
    {
        super(ctrl);
        super.isShowingOwnAvatar = true;

        //If an avatar changes state, make sure we are updated.
        _paintableOverlay.mouseEnabled = true;
        registerListener(_ctrl.room, AVRGameRoomEvent.AVATAR_CHANGED,
            function(e :AVRGameRoomEvent) :void {
                setDisplayMode(_displayMode);
            }
       );


        //If you click outside the feeding buttons, return to the default display.
        registerListener(_paintableOverlay, MouseEvent.CLICK,
            function(e :MouseEvent) :void {
                if (e.target == _paintableOverlay){
                    setDisplayMode(DISPLAY_MODE_OFF);
                }
            }
       );

        if(VConstants.LOCAL_DEBUG_MODE) {
            p1 = new VampireAvatarHUD(ctrl,  1);
            _avatars.put(p1.playerId, p1);
            p1.isPlayer = true;
            p1.setHotspot([100, 200]);
            p1.setLocation([0.6, 0, 0.5], 2);

            var p2 :VampireAvatarHUD = new VampireAvatarHUD(ctrl,  2);
            _avatars.put(p2.playerId, p2);
            p2.isPlayer = true;
            p2.setHotspot([100, 200]);
            p2.setLocation([0.3, 0, 1.0], 3);

            var p3 :VampireAvatarHUD = new VampireAvatarHUD(ctrl,  3);
            _avatars.put(p3.playerId, p3);
            p3.isPlayer = true;
            p3.setHotspot([100, 200]);
            p3.setLocation([0.9, 0, 0.7], 3);
        }

        setDisplayMode(DISPLAY_MODE_OFF);

//        _loadBalancer = new LoadBalancerClient(ClientContext.ctrl, _paintableOverlay);
//        addSimObject(_loadBalancer);
    }

    override protected function addedToDB():void
    {
        super.addedToDB();
        if(VConstants.LOCAL_DEBUG_MODE) {

            for each(var p :AvatarHUD in _avatars.values()) {
                mode.addSceneObject(p, _paintableOverlay);
            }
        }

//        addSimObject(_loadBalancer);
    }

    override protected function destroyed():void
    {
        super.destroyed();
        if(db != null && db.getObjectNamed(UPDATE_DISPLAY_TIMER_NAME) != null) {
            db.getObjectNamed(UPDATE_DISPLAY_TIMER_NAME).destroySelf();
        }
    }

    override protected function createPlayerAvatar(userId :int) :AvatarHUD
    {
        var av :VampireAvatarHUD = new VampireAvatarHUD(_ctrl, userId);
        return av;
    }

    public function getVampireAvatar(playerId :int) :VampireAvatarHUD
    {
        return getAvatar(playerId) as VampireAvatarHUD;
    }

    public function get avatars() :Array
    {
        return _avatars.values();
    }

    protected function getValidPlayerIdTargets() :HashSet
    {
        //Debugging mode
        if(VConstants.LOCAL_DEBUG_MODE) {
            var a :HashSet = new HashSet();
            FakeAVRGContext.playerIds.forEach(function(playerId :int, ...ignored) :void {
                a.add(playerId);

            });
            a.remove(ClientContext.ourPlayerId);
            return a;
        }
        var validIds :HashSet = new HashSet();

        var playersAlreadyFeeding :Array = ClientContext.model.playersFeeding;

        log.debug("getValidPlayerIdTargets", "playersAlreadyFeeding", playersAlreadyFeeding);
        log.debug("getValidPlayerIdTargets", "avatarIds", ClientContext.getAvatarIds(true));

        for each(var avatarId :int in ClientContext.getAvatarIds(true)) {
            //Don't allow the targeting of players already feeding.
            if(!ArrayUtil.contains(playersAlreadyFeeding, avatarId)){
                validIds.add(avatarId);
            }
        }
        return validIds;
    }

    public function setDisplayMode(mode :int) :void
    {
        var previousDisplayMode :int = _displayMode;
        _displayMode = mode;
        var validIds :HashSet;
        var predators :HashSet;

        switch(mode) {
            case DISPLAY_MODE_SHOW_VALID_TARGETS:

                //Draw on the paintable overlay so it can intercept mouseclicks.
                //These clicks are interpreted as 'cancel'.
                _paintableOverlay.graphics.clear();
                _paintableOverlay.graphics.beginFill(0, 0);
                var screenWidth :Number = _ctrl.local.getPaintableArea().width;
                var screenHeight :Number = _ctrl.local.getPaintableArea().height;
                _paintableOverlay.graphics.drawRect(0, 0, screenWidth, screenHeight);
                _paintableOverlay.graphics.endFill();
                _displaySprite.addChild(_paintableOverlay);

                var playersInRoom :int = ClientContext.ctrl.room.getPlayerIds().length;
//                if (VConstants.LOCAL_DEBUG_MODE || playersInRoom == 1 ||
//                    playersInRoom >= VConstants.PLAYERS_IN_ROOM_TRIGGERING_BALANCING) {
//                    _loadBalancer.activate();
//                }

                validIds = getValidPlayerIdTargets();

                if (validIds.size() > 0) {
                    _avatars.forEach(function(id :int, avatar :VampireAvatarHUD) :void {
                        if(validIds.contains(avatar.playerId)) {
                            avatar.setDisplayModeSelectableForFeed();
                        }
                        else {
                            avatar.setDisplayModeInvisible();
                        }
                    });


                }
                else {
                    if (previousDisplayMode != mode) {
                        var avatars :int = _ctrl.room.getEntityIds(EntityControl.TYPE_AVATAR).length;
                        if (avatars > 1) {
                            _ctrl.local.feedback("Everyone is in the midst of feeding.  Either wait " +
                                " a little, or try hunting in a different room.");
                        }
                        else {
                            _ctrl.local.feedback("This room is empty! " +
                                "Try hunting in a different room.");
                        }
                    }
//                    setDisplayMode(DISPLAY_MODE_OFF);
                }


                break;
            default://Off

                _paintableOverlay.graphics.clear();
                _avatars.forEach(function(id :int, avatar :VampireAvatarHUD) :void {
                    avatar.setDisplayModeInvisible();
                });

//                _loadBalancer.deactivate();
        }

    }

    override protected function update(dt:Number):void
    {
        super.update(dt);
    }

    public function get displayMode() :int
    {
        return _displayMode;
    }

    //For debugging
    protected var p1 :VampireAvatarHUD;

    protected var _displayMode :int = 0;

//    protected var _loadBalancer :LoadBalancerClient;

    public static const DISPLAY_MODE_OFF :int = 0;
    public static const DISPLAY_MODE_SHOW_VALID_TARGETS :int = 2;

    protected static const UPDATE_DISPLAY_TIMER_NAME :String = "updateVampireHUDTimer";
}
}