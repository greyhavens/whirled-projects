package vampire.net.messages
{
    import flash.utils.ByteArray;

public class RoomNameMsg extends BaseGameMsg
{
    public function RoomNameMsg(playerId:int = 0, roomId :int = 0, name :String = "")
    {
        super(playerId);
        _roomId = roomId;
        _roomName = name == null ? "" : name;
    }

    override public function fromBytes (bytes :ByteArray) :void
    {
        super.fromBytes(bytes);
        _roomName = bytes.readUTF();
        _roomId = bytes.readInt();
    }

    override public function toBytes (bytes :ByteArray = null) :ByteArray
    {
        var bytes :ByteArray = super.toBytes(bytes);
        bytes.writeUTF(_roomName);
        bytes.writeInt(_roomId);
        return bytes;
    }

    override public function get name () :String
    {
       return NAME;
    }

    public function get roomName () :String
    {
        return _roomName;
    }

    public function get roomId () :int
    {
        return _roomId;
    }

    override public function toString () :String
    {
        return NAME + "roomId=" + _roomId + ", roomName=" + _roomName;
    }

    protected var _roomName :String;
    protected var _roomId :int;

    public static const NAME :String = "Message: Room Name";

}
}
