package vampire.net.messages
{
    import flash.utils.ByteArray;

public class MovePredIntoPositionMsg extends BaseGameMsg
{
    public function MovePredIntoPositionMsg (playerId:int = 0, preyId :int = 0,
        predIndex :int = 0)
    {
        super(playerId);
        _preyId = preyId;
       _predIndex = predIndex;
    }

    override public function fromBytes (bytes :ByteArray) :void
    {
        super.fromBytes(bytes);
        _preyId = bytes.readInt();
        _predIndex = bytes.readInt();
    }

    override public function toBytes (bytes :ByteArray = null) :ByteArray
    {
        var bytes :ByteArray = super.toBytes(bytes);
        bytes.writeInt(_preyId);
        bytes.writeInt(_predIndex);
        return bytes;
    }

    public function get preyId () :int
    {
       return _preyId;
    }

    public function get predIndex () :int
    {
       return _predIndex;
    }

    override public function get name () :String
    {
       return NAME;
    }

    protected var _preyId :int;
    protected var _predIndex :int;

    public static const NAME :String = "Message: Move 2nd Pred";

}
}