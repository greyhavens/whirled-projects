package vampire.combat
{
import flash.geom.Point;

/**
 * Stores everything about a player, stats, weapons, current energy etc
 *
 */
public class CombatUnit //implements IExternalizable
{
    public function CombatUnit()
    {
    }
    public var profile :UnitProfile;
    public var team :int;
    public var controllingPlayer :int;
    public var items :Items;
    public var location :Point;
    public var energy :Number;
    public var avatarState :String;
    public var currentAction :int;
    public var currentHealth :Number;
}
}