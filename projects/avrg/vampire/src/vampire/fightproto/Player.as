package vampire.fightproto {

public class Player
{
    public var maxHealth :int;
    public var health :int;
    public var xp :int;
    public var energy :int;
    public var skills :Array = [];

    public function offsetHealth (offset :int) :void
    {
        health += offset;
        health = Math.max(health, 0);
        health = Math.min(health, maxHealth);
    }
}

}
