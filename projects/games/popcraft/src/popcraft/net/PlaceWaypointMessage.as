package popcraft.net {

import com.whirled.contrib.core.net.*;

public class PlaceWaypointMessage
    implements Message
{
    public var owningPlayerId :uint;
    public var xLoc :uint;
    public var yLoc :uint;

    public function PlaceWaypointMessage (owningPlayerId :uint, xLoc :uint, yLoc :uint)
    {
        this.owningPlayerId = owningPlayerId;
        this.xLoc = xLoc;
        this.yLoc = yLoc;
    }

    public function get name () :String
    {
        return messageName;
    }

    public function toString () :String
    {
        return new String(
           "[WAYPOINT. playerId: " + owningPlayerId +
           ". loc: (" + xLoc + ", " + yLoc + ")" +
           "]");
    }

    public static function createFactory () :MessageFactory
    {
        return new PlaceWaypointMessageFactory();
    }

    public static function get messageName () :String
    {
        return "PlaceWaypoint";
    }
}

}

import com.threerings.util.Assert;

import com.whirled.contrib.core.net.*;
import popcraft.net.PlaceWaypointMessage;

/*
Data layout:
owningPlayerId : top 4 bits
xLoc : next 14 bits
yLoc : bottom 14 bits

This assumes:
numPlayers <= 15
battlefield width <= 16,384
battlefield height <= 16, 384
*/

class PlaceWaypointMessageFactory
    implements MessageFactory
{
    public function serialize (message :Message) :Object
    {
        var msg :PlaceWaypointMessage = (message as PlaceWaypointMessage);

        Assert.isTrue(msg.owningPlayerId <= 0xF);
        Assert.isTrue(msg.xLoc <= 0x3FFF);
        Assert.isTrue(msg.yLoc <= 0x3FFF);

        var owningPlayerId :uint = ((msg.owningPlayerId & 0xF) << 28);
        var xLoc :uint = ((msg.xLoc & 0x3FFF) << 14);
        var yLoc :uint = (msg.yLoc & 0x3FFF);

        var data :uint = owningPlayerId | xLoc | yLoc;

        return { data: data };
    }

    public function deserialize (obj :Object) :Message
    {
        var data :uint = obj.data;
        var owningPlayerId :uint = (data >> 28) & 0xF;
        var xLoc :uint = (data >> 14) & 0x3FFF;
        var yLoc :uint = data & 0x3FFF;

        return new PlaceWaypointMessage(owningPlayerId, xLoc, yLoc);
    }
}

