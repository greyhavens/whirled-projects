package popcraft.net {

public class CreateUnitMessage
    implements Message
{
    public var unitType :uint;
    public var owningPlayer :uint;

    public function get name () :String
    {
        return messageName;
    }

    public static function createFactory () :MessageFactory
    {
        return new CreateUnitMessageFactory();
    }

    public static function get messageName () :String
    {
        return "CreateUnit";
    }
}

}

import popcraft.net.MessageFactory;
import popcraft.net.Message;
import popcraft.net.CreateUnitMessage;

class CreateUnitMessageFactory
    implements MessageFactory
{
    public function serialize (message :Message) :Object
    {
        var msg :CreateUnitMessage = (message as CreateUnitMessage);
        return { data: uint((msg.unitType << 16) | (msg.owningPlayer & 0x0000FFFF)) };
    }

    public function deserialize (obj :Object) :Message
    {
        var data :uint = obj.data;

        var msg :CreateUnitMessage = new CreateUnitMessage();
        msg.unitType = (data >> 16);
        msg.owningPlayer = (data & 0x0000FFFF);

        return msg;
    }
}

