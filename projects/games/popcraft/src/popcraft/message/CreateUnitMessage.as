package popcraft.message {

public class CreateUnitMessage
    implements GameMessage
{
    public var unitType :uint;
    public var owningPlayer :uint;

    public function serialize () :Object
    {
        return { data: uint((unitType << 16) | (owningPlayer & 0x0000FFFF)) };
    }

    public function deserialize (obj :Object) :void
    {
        var data :uint = obj.data;

        unitType = data >> 16;
        owningPlayer = data & 0x0000FFFF;
    }
}

}
