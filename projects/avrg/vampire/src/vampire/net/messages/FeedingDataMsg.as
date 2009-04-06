package vampire.net.messages
{
    import flash.utils.ByteArray;

public class FeedingDataMsg extends BaseGameMsg
{
    public function FeedingDataMsg(playerId:int, feedingData :ByteArray = null)
    {
        super(playerId);
        _feedingData = feedingData;
    }

    override public function fromBytes (bytes :ByteArray) :void
    {
        super.fromBytes(bytes);
        var feedingBytesLength :int = bytes.readInt();
        _feedingData = new ByteArray();
        bytes.readBytes(_feedingData, 0, feedingBytesLength);
    }

    override public function toBytes (bytes :ByteArray = null) :ByteArray
    {
        var bytes :ByteArray = super.toBytes(bytes);
        bytes.writeInt(_feedingData.length);
        bytes.writeBytes(_feedingData);
        return bytes;
    }

    override public function get name () :String
    {
       return NAME;
    }

    public function get feedingData () :ByteArray
    {
        return _feedingData;
    }

    protected var _feedingData :ByteArray;

    public static const NAME :String = "Message: Feeding Data";
}
}