package {

import mx.core.MovieClipAsset;
import flash.media.Sound;
import flash.media.SoundTransform;

public class SaucerShipType extends ShipType
{
    public function SaucerShipType () :void
    {
        name = "Saucer";

        turnAccelRate = 8000;
        forwardAccel = 60.0;
        backwardAccel = 0.0;
        friction = 0.5;
        turnFriction = 0.4;

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
        ENGINE_MOV.gotoAndStop(2);
    }

    override public function primaryShot (sf :StarFight, val :Array) :void
    {
        var ship :ShipSprite = sf.getShip(val[0]);
        if (ship == null) {
            return;
        }
        var ships :Array = sf.findShips(ship.boardX, ship.boardY, RANGE);

        // no one in range so shoot straight
        if (ships.length == 1) {
            sf.addShot(new LaserShotSprite(ship.boardX + ship.xVel, ship.boardY + ship.yVel,
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
            sf.addShot(new LaserShotSprite(ship.boardX + ship.xVel, ship.boardY + ship.yVel,
                angle, dist, val[0], hitPower, primaryShotLife, val[1], tShip.shipId, sf));
        }

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

    protected static var RANGE :Number = 5;
    protected static var TARGET :Number = 12;

    // Shooting sounds.
    [Embed(source="rsrc/ships/wasp/beam.mp3")]
    protected static var beamSound :Class;

    public const BEAM :Sound = Sound(new beamSound());

    [Embed(source="rsrc/ships/wasp/beam_tri.mp3")]
    protected static var triBeamSound :Class;

    public const TRI_BEAM :Sound = Sound(new triBeamSound());

    // Ship spawning.
    [Embed(source="rsrc/ships/wasp/spawn.mp3")]
    protected static var spawnSound :Class;

    public const SPAWN :Sound = Sound(new spawnSound());

    // Looping sound - this is a movieclip to make the looping work without
    //  hiccups.  This is pretty hacky - we can't control the looping sound
    //  appropriately, so we just manipulate the volume.  So, the sounds are
    //  always running, just sometimes really quietly.  Bleh.

    // Engine hum.
    [Embed(source="rsrc/ships/wasp/engine_sound.swf#sound_main")]
    protected static var engineSound :Class;

    public const ENGINE_MOV :MovieClipAsset =
        MovieClipAsset(new engineSound());

    // Animations
    [Embed(source="rsrc/ships/saucer/ship.swf#ship_movie_01")]
    public const SHIP_ANIM :Class;

    [Embed(source="rsrc/ships/saucer/ship_shield.swf")]
    public const SHIELD_ANIM :Class;

    [Embed(source="rsrc/ships/saucer/ship_explosion_big.swf")]
    public const EXPLODE_ANIM :Class;

    [Embed(source="rsrc/ships/saucer/beam.swf")]
    public const SHOT_ANIM :Class;

}
}
