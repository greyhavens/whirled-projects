package popcraft.message {

public interface GameMessage
{
    function serialize () :Object;
    function deserialize (obj :Object) :void;
}

}
