package {

import flash.events.TimerEvent;
import flash.utils.Timer;

import net.DefaultShotMessage;
import net.ShipMessage;

public class RaptorShipType extends ShipType
{
    public function RaptorShipType () :void
    {
        name = "Raptor";

        forwardAccel = 6.0;
        backwardAccel = -2;
        friction = 0.04;
        turnRate = 130;
        turnAccel = 45.0;
        turnFriction = 0.02;

        hitPower = 0.145;
        primaryShotCost = 0.25;
        primaryShotRecharge = 0.1;
        primaryPowerRecharge = 2.5;
        primaryShotSpeed = 20;
        primaryShotLife = 0.3;
        primaryShotSize = 0.3;

        secondaryShotCost = 0.5;
        secondaryShotRecharge = 2;
        secondaryPowerRecharge = 30;
        secondaryShotSpeed = 1500;
        secondaryShotLife = 4;

        armor = 1;
        size = 1.1;
    }

    override public function doShot (message :ShipMessage) :void
    {
        if (message is DefaultShotMessage) {
            doPrimaryShot(message);
        }
    }

    override protected function doPrimaryShot (message :ShipMessage) :void
    {
        var msg :DefaultShotMessage = DefaultShotMessage(message);

        var ttl :Number = primaryShotLife;
        if (msg.isSuper) {
            ttl *= 2;
        }

        for (var ii :Number = -0.3; ii <= 0.3; ii += 0.3) {
            AppContext.game.createMissileShot(msg.x, msg.y, msg.velocity, msg.rotationRads + ii,
                msg.shipId, hitPower, ttl, msg.shipTypeId);
        }
        super.doPrimaryShot(msg);
    }

    override public function sendSecondaryShotMessage (ship :Ship) :Boolean
    {
        if (ship.shieldHealth > 0.0) {
            return false;
        }
        ship.addPowerup(Powerup.SHIELDS);
        ship.shieldHealth = 100.0;
        var shieldTimer :Timer = new Timer(secondaryShotSpeed, 1);
        shieldTimer.addEventListener(TimerEvent.TIMER, function (event :TimerEvent) :void {
                shieldTimer.removeEventListener(TimerEvent.TIMER, arguments.callee);
                ship.removePowerup(Powerup.SHIELDS);
                ship.shieldHealth = 0.0;
        });
        shieldTimer.start();

        dispatchEvent(new ShotMessageSentEvent(ShipType.SECONDARY_SHOT_SENT, ship));

        return true;
    }
}
}
