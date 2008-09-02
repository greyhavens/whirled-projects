package {

import flash.events.Event;
import flash.events.TimerEvent;
import flash.utils.Timer;

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

    override public function primaryShot (val :Array) :void
    {
        var ttl :Number = primaryShotLife;
        if (val[2] == Shot.SUPER) {
            ttl *= 2;
        }
        for (var ii :Number = -0.3; ii <= 0.3; ii += 0.3) {
            AppContext.game.createMissileShot(val[3], val[4], val[5], val[6] + ii, val[0],
                hitPower, ttl, val[1]);
        }
        super.primaryShot(val);
    }

    override public function secondaryShotMessage (ship :Ship) :Boolean
    {
        if (ship.shieldPower > 0.0) {
            return false;
        }
        ship.addPowerup(Powerup.SHIELDS);
        ship.shieldPower = 100.0;
        var shieldTimer :Timer = new Timer(secondaryShotSpeed, 1);
        shieldTimer.addEventListener(TimerEvent.TIMER, function (event :TimerEvent) :void {
                shieldTimer.removeEventListener(TimerEvent.TIMER, arguments.callee);
                ship.removePowerup(Powerup.SHIELDS);
                ship.shieldPower = 0.0;
        });
        shieldTimer.start();
        // TODO
        //AppContext.game.playSoundAt(secondarySound, ship.boardX, ship.boardY);
        return true;
    }

    override public function secondaryShot (val :Array) :void
    {
    }
}
}
