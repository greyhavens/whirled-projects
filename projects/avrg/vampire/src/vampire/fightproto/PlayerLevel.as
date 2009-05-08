package vampire.fightproto {

public class PlayerLevel
{
    public static const LEVELS :Array = [
        new PlayerLevel(0, 0, 100, 100, 5),
        new PlayerLevel(1, 5, 120, 100, 10),
        new PlayerLevel(2, 65, 120, 150, 10),
        new PlayerLevel(3, 150, 150, 150, 10),
        new PlayerLevel(4, 300, 200, 200, 20)
    ];

    public var level :int;
    public var xpRequirement :int;

    public var maxHealth :Number;
    public var maxEnergy :Number;
    public var energyReplenishRate :Number;

    public function PlayerLevel (level :int, xpRequirement :int, maxHealth :Number,
        maxEnergy :Number, energyReplenishRate :Number)
    {
        this.level = level;
        this.xpRequirement = xpRequirement;
        this.maxHealth = maxHealth;
        this.maxEnergy = maxEnergy;
        this.energyReplenishRate = energyReplenishRate;
    }
}

}
