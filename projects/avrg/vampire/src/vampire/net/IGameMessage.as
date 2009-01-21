package vampire.net
{
import flash.utils.ByteArray;

public interface IGameMessage
{
    function get name () :String;
    function fromBytes (bytes :ByteArray) :void;
    function toBytes (bytes :ByteArray = null) :ByteArray;
}
}