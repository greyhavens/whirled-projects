package {

import flash.events.EventDispatcher;

import net.DefaultShotMessage;
import net.ShipMessage;

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

    public function getPrimaryShotCost (ship :Ship) :Number
    {
        return primaryShotCost;
    }

    /**
     * Sends a standard forward fire message.
     */
    public function sendPrimaryShotMessage (ship :Ship) :void
    {
        AppContext.msgs.sendMessage(DefaultShotMessage.create(ship, primaryShotSpeed, size));
        dispatchEvent(new ShotMessageSentEvent(PRIMARY_SHOT_SENT, ship));
    }

    public function doShot (message :ShipMessage) :void
    {
    }

    /**
     * Called to have the ship perform their primary shot action.
     */
    protected function doPrimaryShot (message :ShipMessage) :void
    {
        dispatchEvent(new ShotCreatedEvent(PRIMARY_SHOT_CREATED, message));
    }

    /**
     * Secondary shot message generator.
     */
    public function sendSecondaryShotMessage (ship :Ship) :Boolean
    {
        return false;

        // subclasses overriding this must remember to send the SECONDARY_SHOT_SENT event
    }

    /**
     * Called to have the ship perform their secondary shot action.
     */
    protected function doSecondaryShot (message :ShipMessage) :void
    {
        dispatchEvent(new ShotCreatedEvent(SECONDARY_SHOT_CREATED, message));
    }
}
}
