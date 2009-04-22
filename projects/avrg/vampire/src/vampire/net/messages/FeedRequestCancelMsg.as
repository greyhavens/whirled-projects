package vampire.net.messages
{
import com.threerings.util.ClassUtil;

import flash.utils.ByteArray;

public class FeedRequestCancelMsg extends BaseGameMsg
{
    public function FeedRequestCancelMsg(playerId:int = 0, targetPlayerId :int = 0)
    {
        super(playerId);
        _targetPlayerId = targetPlayerId;
    }

    override public function fromBytes (bytes :ByteArray) :void
    {
        super.fromBytes(bytes);
        _targetPlayerId = bytes.readInt();
    }

    override public function toBytes (bytes :ByteArray = null) :ByteArray
    {
        var bytes :ByteArray = super.toBytes(bytes);
        bytes.writeInt(_targetPlayerId);
        return bytes;
    }

    public function get targetPlayer () :int
    {
       return _targetPlayerId;
    }

    override public function get name () :String
    {
       return NAME;
    }

    override public function toString() :String
    {
        return ClassUtil.tinyClassName(this) + ": player=" + _playerId + ", targetPlayer=" + targetPlayer;
    }

    protected var _targetPlayerId :int;

    public static const NAME :String = "Message: Feed Request Cancel";

}
}