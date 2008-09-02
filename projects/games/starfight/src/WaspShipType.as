package {

import flash.display.MovieClip;
import flash.media.Sound;
import flash.media.SoundTransform;

import flash.events.Event;

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

    override public function primaryShot (val :Array) :void
    {
        AppContext.game.createMissileShot(val[3], val[4], val[5], val[6], val[0], hitPower,
            primaryShotLife, val[1]);

        if (val[2] == Shot.SUPER) {
            AppContext.game.createMissileShot(val[3], val[4], val[5], val[6] + SPREAD, val[0],
                hitPower, primaryShotLife, val[1]);
            AppContext.game.createMissileShot(val[3], val[4], val[5], val[6] - SPREAD, val[0],
                hitPower, primaryShotLife, val[1]);
        }

        super.primaryShot(val);
    }

    override public function secondaryShotMessage (ship :Ship) :Boolean
    {
        var rads :Number = ship.rotation*Codes.DEGS_TO_RADS;
        var cos :Number = Math.cos(rads);
        var sin :Number = Math.sin(rads);

        var shotX :Number = cos * secondaryShotSpeed + ship.xVel;
        var shotY :Number = sin * secondaryShotSpeed + ship.yVel;

        //var shotVel :Number = Math.sqrt(shotX*shotX + shotY*shotY);
        var shotVel :Number = secondaryShotSpeed;
        var shotAngle :Number = Math.atan2(shotY, shotX);

        var args :Array = new Array(6);
        args[0] = ship.shipId;
        args[1] = ship.shipTypeId;
        args[2] = ship.boardX + cos * size + 0.1 * ship.xVel;
        args[3] = ship.boardY + sin * size + 0.1 * ship.yVel;
        args[4] = shotVel;
        args[5] = rads;

        AppContext.game.sendMessage("secondary", args);
        return true;
    }

    override public function secondaryShot (val :Array) :void
    {
        AppContext.game.createTorpedoShot(val[2], val[3], val[4], val[5], val[0],
            SECONDARY_HIT_POWER, secondaryShotLife, val[1]);
        // TODO
        //AppContext.game.playSoundAt(secondarySound, val[2], val[3]);
    }

    protected static const SPREAD :Number = 0.1;
}
}
