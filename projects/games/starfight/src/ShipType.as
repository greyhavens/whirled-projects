package {

import flash.events.EventDispatcher;

public class ShipType extends EventDispatcher
{
    public static const PRIMARY_SHOT_CREATED :String = "PrimaryShotCreated";
    public static const SECONDARY_SHOT_CREATED :String = "SecondaryShotCreated";
    public static const PRIMARY_SHOT_SENT :String = "PrimaryShotSent";
    public static const SECONDARY_SHOT_SENT :String = "SecondaryShotSent";

    /** The name of the ship type. */
    public var name :String;

    /** maneuverability statistics. */
    public var forwardAccel :Number;
    public var backwardAccel :Number;
    public var friction :Number;
    public var velThreshold :Number = 0.5;
    public var turnAccel :Number;
    public var turnFriction :Number;
    public var turnThreshold :Number = 35;
    public var turnRate :Number;

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
    public function doPrimaryShot (args :Array) :void
    {
        dispatchEvent(new ShotCreatedEvent(PRIMARY_SHOT_CREATED, args));
    }

    /**
     * Called to have the ship perform their secondary shot action.
     */
    public function doSecondaryShot (args :Array) :void
    {
        dispatchEvent(new ShotCreatedEvent(SECONDARY_SHOT_CREATED, args));
    }

    public function getPrimaryShotCost (ship :Ship) :Number
    {
        return primaryShotCost;
    }

    /**
     * Sends a standard forward fire message.
     */
    public function sendPrimaryShotMessage (ship :Ship) :void
    {
        var rads :Number = ship.rotation * Codes.DEGS_TO_RADS;
        var cos :Number = Math.cos(rads);
        var sin :Number = Math.sin(rads);

        var shotX :Number = cos * primaryShotSpeed + ship.xVel;
        var shotY :Number = sin * primaryShotSpeed + ship.yVel;

        var shotVel :Number = primaryShotSpeed;
        var shotAngle :Number = Math.atan2(shotY, shotX);

        var type :int = ship.hasPowerup(Powerup.SPREAD) ? Shot.SUPER : Shot.NORMAL;

        var args :Array = new Array(7);
        args[0] = ship.shipId;
        args[1] = ship.shipTypeId;
        args[2] = type;
        args[3] = ship.boardX + cos * size + 0.1 * ship.xVel;
        args[4] = ship.boardY + sin * size + 0.1 * ship.yVel;
        args[5] = shotVel;
        args[6] = rads;

        AppContext.game.sendShotMessage(args);

        dispatchEvent(new ShotMessageSentEvent(PRIMARY_SHOT_SENT, ship));
    }

    /**
     * Secondary shot message generator.
     */
    public function sendSecondaryShotMessage (ship :Ship) :Boolean
    {
        return false;

        // subclasses overriding this must remember to send the SECONDARY_SHOT_SENT event
    }
}
}
