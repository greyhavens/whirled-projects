package vampire.net.messages
{
import com.threerings.util.ClassUtil;

import flash.utils.ByteArray;

/**
 * When a vampire successfully feeds on something.  This event is fired from the client
 * every time a blood amount is gained.
 */
public class SuccessfulFeedMsg extends BaseGameMsg
{
    public function SuccessfulFeedMsg(biterId :int = 0, eatenId :int = 0)
    {
        super(playerId);
        _eatenId = eatenId;
    }

    override public function fromBytes (bytes :ByteArray) :void
    {
        super.fromBytes(bytes);
        _eatenId = bytes.readInt();
    }

    override public function toBytes (bytes :ByteArray = null) :ByteArray
    {
        var bytes :ByteArray = super.toBytes(bytes);
        bytes.writeInt(_eatenId);
        return bytes;
    }

    public function get biter () :int
    {
       return _playerId;
    }

    public function get eatenPlayerId () :int
    {
       return _eatenId;
    }

    override public function get name () :String
    {
       return NAME;
    }

    override public function toString() :String
    {
        return ClassUtil.tinyClassName(this) + ": player=" + _playerId + ", _eatenId=" + _eatenId;
    }

    protected var _eatenId :int;

    public static const NAME :String = "Message: Successful";

}
}