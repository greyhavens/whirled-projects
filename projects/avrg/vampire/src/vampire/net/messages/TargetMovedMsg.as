package vampire.net.messages
{
import flash.utils.ByteArray;

public class TargetMovedMsg extends BaseGameMsg
{
    public function TargetMovedMsg (playerId:int = 0, targetPlayerId :int = 0)
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
        bytes.writeInt( _targetPlayerId );
        return bytes;
    }

    override public function get name () :String
    {
       return NAME;
    }


    protected var _targetPlayerId :int;
    public static const NAME :String = "Message: Target Moved";
}
}