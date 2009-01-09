package flashmob.client {

import com.whirled.avrg.*;
import com.whirled.contrib.simplegame.MainLoop;

import flash.geom.Point;
import flash.geom.Rectangle;
import flash.utils.getTimer;

import flashmob.*;
import flashmob.client.view.BasicYesNoMode;
import flashmob.client.view.GameUIView;
import flashmob.client.view.HitTester;
import flashmob.data.*;
import flashmob.party.*;

public class ClientContext
{
    public static var mainLoop :MainLoop;
    public static var gameCtrl :AVRGameControl;
    public static var partyId :int;
    public static var localPlayerId :int;
    public static var playerIds :Array = [];
    public static var inMsg :PartyMsgReceiver;
    public static var outMsg :PartyMsgSender;
    public static var props :PartyPropGetControl;
    public static var spectacle :Spectacle;
    public static var hitTester :HitTester;
    public static var gameUIView :GameUIView;

    public static function get fullDisplayBounds () :Rectangle
    {
        return gameCtrl.local.getPaintableArea(true);
    }

    public static function get roomDisplayBounds () :Rectangle
    {
        return gameCtrl.local.getPaintableArea(false);
    }

    public static function get waitingForPlayers () :Boolean
    {
        return props.get(Constants.PROP_WAITINGFORPLAYERS) as Boolean;
    }

    public static function getPlayerRoomLoc (playerId :int) :Point
    {
        var avatar :AVRGameAvatar = getAvatarInfo(playerId);
        return (avatar != null ? locToRoom(avatar.x, avatar.y, avatar.z) : null);
    }

    public static function locToRoom (x :Number, y :Number, z :Number) :Point
    {
        return gameCtrl.local.locationToRoom(x, y, z);
    }

    public static function sendAgentMsg (name :String, value :Object = null) :void
    {
        outMsg.sendMessage(name, value);
    }

    public static function get timeNow () :Number
    {
        return flash.utils.getTimer() / 1000;
    }

    public static function getAvatarInfo (playerId :int) :AVRGameAvatar
    {
        return gameCtrl.room.getAvatarInfo(playerId);
    }

    public static function get isPartyLeader () :Boolean
    {
        return (playerIds.length == 0 || playerIds[0] == localPlayerId);
        // TODO - fix this when party support is added
    }

    public static function get isPartied () :Boolean
    {
        return true;
        // TODO - fix this when party support is added
        //return (gameCtrl.isConnected() && gameCtrl.game.getPlayerInfo(localPlayerId).partyId != 0);
    }

    public static function confirmQuit () :void
    {
        mainLoop.pushMode(new BasicYesNoMode(QUIT_TEXT, quit, mainLoop.popMode));
    }

    public static function quit () :void
    {
        if (gameCtrl.isConnected()) {
            gameCtrl.player.deactivateGame();
        }
    }

    protected static const QUIT_TEXT :String = "If you leave now, you'll cancel the spectacle " +
        "for the entire party! Are you sure?"
}

}
