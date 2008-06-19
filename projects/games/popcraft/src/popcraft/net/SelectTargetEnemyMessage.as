package popcraft.net {

import com.whirled.contrib.simplegame.net.*;

public class SelectTargetEnemyMessage
    implements Message
{
    public var playerIndex :int;
    public var targetPlayerIndex :int;

    public function SelectTargetEnemyMessage (playerIndex :int, targetPlayerIndex :int)
    {
        this.playerIndex = playerIndex;
        this.targetPlayerIndex = targetPlayerIndex;
    }

    public function get name () :String
    {
        return messageName;
    }

    public function toString () :String
    {
        return "[SelectTargetEnemy. playerIndex: " + playerIndex + ". targetPlayerIndex: " + targetPlayerIndex + "]";
    }

    public static function createFactory () :MessageFactory
    {
        return new SelectTargetEnemyMessageFactory();
    }

    public static function get messageName () :String
    {
        return "SelectTargetEnemy";
    }
}

}

import com.whirled.contrib.simplegame.net.*;
import popcraft.net.SelectTargetEnemyMessage;
import flash.utils.ByteArray;
import flash.errors.EOFError;
import com.threerings.util.Log;

class SelectTargetEnemyMessageFactory
    implements MessageFactory
{
    public function serializeForNetwork (message :Message) :Object
    {
        var msg :SelectTargetEnemyMessage = (message as SelectTargetEnemyMessage);

        var ba :ByteArray = new ByteArray();
        ba.writeByte(msg.playerIndex);
        ba.writeByte(msg.targetPlayerIndex);

        return ba;
    }

    public function deserializeFromNetwork (obj :Object) :Message
    {
        var msg :SelectTargetEnemyMessage;

        var ba :ByteArray = obj as ByteArray;
        if (null == ba) {
            log.warning("received non-ByteArray message");
        } else {
            try {
                var selectingPlayer :int = ba.readByte();
                var targetPlayer :int = ba.readByte();

                msg = new SelectTargetEnemyMessage(selectingPlayer, targetPlayer);

            } catch (err :EOFError) {
                log.warning("received bad data");
            }
        }

        return msg;
    }

    protected static const log :Log = Log.getLog(SelectTargetEnemyMessageFactory);
}

