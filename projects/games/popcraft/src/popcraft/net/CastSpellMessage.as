package popcraft.net {

import com.whirled.contrib.simplegame.net.*;

public class CastSpellMessage
    implements Message
{
    public var playerId :uint;
    public var spellType :uint;

    public function CastSpellMessage (playerId :uint, spellType :uint)
    {
        this.playerId = playerId;
        this.spellType = spellType;
    }

    public function get name () :String
    {
        return messageName;
    }

    public function toString () :String
    {
        return "[CastSpell. playerId: " + playerId + ". spellType: " + spellType + "]";
    }

    public static function createFactory () :MessageFactory
    {
        return new CastSpellMessageFactory();
    }

    public static function get messageName () :String
    {
        return "CastSpell";
    }
}

}

import com.whirled.contrib.simplegame.net.*;
import popcraft.net.CastSpellMessage;
import flash.utils.ByteArray;
import flash.errors.EOFError;
import com.threerings.util.Log;

class CastSpellMessageFactory
    implements MessageFactory
{
    public function serializeForNetwork (message :Message) :Object
    {
        var msg :CastSpellMessage = (message as CastSpellMessage);

        var ba :ByteArray = new ByteArray();
        ba.writeByte(msg.playerId);
        ba.writeByte(msg.spellType);

        return ba;
    }

    public function deserializeFromNetwork (obj :Object) :Message
    {
        var msg :CastSpellMessage;

        var ba :ByteArray = obj as ByteArray;
        if (null == ba) {
            log.warning("received non-ByteArray message");
        } else {
            try {
                var playerId :uint = ba.readByte();
                var spellType :uint = ba.readByte();

                msg = new CastSpellMessage(playerId, spellType);

            } catch (err :EOFError) {
                log.warning("received bad data");
            }
        }

        return msg;
    }

    protected static const log :Log = Log.getLog(CastSpellMessageFactory);
}

