package vampire.net.messages
{
    import flash.utils.ByteArray;


/**
 * Requests and sends the current rooms we want to send players from overpopulated rooms.
 */
public class LoadBalancingMsg extends BaseGameMsg
{
    public function LoadBalancingMsg(playerId:int = 0, roomIds :Array = null,
                                                       roomNames :Array = null)
//                                                       ,
//                                                       roomPlayerCounts :Array = null)
    {

        super(playerId);
        _roomIds = (roomIds == null ? [] : roomIds);
        _roomNames = (roomNames == null ? [] : roomNames);

        if (_roomNames.length < _roomIds.length) {
            throw new Error("_roomNames.length < _roomIds.length");
        }
//        _roomPlayerCounts = roomPlayerCounts == null ? [] : roomPlayerCounts;
    }

    override public function fromBytes (bytes :ByteArray) :void
    {
        super.fromBytes(bytes);
        var length :int;
        var ii :int;

        length = bytes.readInt();
        _roomIds = [];
        for (ii = 0; ii < length; ++ii) {
            _roomIds.push(bytes.readInt());
        }

        _roomNames = [];
        for (ii = 0; ii < length; ++ii) {
            _roomNames.push(bytes.readUTF());
        }

//        _roomPlayerCounts = [];
//        for (ii = 0; ii < length; ++ii) {
//            _roomPlayerCounts.push(bytes.readInt());
//        }
    }

    override public function toBytes (bytes :ByteArray = null) :ByteArray
    {
        var bytes :ByteArray = super.toBytes(bytes);
        var ii :int;

        bytes.writeInt(_roomIds.length);
        for (ii = 0; ii < _roomIds.length; ++ii) {
            bytes.writeInt(_roomIds[ii]);
        }

        for (ii = 0; ii < _roomIds.length; ++ii) {
            bytes.writeUTF((_roomNames[ii] == null ? "" : _roomNames[ii]));
        }

//        for (ii = 0; ii < _roomIds.length; ++ii) {
//            bytes.writeInt(_roomPlayerCounts[ii]);
//        }

        return bytes;
    }

    public function get roomIds () :Array
    {
        return _roomIds;
    }
    public function get roomNames () :Array
    {
        return _roomNames;
    }
//    public function get roomPlayerCounts () :Array
//    {
//        return _roomPlayerCounts;
//    }

    override public function get name () :String
    {
       return NAME;
    }

    override public function toString () :String
    {
        return NAME + " roomIds=" + roomIds + ", roomNames=" + roomNames;
    }

    protected var _roomIds :Array;
    protected var _roomNames :Array;
//    protected var _roomPlayerCounts :Array;

    public static const NAME :String = "Message: Load Balancing";

}
}
