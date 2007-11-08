package {

public class ShipType
{
    /** The name of the ship type. */
    public var name :String;

    /** maneuverability statistics. */
    public var turnAccelRate :Number;
    public var forwardAccel :Number;
    public var backwardAccel :Number;
    public var friction :Number;
    public var turnFriction :Number;

    /** armorment statistics. */
    public var hitPower :Number;
    public var primaryShotCost :Number;
    public var primaryPowerRecharge :Number;
    public var primaryShotRecharge :Number;
    public var primaryShotSpeed :Number;
    public var primaryShotLife :Number;
    public var primaryShotSize :Number;

    public var secondaryShotCost :Number;
    public var secondaryPowerRecharge :Number;
    public var secondaryShotRecharge :Number;
    public var secondaryShotSpeed :Number;
    public var secondaryShotLife :Number;
    public var secondaryShotSize :Number;

    public var armor :Number;
    public var size :Number;

    /**
     * Called to have the ship perform their primary shot action.
     */
    public function primaryShot (sf :StarFight, val :Array) :void
    {
    }

    /**
     * Called to have the ship perform their secondary shot action.
     */
    public function secondaryShot () :void
    {
    }
}
}
