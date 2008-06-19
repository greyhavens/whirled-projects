package popcraft.net {

import com.whirled.contrib.simplegame.net.*;

public class CreateUnitMessage
    implements Message
{
    public var playerIndex :int;
    public var unitType :int;

    public function CreateUnitMessage (playerIndex :int, unitType :int)
    {
        this.unitType = unitType;
        this.playerIndex = playerIndex;
    }

    public function get name () :String
    {
        return messageName;
    }

    public function toString () :String
    {
        return "[CreateUnit. playerIndex: " + playerIndex + ". unitType: " + unitType + "]";
    }

    public static function createFactory () :MessageFactory
    {
        return new CreateUnitMessageFactory();
    }

    public static function get messageName () :String
    {
        return "CreateUnit";
    }
}

}

import com.whirled.contrib.simplegame.net.*;
import popcraft.net.CreateUnitMessage;
import flash.utils.ByteArray;
import flash.errors.EOFError;
import com.threerings.util.Log;

class CreateUnitMessageFactory
    implements MessageFactory
{
    public function serializeForNetwork (message :Message) :Object
    {
        var msg :CreateUnitMessage = (message as CreateUnitMessage);

        var ba :ByteArray = new ByteArray();
        ba.writeByte(msg.unitType);
        ba.writeByte(msg.playerIndex);

        return ba;
    }

    public function deserializeFromNetwork (obj :Object) :Message
    {
        var msg :CreateUnitMessage;

        var ba :ByteArray = obj as ByteArray;
        if (null == ba) {
            log.warning("received non-ByteArray message");
        } else {
            try {
                var unitType :int = ba.readByte();
                var owningPlayer :int = ba.readByte();

                msg = new CreateUnitMessage(owningPlayer, unitType);

            } catch (err :EOFError) {
                log.warning("received bad data");
            }
        }

        return msg;
    }

    protected static const log :Log = Log.getLog(CreateUnitMessageFactory);
}

