package vampire.net.messages
{
public class StatsMsg extends BaseGameMsg
{
    public function StatsMsg(playerId:int = 0, stats :String = null)
    {
        super(playerId);
        _statString = stats != null ? stats : "";
    }
    override public function fromBytes (bytes :ByteArray) :void
    {
        super.fromBytes(bytes);
        _statString = bytes.readUTF();
    }

    override public function toBytes (bytes :ByteArray = null) :ByteArray
    {
        var bytes :ByteArray = super.toBytes(bytes);
        bytes.writeUTF(_statString);
        return bytes;
    }

    override public function get statsString () :String
    {
       return _statString;
    }

    override public function get name () :String
    {
       return NAME;
    }

    protected var _statString :String;

    public static const NAME :String = "Message: Stats";
}
}