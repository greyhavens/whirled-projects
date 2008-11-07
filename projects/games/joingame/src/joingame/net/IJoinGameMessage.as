package joingame.net
{
    import flash.utils.ByteArray;
    
    public interface IJoinGameMessage
    {
        function get name () :String;
        function fromBytes (bytes :ByteArray) :void;
        function toBytes (bytes :ByteArray = null) :ByteArray;
    }
}