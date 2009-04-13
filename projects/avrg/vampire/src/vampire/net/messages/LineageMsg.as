package vampire.net.messages
{
    import flash.utils.ByteArray;

    import vampire.data.Lineage;

public class LineageMsg extends BaseGameMsg
{
    public function LineageMsg(playerId:int = 0, lineage :Lineage = null)
    {
        super(playerId);
        _lineage = lineage;
    }

    override public function fromBytes (bytes :ByteArray) :void
    {
        super.fromBytes(bytes);

        var isValidLineage :Boolean = bytes.readBoolean();
        if (isValidLineage) {
            _lineage = bytes.readObject() as Lineage;
        }
    }

    override public function toBytes (bytes :ByteArray = null) :ByteArray
    {
        var bytes :ByteArray = super.toBytes(bytes);
        if (lineage != null) {
            bytes.writeBoolean(true);
            bytes.writeObject(lineage);
        }
        else {
            bytes.writeBoolean(false);
        }

        return bytes;
    }

    override public function get name () :String
    {
       return NAME;
    }

    public function get lineage () :Lineage
    {
        return _lineage;
    }

    override public function toString () :String
    {
        return name + " lineage=" + _lineage;
    }

    protected var _lineage :Lineage;

    public static const NAME :String = "Message: Lineage";

}
}