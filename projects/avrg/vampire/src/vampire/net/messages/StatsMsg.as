package vampire.net.messages
{
import flash.utils.ByteArray;

public class StatsMsg extends BaseGameMsg
{
    public function StatsMsg(playerId:int = 0, type :String = null, data :ByteArray = null)
    {
        super(playerId);
        _type = type == null ? "" : type;
        _data = data;
        if (_data == null) {
            _data = new ByteArray();
        }
    }
    override public function fromBytes (bytes :ByteArray) :void
    {
        super.fromBytes(bytes);
        _type = bytes.readUTF();
        var length :int = bytes.readInt();
        _data = new ByteArray();
        bytes.readBytes(_data, 0, length);
    }

    override public function toBytes (bytes :ByteArray = null) :ByteArray
    {
        var bytes :ByteArray = super.toBytes(bytes);
        bytes.writeUTF(_type);
        bytes.writeInt(_data.length);
        bytes.writeBytes(_data);
        return bytes;
    }

    public function get data () :ByteArray
    {
       return _data;
    }

    public function get type () :String
    {
       return _type;
    }

    override public function get name () :String
    {
       return NAME;
    }

    protected var _data :ByteArray;
    protected var _type :String;

    public static const NAME :String = "Message: Stats";
    public static const TYPE_STATS :String = "Type: Stats";
    public static const TYPE_LINEAGE :String = "Type: Lineage";
}
}
