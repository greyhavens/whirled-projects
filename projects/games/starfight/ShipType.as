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

    public var maxSpeed :Number = 20.0;
    public var maxSpeedRev :Number = 10;
    public var fAccel :Number = 8.0;
    public var rAccel :Number = -3.0;
    public var drag :Number = 0.1;

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

    /**
     * Sends a standard forward fire message.
     */
    public function primaryShotMessage (ship :ShipSprite, sf: StarFight) :void
    {
        var rads :Number = ship.ship.rotation*Codes.DEGS_TO_RADS;
        var cos :Number = Math.cos(rads);
        var sin :Number = Math.sin(rads);

        var shotX :Number = cos * primaryShotSpeed + ship.xVel;
        var shotY :Number = sin * primaryShotSpeed + ship.yVel;

        //var shotVel :Number = Math.sqrt(shotX*shotX + shotY*shotY);
        var shotVel :Number = primaryShotSpeed;
        var shotAngle :Number = Math.atan2(shotY, shotX);

        var type :int = (ship.powerups & ShipSprite.SPREAD_MASK) ?
                ShotSprite.SUPER : ShotSprite.NORMAL;

        var args :Array = new Array(7);
        args[0] = ship.shipId;
        args[1] = ship.shipType;
        args[2] = type;
        args[3] = ship.boardX + cos * size + 0.1 * ship.xVel;
        args[4] = ship.boardY + sin * size + 0.1 * ship.yVel;
        args[5] = shotVel;
        args[6] = rads;

        sf.fireShot(args);
    }
}
}
