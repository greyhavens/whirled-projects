package popcraft.net {

import com.whirled.contrib.simplegame.net.*;

public class CreateUnitMessage
    implements Message
{
    public var unitType :uint;
    public var owningPlayer :uint;

    public function CreateUnitMessage (unitType :uint, owningPlayer :uint)
    {
        this.unitType = unitType;
        this.owningPlayer = owningPlayer;
    }

    public function get name () :String
    {
        return messageName;
    }

    public function toString () :String
    {
        return new String(
           "[CREATEUNIT. playerId: " + owningPlayer +
           ". unitType: " + unitType +
           "]");
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

import com.whirled.contrib.simplegame.net.*;
import popcraft.net.CreateUnitMessage;

class CreateUnitMessageFactory
    implements MessageFactory
{
    public function serializeForNetwork (message :Message) :Object
    {
        var msg :CreateUnitMessage = (message as CreateUnitMessage);
        return { data: uint((msg.unitType << 16) | (msg.owningPlayer & 0x0000FFFF)) };
    }

    public function deserializeFromNetwork (obj :Object) :Message
    {
        var data :uint = obj.data;
        return new CreateUnitMessage((data >> 16), (data & 0x0000FFFF));
    }
}

