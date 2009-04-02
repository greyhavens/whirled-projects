package vampire.net.messages
{
    import com.threerings.util.ClassUtil;

    import flash.utils.ByteArray;

public class SendGlobalMsg extends BaseGameMsg
{
    public function SendGlobalMsg(msg :String = null)
    {
        super(0);
        _msg = msg != null ? msg : "";
    }

    override public function fromBytes (bytes :ByteArray) :void
    {
        super.fromBytes(bytes);
        _msg = bytes.readUTF();
    }

    override public function toBytes (bytes :ByteArray = null) :ByteArray
    {
        var bytes :ByteArray = super.toBytes(bytes);
        bytes.writeUTF(_msg);
        return bytes;
    }

    override public function toString() :String
    {
        return ClassUtil.tinyClassName(this) + ": player=" + _playerId + ", msg=" + _msg;
    }

    public function get message () :String
    {
       return _msg;
    }

    override public function get name () :String
    {
       return NAME;
    }

    protected var _msg :String;

    public static const NAME :String = "Message: GlobalMessage";

}
}