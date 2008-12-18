package flashmob.client {

import com.whirled.avrg.AVRGameControl;
import com.whirled.contrib.simplegame.MainLoop;

import flash.utils.getTimer;

import flashmob.data.Spectacle;
import flashmob.party.PartyMsgReceiver;
import flashmob.party.PartyMsgSender;
import flashmob.party.PartyPropGetControl;

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

    public static function sendAgentMsg (name :String, value :Object = null) :void
    {
        outMsg.sendMessage(name, value);
    }

    public static function get timeNow () :Number
    {
        return flash.utils.getTimer() / 1000;
    }

    public static function get isLocalPlayerPartyLeader () :Boolean
    {
        return true;
        //return (playerIds.length > 0 && playerIds[0] == localPlayerId);
        // TODO - fix this when party support is added
    }

    public static function get isLocalPlayerPartied () :Boolean
    {
        return true;
        // TODO - fix this when party support is added
        //return (gameCtrl.isConnected() && gameCtrl.game.getPlayerInfo(localPlayerId).partyId != 0);
    }

    public static function quit () :void
    {
        if (gameCtrl.isConnected()) {
            gameCtrl.player.deactivateGame();
        }
    }
}

}
