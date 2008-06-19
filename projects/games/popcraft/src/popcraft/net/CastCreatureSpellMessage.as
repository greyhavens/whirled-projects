package popcraft.net {

import com.whirled.contrib.simplegame.net.*;

public class CastCreatureSpellMessage
    implements Message
{
    public var playerIndex :int;
    public var spellType :int;

    public function CastCreatureSpellMessage (playerIndex :int, spellType :int)
    {
        this.playerIndex = playerIndex;
        this.spellType = spellType;
    }

    public function get name () :String
    {
        return messageName;
    }

    public function toString () :String
    {
        return "[CastCreatureSpell. playerIndex: " + playerIndex + ". spellType: " + spellType + "]";
    }

    public static function createFactory () :MessageFactory
    {
        return new CastCreatureSpellMessageFactory();
    }

    public static function get messageName () :String
    {
        return "CastCreatureSpell";
    }
}

}

import com.whirled.contrib.simplegame.net.*;
import popcraft.net.CastCreatureSpellMessage;
import flash.utils.ByteArray;
import flash.errors.EOFError;
import com.threerings.util.Log;

class CastCreatureSpellMessageFactory
    implements MessageFactory
{
    public function serializeForNetwork (message :Message) :Object
    {
        var msg :CastCreatureSpellMessage = (message as CastCreatureSpellMessage);

        var ba :ByteArray = new ByteArray();
        ba.writeByte(msg.playerIndex);
        ba.writeByte(msg.spellType);

        return ba;
    }

    public function deserializeFromNetwork (obj :Object) :Message
    {
        var msg :CastCreatureSpellMessage;

        var ba :ByteArray = obj as ByteArray;
        if (null == ba) {
            log.warning("received non-ByteArray message");
        } else {
            try {
                var playerIndex :int = ba.readByte();
                var spellType :int = ba.readByte();

                msg = new CastCreatureSpellMessage(playerIndex, spellType);

            } catch (err :EOFError) {
                log.warning("received bad data");
            }
        }

        return msg;
    }

    protected static const log :Log = Log.getLog(CastCreatureSpellMessageFactory);
}

