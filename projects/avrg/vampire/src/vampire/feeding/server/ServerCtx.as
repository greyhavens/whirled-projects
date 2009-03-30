package vampire.feeding.server {

import com.threerings.util.ArrayUtil;
import com.threerings.util.Log;
import com.whirled.avrg.AVRServerGameControl;
import com.whirled.avrg.RoomSubControlServer;
import com.whirled.contrib.simplegame.net.BasicMessageManager;
import com.whirled.contrib.simplegame.net.Message;

import vampire.feeding.*;
import vampire.feeding.net.*;

public class ServerCtx
{
    public var server :vampire.feeding.server.Server;

    public var gameId :int;
    public var roomCtrl :RoomSubControlServer;
    public var props :GamePropControl;
    public var nameUtil :NameUtil;

    public var playerIds :Array;
    public var preyBlood :Number;
    public var gameStartedCallback :Function;
    public var roundCompleteCallback :Function;
    public var gameCompleteCallback :Function;
    public var playerLeftCallback :Function;

    public var lastRoundScore :int;

    public function get preyId () :int
    {
        return props.get(Props.PREY_ID) as int;
    }

    public function set preyId (id :int) :void
    {
        props.set(Props.PREY_ID, id, true);
    }

    public function get preyIsAi () :Boolean
    {
        return props.get(Props.PREY_IS_AI) as Boolean;
    }

    public function set preyIsAi (val :Boolean) :void
    {
        props.set(Props.PREY_IS_AI, val, true);
    }

    public function get preyBloodType () :int
    {
        return props.get(Props.PREY_BLOOD_TYPE) as int;
    }

    public function set preyBloodType (val :int) :void
    {
        props.set(Props.PREY_BLOOD_TYPE, val, true);
    }

    public function get aiPreyName () :String
    {
        return props.get(Props.AI_PREY_NAME) as String;
    }

    public function set aiPreyName (val :String) :void
    {
        props.set(Props.AI_PREY_NAME, val, true);
    }

    public function get lobbyLeader () :int
    {
        return props.get(Props.LOBBY_LEADER) as int;
    }

    public function set lobbyLeader (val :int) :void
    {
        props.set(Props.LOBBY_LEADER, val, true);
    }

    public function get bloodBondProgress () :int
    {
        return props.get(Props.BLOOD_BOND_PROGRESS) as int;
    }

    public function set bloodBondProgress (val :int) :void
    {
        props.set(Props.BLOOD_BOND_PROGRESS, val, true);
    }

    public function getPredatorIds () :Array
    {
        var predators :Array = playerIds.slice();
        ArrayUtil.removeFirst(predators, preyId);
        return predators;
    }

    public function canContinueFeeding () :Boolean
    {
        if (preyId == Constants.NULL_PLAYER && !preyIsAi) {
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
