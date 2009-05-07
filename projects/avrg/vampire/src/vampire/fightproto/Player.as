package vampire.fightproto {

public class Player
{
    public var maxHealth :Number;
    public var health :Number;
    public var xp :int;
    public var maxEnergy :Number;
    public var energy :Number;
    public var energyReplenishRate :Number;
    public var skills :Array = [];

    public function offsetHealth (offset :Number) :void
    {
        health += offset;
        health = Math.max(health, 0);
        health = Math.min(health, maxHealth);
    }

    public function offsetEnergy (offset :Number) :void
    {
        energy += offset;
        energy = Math.max(energy, 0);
        energy = Math.min(energy, maxEnergy);
    }
}

}
