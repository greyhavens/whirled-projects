package com.whirled.contrib.avrg
{
import com.threerings.util.HashMap;
import com.threerings.util.HashSet;
import com.threerings.util.Log;
import com.whirled.EntityControl;
import com.whirled.avrg.AVRGameControl;
import com.whirled.avrg.AVRGamePlayerEvent;
import com.whirled.avrg.AVRGameRoomEvent;
import com.threerings.flashbang.AppMode;
import com.threerings.flashbang.objects.SimpleTimer;

import vampire.data.VConstants;

//import vampire.data.Codes;
//import vampire.data.Constants;

/**
 * Paints the individual AvatarHUD elements when e.g. locations change.
 *
 */
public class TargetingOverlayAvatars extends TargetingOverlay
{
    public function TargetingOverlayAvatars(ctrl :AVRGameControl,  targetClickedCallback:Function = null)
    {
        super([], [], [], targetClickedCallback, null);

        _ctrl = ctrl;

        _avatars = new HashMap();

        registerListener(_ctrl.player, AVRGamePlayerEvent.ENTERED_ROOM, checkAvatarsAndUsersMatch);
        registerListener(ctrl.room, AVRGameRoomEvent.PLAYER_ENTERED, checkAvatarsAndUsersMatch);
        registerListener(ctrl.room, AVRGameRoomEvent.PLAYER_LEFT, checkAvatarsAndUsersMatch);
    }

    override protected function addedToDB():void
    {
        super.addedToDB();
        //Check for missing avatars/HUDs every second.  Lets not overload the client on checking.
        var avatarCheckTimer :SimpleTimer = new SimpleTimer(1, checkAvatarsAndUsersMatch, true, "avatarCheck");
        addGameObject(avatarCheckTimer);
    }

    override protected function update(dt:Number) :void
    {
        super.update(dt);

        //Remove destroyed avatars.
        var isDeadAvatars :Boolean = false;
        _avatars.forEach(function (userId :int, avatarHUD :AvatarHUD) :void
        {
           if(!avatarHUD.isLiveObject) {
               isDeadAvatars = true;
           }
        });

        if(isDeadAvatars) {
            for each(var userId :int in _avatars.keys()) {
                var avatar :AvatarHUD = _avatars.get(userId) as AvatarHUD;
                if(avatar != null && !avatar.isLiveObject) {
                    _avatars.remove(userId);
                }
            }
        }
    }




    override protected function destroyed() :void
    {
        super.destroyed();
        _ctrl = null;
        _avatars.clear();
    }

    protected function get mode() :AppMode
    {
        return db as AppMode;
    }

    protected function get playerEntityId () :String
    {
        if(_playerEntityId == null) {
            for each(var entityId :String in _ctrl.room.getEntityIds(EntityControl.TYPE_AVATAR)) {

                var entityUserId :int = int(_ctrl.room.getEntityProperty(EntityControl.PROP_MEMBER_ID, entityId));

                if(entityUserId == _ctrl.player.getPlayerId()) {
                    _playerEntityId = entityId;
                    break;
                }

            }
        }

        return _playerEntityId;
    }





    /**
    * Subclasses can override this.
    */
    protected function createPlayerAvatar(userId :int) :AvatarHUD
    {
        return new AvatarHUD(_ctrl, userId);
    }

    protected function checkAvatarsAndUsersMatch(...ignored) :void
    {

//        if(VConstants.LOCAL_DEBUG_MODE) {
//            return;
//        }
        //Check for room avatars without a HUD
        var allUserIds :HashSet = new HashSet();
        var userId :int;
        for each(var entityId :String in _ctrl.room.getEntityIds(EntityControl.TYPE_AVATAR)) {
            userId = int(_ctrl.room.getEntityProperty(EntityControl.PROP_MEMBER_ID, entityId));

            if(!isShowingOwnAvatar && userId == _ctrl.player.getPlayerId()) {
                continue;
            }

            allUserIds.add(userId);
//            trace("Creating avatarHUD for " + userId);
            if(!_avatars.containsKey(userId)) {
                var playerAvatar :AvatarHUD = createPlayerAvatar(userId);
                addSceneObject(playerAvatar, _paintableOverlay);
//                mode.addSceneObject(playerAvatar, _paintableOverlay);
                _avatars.put(userId, playerAvatar);
            }

        }

        //Remove AvatarHUDs of players not in the room anymore
        for each(userId in _avatars.keys()) {
            if(!allUserIds.contains(userId)) {
                (_avatars.get(userId) as AvatarHUD).destroySelf();
                _avatars.remove(userId);
            }
        }

//        _avatars.forEach(function(userId :int, avatar :AvatarHUD) :void {
//            var playerId :int = avatar.playerId;
//
//            //Add the avatar to the db if not yet added.
//            if(avatar.db == null) {
//                mode.addSceneObject(avatar, _paintableOverlay);
//            }
//
//            if(avatar.sprite != null && !_paintableOverlay.contains(avatar.sprite)) {
//                _paintableOverlay.addChild(avatar.sprite);
//            }
//        });
    }

    public function getAvatar(playerId :int) :AvatarHUD
    {
        return _avatars.get(playerId);
    }



    protected var _ctrl :AVRGameControl;
    protected var _playerEntityId :String;
    protected var _avatars :HashMap;
    public var isShowingOwnAvatar :Boolean = false;



    protected static const log :Log = Log.getLog(TargetingOverlayAvatars);

}
}
