package popcraft.net {

import com.whirled.contrib.simplegame.net.*;

public class ChecksumMessage
    implements Message
{
    public var playerId :int;
    public var tick :uint;
    public var checksum :uint;
    public var details :String;

    public function ChecksumMessage (playerId :int, tick :uint, checksum :uint, details :String)
    {
        this.playerId = playerId;
        this.tick = tick;
        this.checksum = checksum;
        this.details = details;
    }

    public function get name () :String
    {
        return messageName;
    }

    public function toString () :String
    {
        return new String(
           "[CHECKSUM. playerId: " + playerId +
           ". tick: " + tick +
           ". checksum: " + checksum +
           ". details: " + details +
           "]");
    }

    public static function createFactory () :MessageFactory
    {
        return new ChecksumMessageFactory();
    }

    public static function get messageName () :String
    {
        return "Checksum";
    }
}

}

import com.whirled.contrib.simplegame.net.*;
import popcraft.net.ChecksumMessage;

class ChecksumMessageFactory
    implements MessageFactory
{
    public function serializeForNetwork (message :Message) :Object
    {
        var msg :ChecksumMessage = (message as ChecksumMessage);
        return { playerId: msg.playerId, tick: msg.tick, checksum: msg.checksum, details: msg.details };
    }

    public function deserializeFromNetwork (obj :Object) :Message
    {
        return new ChecksumMessage(int(obj.playerId), uint(obj.tick), uint(obj.checksum), String(obj.details));
    }
}

