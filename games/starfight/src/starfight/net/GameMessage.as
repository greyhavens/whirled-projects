package starfight.net {

import flash.utils.ByteArray;

public interface GameMessage
{
    function get name () :String;
    function fromBytes (bytes :ByteArray) :void;
    function toBytes (bytes :ByteArray = null) :ByteArray;
}

}
