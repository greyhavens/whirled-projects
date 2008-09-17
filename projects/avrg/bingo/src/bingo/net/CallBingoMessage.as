package bingo.net {

import com.threerings.util.StringUtil;

import flash.utils.ByteArray;

public class CallBingoMessage
{
    public var roundId :int;

    public static function create (roundId :int) :CallBingoMessage
    {
        var msg :CallBingoMessage = new CallBingoMessage();
        msg.roundId = roundId;
    }

    public static function fromBytes (bytes :ByteArray) :CallBingoMessage
    {
        var msg :CallBingoMessage = new CallBingoMessage();
        msg.fromBytes(bytes);
        return msg;
    }

    public function toBytes (bytes :ByteArray = null) :ByteArray
    {
        bytes = (bytes != null ? bytes : new ByteArray());
        bytes.writeInt(roundId);
        return bytes;
    }

    public function fromBytes (bytes :ByteArray) :void
    {
        roundId = bytes.readInt();
    }

    public function toString () :String
    {
        return StringUtil.simpleToString(this, [ "roundId" ]);
    }

}

}
