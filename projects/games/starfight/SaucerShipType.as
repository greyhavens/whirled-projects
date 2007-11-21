package {

import flash.display.MovieClip;
import flash.media.Sound;
import flash.media.SoundTransform;

public class SaucerShipType extends ShipType
{
    public function SaucerShipType () :void
    {
        name = "Saucer";

        forwardAccel = 60.0;
        backwardAccel = 0.0;
        friction = 0.5;
        velThreshold = 5;
        turnRate = 180;
        turnAccel = 38;
        turnFriction = 0.02;
        turnThreshold = 180;

        hitPower = 0.09;

        primaryShotCost = 0.2;
        primaryPowerRecharge = 6.0;
        primaryShotRecharge = 0.1;
        primaryShotSpeed = 10;
        primaryShotLife = 0.1;
        primaryShotSize = 0.4;

        secondaryShotCost = 0.5;
        secondaryShotRecharge = 3;
        secondaryPowerRecharge = 30;

        armor = 0.8;
        size = 0.9;
    }

    override public function primaryShot (sf :StarFight, val :Array) :void
    {
        var ship :ShipSprite = sf.getShip(val[0]);
        if (ship == null) {
            return;
        }
        var ships :Array = sf.findShips(ship.boardX, ship.boardY, RANGE);

        // no one in range so shoot straight
        if (ships.length <= 1) {
            sf.addShot(new LaserShotSprite(ship.boardX, ship.boardY,
                ship.ship.rotation, RANGE, val[0], hitPower, primaryShotLife, val[1], -1, sf));
            return;
        }

        for each (var tShip :ShipSprite in ships) {
            if (tShip.shipId == ship.shipId) {
                continue;
            }
            var dist :Number = Math.sqrt((tShip.boardX - ship.boardX)*(tShip.boardX-ship.boardX) +
                    (tShip.boardY-ship.boardY)*(tShip.boardY-ship.boardY));
            dist = Math.min(RANGE, dist);
            var angle :Number = Codes.RADS_TO_DEGS *
                    Math.atan2(tShip.boardY - ship.boardY, tShip.boardX - ship.boardX);
            sf.addShot(new LaserShotSprite(ship.boardX, ship.boardY,
                angle, dist, val[0], hitPower, primaryShotLife, val[1], tShip.shipId, sf));
        }

        var sound :Sound = (val[2] == ShotSprite.SUPER) ? supShotSound : shotSound;

        sf.playSoundAt(sound, ship.boardX, ship.boardY);
    }

    override public function primaryShotMessage (ship :ShipSprite, sf :StarFight) :void
    {
        var type :int = (ship.powerups & ShipSprite.SPREAD_MASK) ?
            ShotSprite.SUPER : ShotSprite.NORMAL;

        var args :Array = new Array(3);
        args[0] = ship.shipId;
        args[1] = ship.shipType;
        args[2] = type;
        sf.fireShot(args);
    }

    override protected function swfAsset () :Class
    {
        return SHIP;
    }

    protected static var RANGE :Number = 5;
    protected static var TARGET :Number = 12;

    [Embed(source="rsrc/ships/xyru.swf", mimeType="application/octet-stream")]
    protected static var SHIP :Class;
}
}
