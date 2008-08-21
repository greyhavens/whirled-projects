package {

import flash.media.Sound;
import flash.media.SoundTransform;

import flash.events.Event;
import flash.events.TimerEvent;
import flash.utils.Timer;

public class RaptorShipType extends ShipType
{
    public var secondarySound :Sound;

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

    override public function primaryShot (sf :StarFight, val :Array) :void
    {
        var ttl :Number = primaryShotLife;
        if (val[2] == ShotSprite.SUPER) {
            ttl *= 2;
        }
        for (var ii :Number = -0.3; ii <= 0.3; ii += 0.3) {
            sf.addShot(new MissileShotSprite(
                    val[3], val[4], val[5], val[6] + ii, val[0], hitPower, ttl, val[1], sf));
        }
        super.primaryShot(sf, val);
    }

    override public function secondaryShotMessage (ship :ShipSprite, sf :StarFight) :Boolean
    {
        if (ship.shieldPower > 0.0) {
            return false;
        }
        ship.powerups |= (1 << Powerup.SHIELDS);
        ship.shieldPower = 100.0;
        var shieldTimer :Timer = new Timer(secondaryShotSpeed, 1);
        shieldTimer.addEventListener(TimerEvent.TIMER, function (event :TimerEvent) :void
            {
                shieldTimer.removeEventListener(TimerEvent.TIMER, arguments.callee);
                ship.powerups &= ~ShipSprite.SHIELDS_MASK;
                ship.shieldPower = 0.0;
            });
        shieldTimer.start();
        sf.playSoundAt(secondarySound, ship.boardX, ship.boardY);
        return true;
    }

    override public function secondaryShot (sf :StarFight, val :Array) :void
    {
    }

    override protected function swfAsset () :Class
    {
        return SHIP;
    }

    override protected function successHandler (event :Event) :void
    {
        super.successHandler(event);
        secondarySound = Sound(new (_loader.getClass("shield.wav"))());
    }

    [Embed(source="../rsrc/ships/raptor.swf", mimeType="application/octet-stream")]
    protected static const SHIP :Class;
}
}
