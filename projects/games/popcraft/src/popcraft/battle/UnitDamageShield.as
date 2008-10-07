package popcraft.battle {

public class UnitDamageShield
{
    public var maxHealth :Number;
    public var health :Number;

    public function UnitDamageShield (maxHealth :Number)
    {
        this.maxHealth = maxHealth;
        this.health = maxHealth;
    }

    public function clone () :UnitDamageShield
    {
        var theClone :UnitDamageShield = new UnitDamageShield(maxHealth);
        theClone.health = health;
        return theClone;
    }
}

}
