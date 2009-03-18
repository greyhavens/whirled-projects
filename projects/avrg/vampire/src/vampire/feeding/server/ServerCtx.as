package vampire.feeding.server {

import com.threerings.util.ArrayUtil;
import com.threerings.util.Log;
import com.whirled.avrg.AVRServerGameControl;
import com.whirled.avrg.RoomSubControlServer;
import com.whirled.contrib.simplegame.net.BasicMessageManager;
import com.whirled.contrib.simplegame.net.Message;

import flash.utils.Dictionary;

import vampire.feeding.*;
import vampire.feeding.net.*;

public class ServerCtx
{
    public var server :vampire.feeding.server.Server;

    public var gameId :int;
    public var playerIds :Array;
    public var preyId :int;
    public var preyIsAi :Boolean;
    public var preyBlood :Number;
    public var preyBloodType :int;
    public var gameStartedCallback :Function;
    public var roundCompleteCallback :Function;
    public var gameCompleteCallback :Function;
    public var playerLeftCallback :Function;

    public var roomCtrl :RoomSubControlServer;
    public var props :GamePropControl;
    public var nameUtil :NameUtil;

    public var lastRoundScore :int;

    public function getPrimaryPredatorId () :int
    {
        for each (var playerId :int in playerIds) {
            if (playerId != preyId) {
                return playerId;
            }
        }

        return Constants.NULL_PLAYER;
    }

    public function getPredatorIds () :Array
    {
        var predators :Array = playerIds.slice();
        ArrayUtil.removeFirst(predators, preyId);
        return predators;
    }

    public function canContinueFeeding () :Boolean
    {
        if (preyId == 0 && !preyIsAi) {
            return false;
        } else if (getPredatorIds().length == 0) {
            return false;
        }

        return true;
    }

    public function get gameCtrl () :AVRServerGameControl
    {
        return _gameCtrl;
    }

    public function get msgMgr () :BasicMessageManager
    {
        return _msgMgr;
    }

    public function sendMessage (msg :Message, toPlayer :int = 0) :void
    {
        /*if( !roomCtrl.isConnected() ) {
            log.info("Not sending msg (not connected) '" + msg.name + "' to " + (toPlayer != 0 ? toPlayer : "ALL"));
            return;
        }*/

        var name :String = nameUtil.encodeName(msg.name);
        var val :Object = msg.toBytes();
        if (toPlayer == 0) {
            roomCtrl.sendMessage(name, val);
        } else {
            gameCtrl.getPlayer(toPlayer).sendMessage(name, val);
        }

        log.info("Sending msg '" + msg.name + "' to " + (toPlayer != 0 ? toPlayer : "ALL"));
    }

    public function logBadMessage (senderId :int, msgName :String, reason :String = null,
                                   err :Error = null) :void
    {
        var args :Array = [
            "Bad game message",
            "name", msgName,
            "sender", senderId
        ];

        if (reason != null) {
            args.push("problem", reason);
        }

        if (err != null) {
            args.push(err);
        }

        log.warning.apply(null, args);
    }

    public static function init (gameCtrl :AVRServerGameControl) :void
    {
        _gameCtrl = gameCtrl;
        _msgMgr = new BasicMessageManager();
        FeedingUtil.initMessageManager(_msgMgr);
    }

    protected static var _gameCtrl :AVRServerGameControl;
    protected static var _msgMgr :BasicMessageManager = new BasicMessageManager();

    protected static const log :Log = Log.getLog(ServerCtx);
}

}
