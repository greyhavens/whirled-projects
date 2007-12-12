package popcraft.message {

public interface GameMessage
{
    function get name () :String;
    function serialize () :Object;
    function deserialize (obj :Object) :void;
}

}
