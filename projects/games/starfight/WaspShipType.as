package {

import flash.display.MovieClip;
import flash.media.Sound;
import flash.media.SoundTransform;

import flash.events.Event;

public class WaspShipType extends ShipType
{
    public var secondaryHitPower :Number = 0.4;
    public var secondaryShotRange :Number = 3.0;
    public var secondaryExplode :Class;
    public var secondarySound :Sound;

    public function WaspShipType () :void
    {
        name = "Wasp";

        forwardAccel = 8.0;
        backwardAccel = -3.0;
        friction = 0.1;
        turnAccel = 30.0;
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

    override public function primaryShot (sf :StarFight, val :Array) :void
    {
        sf.addShot(new MissileShotSprite(
            val[3], val[4], val[5], val[6], val[0], hitPower, primaryShotLife, val[1], sf));

        if (val[2] == ShotSprite.SUPER) {
            sf.addShot(new MissileShotSprite(val[3], val[4], val[5],
                        val[6] + SPREAD, val[0], hitPower, primaryShotLife, val[1], sf));
            sf.addShot(new MissileShotSprite(val[3], val[4], val[5],
                        val[6] - SPREAD, val[0], hitPower, primaryShotLife, val[1], sf));
        }

        super.primaryShot(sf, val);
    }

    override public function secondaryShotMessage (ship :ShipSprite, sf :StarFight) :Boolean
    {
        var rads :Number = ship.ship.rotation*Codes.DEGS_TO_RADS;
        var cos :Number = Math.cos(rads);
        var sin :Number = Math.sin(rads);

        var shotX :Number = cos * secondaryShotSpeed + ship.xVel;
        var shotY :Number = sin * secondaryShotSpeed + ship.yVel;

        //var shotVel :Number = Math.sqrt(shotX*shotX + shotY*shotY);
        var shotVel :Number = secondaryShotSpeed;
        var shotAngle :Number = Math.atan2(shotY, shotX);

        var args :Array = new Array(6);
        args[0] = ship.shipId;
        args[1] = ship.shipType;
        args[2] = ship.boardX + cos * size + 0.1 * ship.xVel;
        args[3] = ship.boardY + sin * size + 0.1 * ship.yVel;
        args[4] = shotVel;
        args[5] = rads;

        sf.sendMessage("secondary", args);
        return true;
    }

    override public function secondaryShot (sf :StarFight, val :Array) :void
    {
        sf.addShot(new TorpedoShotSprite(val[2], val[3], val[4], val[5], val[0],
                secondaryHitPower, secondaryShotLife, val[1], sf));
        sf.playSoundAt(secondarySound, val[2], val[3]);
    }

    override protected function swfAsset () :Class
    {
        return SHIP;
    }

    override protected function successHandler (event :Event) :void
    {
        super.successHandler(event);
        secondaryAnim = _loader.getClass("torpedo");
        secondaryExplode = _loader.getClass("torpedo_explosion");
        secondarySound = Sound(new (_loader.getClass("torpedo_shot.wav"))());
    }

    [Embed(source="rsrc/ships/wasp.swf", mimeType="application/octet-stream")]
    protected static const SHIP :Class;

    protected static var SPREAD :Number = 0.1;
}
}
