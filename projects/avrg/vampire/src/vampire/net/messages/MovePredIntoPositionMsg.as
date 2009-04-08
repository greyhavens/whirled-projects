package vampire.net.messages
{
    import flash.utils.ByteArray;

public class MovePredIntoPositionMsg extends BaseGameMsg
{
    public function MovePredIntoPositionMsg (playerId:int = 0, preyId :int = 0,
        standBehindPrey :Boolean = false, predIndex :int = 0, targetLocation :Array = null)
    {
        super(playerId);
        _preyId = preyId;
        _standBehindPrey = standBehindPrey;
       _predIndex = predIndex;
       _preyLocation = targetLocation != null ? targetLocation : [0,0,0,0];
    }

    override public function fromBytes (bytes :ByteArray) :void
    {
        super.fromBytes(bytes);
        _preyId = bytes.readInt();
        _standBehindPrey = bytes.readBoolean();
        _predIndex = bytes.readInt();

        var x :Number = bytes.readFloat();
        var y :Number = bytes.readFloat();
        var z :Number = bytes.readFloat();
        var r :Number = bytes.readFloat();

        _preyLocation = [x, y, z, r];
    }

    override public function toBytes (bytes :ByteArray = null) :ByteArray
    {
        var bytes :ByteArray = super.toBytes(bytes);
        bytes.writeInt(_preyId);
        bytes.writeBoolean(_standBehindPrey);
        bytes.writeInt(_predIndex);
        bytes.writeFloat(_preyLocation[0]);
        bytes.writeFloat(_preyLocation[1]);
        bytes.writeFloat(_preyLocation[2]);
        bytes.writeFloat(_preyLocation[3]);
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

    public function get preyLocation () :Array
    {
       return _preyLocation;
    }

    public function get isStandingBehindPrey () :Boolean
    {
       return _standBehindPrey;
    }

    override public function get name () :String
    {
       return NAME;
    }

    protected var _preyId :int;
    protected var _standBehindPrey :Boolean;
    protected var _predIndex :int;
    protected var _preyLocation :Array;

    public static const NAME :String = "Message: Move Pred";

}
}