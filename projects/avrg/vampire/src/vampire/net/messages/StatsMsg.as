package vampire.net.messages
{
import flash.utils.ByteArray;

public class StatsMsg extends BaseGameMsg
{
    public function StatsMsg(playerId:int = 0, stats :ByteArray = null)
    {
        super(playerId);
        _compressedStatsString = stats;
        if (_compressedStatsString == null) {
            _compressedStatsString = new ByteArray();
        }
    }
    override public function fromBytes (bytes :ByteArray) :void
    {
        super.fromBytes(bytes);
        var length :int = bytes.readInt();
        _compressedStatsString = new ByteArray();
        bytes.readBytes(_compressedStatsString, 0, length);
    }

    override public function toBytes (bytes :ByteArray = null) :ByteArray
    {
        var bytes :ByteArray = super.toBytes(bytes);
        bytes.writeInt(_compressedStatsString.length);
        bytes.writeBytes(_compressedStatsString);
        return bytes;
    }

    public function get compressedString () :ByteArray
    {
       return _compressedStatsString;
    }

    override public function get name () :String
    {
       return NAME;
    }

    protected var _compressedStatsString :ByteArray;

    public static const NAME :String = "Message: Stats";
}
}