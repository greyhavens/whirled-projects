package vampire.net.messages
{
import com.threerings.util.ClassUtil;

import flash.utils.ByteArray;

public class StartFeedingClientMsg extends BaseGameMsg
{
    public function StartFeedingClientMsg (playerId:int = 0, gameId :int = 0,
        isPrimPred :Boolean = false)
    {
        super(playerId);
        _gameId = gameId;
        _isPrimPred = isPrimPred;
    }

    override public function toBytes (bytes :ByteArray = null) :ByteArray
    {
        var bytes :ByteArray = super.toBytes(bytes);
        bytes.writeInt(_gameId);
        bytes.writeBoolean(_isPrimPred);
        return bytes;
    }

    override public function fromBytes (bytes :ByteArray) :void
    {
        super.fromBytes(bytes);
        _gameId = bytes.readInt();
        _isPrimPred = bytes.readBoolean();
    }

    public function get gameId () :int
    {
       return _gameId;
    }

    public function get isPrimaryPredator () :Boolean
    {
       return _isPrimPred;
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
    protected var _isPrimPred :Boolean;

    public static const NAME :String = "Message: Start Feeding Client";

}
}