package vampire.net.messages
{
import com.threerings.util.ClassUtil;

import flash.utils.ByteArray;

public class StartFeedingClientMsg extends BaseGameMsg
{
    public function StartFeedingClientMsg (playerId:int = 0, gameId :int = 0)
    {
        super(playerId);
        _gameId = gameId;
    }

    override public function toBytes (bytes :ByteArray = null) :ByteArray
    {
        var bytes :ByteArray = super.toBytes(bytes);
        bytes.writeInt(_gameId);
        return bytes;
    }

    override public function fromBytes (bytes :ByteArray) :void
    {
        super.fromBytes(bytes);
        _gameId = bytes.readInt();
    }

    public function get gameId () :int
    {
       return _gameId;
    }

    override public function get name () :String
    {
       return NAME;
    }

    override public function toString () :String
    {
        return ClassUtil.tinyClassName(this)
            + "gameId=" + _gameId
    }

    protected var _gameId :int;

    public static const NAME :String = "Message: Start Feeding Client";

}
}