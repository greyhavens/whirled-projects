package vampire.net.messages
{
    import flash.utils.ByteArray;

public class DebugMsg extends BaseGameMsg
{
    public function DebugMsg (type :String = DEBUG_GAIN_XP, value1 :Number = 0, value2 :Number = 0)
    {
        super(0);
        _type = type;
        _value1 = value1;
        _value2 = value2;
    }

    override public function fromBytes (bytes :ByteArray) :void
    {
        super.fromBytes(bytes);
        _type = bytes.readUTF();
        _value1 = bytes.readFloat();
        _value2 = bytes.readFloat();
    }

    override public function toBytes (bytes :ByteArray = null) :ByteArray
    {
        var bytes :ByteArray = super.toBytes(bytes);
        bytes.writeUTF(_type);
        bytes.writeFloat(_value1);
        bytes.writeFloat(_value2);
        return bytes;
    }

    public function get type () :String
    {
       return _type;
    }

    override public function get name () :String
    {
       return NAME;
    }

    override public function toString () :String
    {
        return NAME + " type=" + _type;
    }

    protected var _type :String;
    protected var _value1 :Number;
    protected var _value2 :Number;

    public static const DEBUG_GAIN_XP :String = "DEBUG: GainXP";
    public static const DEBUG_LOSE_XP :String = "DEBUG: LoseXP";
    public static const DEBUG_LEVEL_UP :String = "DEBUG: LeveUp";
    public static const DEBUG_LEVEL_DOWN :String = "DEBUG: LevelDown";
    public static const DEBUG_ADD_INVITE :String = "DEBUG: AddInvite";
    public static const DEBUG_LOSE_INVITE :String = "DEBUG: LoseInvite";
    public static const DEBUG_RESET_HIGH_SCORES :String = "DEBUG: ResetLeaderBOard";
    public static const NAME :String = "Message :Debug";
}
}