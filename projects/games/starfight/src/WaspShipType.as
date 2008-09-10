package {
    import net.DefaultShotMessage;
    import net.ShipMessage;
    import net.TorpedoShotMessage;


public class WaspShipType extends ShipType
{
    public static const SECONDARY_HIT_POWER :Number = 0.4;
    public static const SECONDARY_SHOT_RANGE :Number = 3.0;

    public function WaspShipType () :void
    {
        name = "Wasp";

        forwardAccel = 8.0;
        backwardAccel = -3.0;
        friction = 0.1;
        turnAccel = 60.0;
        turnFriction = 0.05;
        turnRate = 100;

        hitPower = 0.2;
        primaryShotCost = 0.18;
        primaryShotRecharge = 0.2;
        primaryPowerRecharge = 3.0;
        primaryShotSpeed = 20;
        primaryShotLife = 2;
        primaryShotSize = 0.1;

        secondaryShotCost = 0.33;
        secondaryShotRecharge = 1;
        secondaryPowerRecharge = 30;
        secondaryShotSpeed = 15;
        secondaryShotLife = 4;
        secondaryShotSize = 0.3;

        armor = 1;
        size = 0.9;
    }

    override public function doShot (message :ShipMessage) :void
    {
        if (message is TorpedoShotMessage) {
            doSecondaryShot(message);
        } else if (message is DefaultShotMessage) {
            doPrimaryShot(message);
        }
    }

    override protected function doPrimaryShot (message :ShipMessage) :void
    {
        var msg :DefaultShotMessage = DefaultShotMessage(message);

        AppContext.game.createMissileShot(msg.x, msg.y, msg.velocity, msg.rotationRads, msg.shipId,
            hitPower, primaryShotLife, msg.shipTypeId);

        if (msg.isSuper) {
            AppContext.game.createMissileShot(msg.x, msg.y, msg.velocity, msg.rotationRads + SPREAD,
                msg.shipId, hitPower, primaryShotLife, msg.shipTypeId);
            AppContext.game.createMissileShot(msg.x, msg.y, msg.velocity, msg.rotationRads - SPREAD,
                msg.shipId, hitPower, primaryShotLife, msg.shipTypeId);
        }

        super.doPrimaryShot(msg);
    }

    override public function sendSecondaryShotMessage (ship :Ship) :Boolean
    {
        AppContext.msgs.sendMessage(TorpedoShotMessage.create(ship, secondaryShotSpeed));
        dispatchEvent(new ShotMessageSentEvent(ShipType.SECONDARY_SHOT_SENT, ship));

        return true;
    }

    override protected function doSecondaryShot (message :ShipMessage) :void
    {
        var msg :TorpedoShotMessage = TorpedoShotMessage(message);

        AppContext.game.createTorpedoShot(msg.x, msg.y, msg.velocity, msg.rotationRads, msg.shipId,
            SECONDARY_HIT_POWER, secondaryShotLife, msg.shipTypeId);

        dispatchEvent(new ShotCreatedEvent(ShipType.SECONDARY_SHOT_CREATED, message));
    }

    protected static const SPREAD :Number = 0.1;
}
}
