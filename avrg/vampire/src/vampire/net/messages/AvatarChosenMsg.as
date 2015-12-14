package vampire.net.messages
{
    import flash.utils.ByteArray;

public class AvatarChosenMsg extends BaseGameMsg
{
    public function AvatarChosenMsg(playerId :int = 0, avatarType :String = AVATAR_FEMALE)
    {
        super(playerId);
        _avatarType = avatarType;
    }

    override public function fromBytes (bytes :ByteArray) :void
    {
        super.fromBytes(bytes);
        _avatarType = bytes.readUTF();
    }

    override public function toBytes (bytes :ByteArray = null) :ByteArray
    {
        var bytes :ByteArray = super.toBytes(bytes);
        bytes.writeUTF(_avatarType);
        return bytes;
    }

    override public function get name () :String
    {
       return NAME;
    }

    public function get isFemale () :Boolean
    {
        return _avatarType == AVATAR_FEMALE;
    }

    public function get isMale () :Boolean
    {
        return _avatarType == AVATAR_MALE;
    }

    override public function toString () :String
    {
        return NAME + "  " + _avatarType;
    }

    protected var _avatarType :String;

    public static const NAME :String = "Message: Choose Avatar";
    public static const AVATAR_FEMALE :String = "Avatar Female";
    public static const AVATAR_MALE :String = "Avatar Male";

}
}
