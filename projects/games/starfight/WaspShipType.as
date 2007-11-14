package {

import mx.core.MovieClipAsset;
import flash.media.Sound;
import flash.media.SoundTransform;

public class WaspShipType extends ShipType
{
    public function WaspShipType () :void
    {
        name = "Wasp";

        turnAccelRate = 1000.0;
        forwardAccel = 8.0;
        backwardAccel = -3.0;
        friction = 0.1;
        turnFriction = 0.05;

        hitPower = 0.2;
        primaryShotCost = 0.18;
        primaryShotRecharge = 0.2;
        primaryPowerRecharge = 3.0;
        primaryShotSpeed = 20;
        primaryShotLife = 3;
        primaryShotSize = 0.1;

        secondaryShotCost = 0.33;
        secondaryShotRecharge = 1;
        secondaryPowerRecharge = 30;
        secondaryShotSpeed = 0.5;
        secondaryShotLife = 4;

        armor = 1;
        size = 0.9;

        ENGINE_MOV.gotoAndStop(2);
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
    }

    override public function secondaryShot () :void
    {
    }

    protected static var SPREAD :Number = 0.1;

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
    [Embed(source="rsrc/ships/wasp/ship.swf#ship_movie_01")]
    public const SHIP_ANIM :Class;

    [Embed(source="rsrc/ships/wasp/ship_shield.swf")]
    public const SHIELD_ANIM :Class;

    [Embed(source="rsrc/ships/wasp/ship_explosion_big.swf")]
    public const EXPLODE_ANIM :Class;

    [Embed(source="rsrc/ships/wasp/beam.swf")]
    public const SHOT_ANIM :Class;

}
}
