package {

import mx.core.MovieClipAsset;
import flash.media.Sound;
import flash.media.SoundTransform;

public class RaptorShipType extends ShipType
{
    public function RaptorShipType () :void
    {
        name = "Raptor";

        turnAccelRate = 1.0;
        forwardAccel = 0.012;
        backwardAccel = -0.007;
        friction = 0.98;
        turnFriction = 0.825;

        hitPower = 0.05;
        primaryShotCost = 0.25;
        primaryShotRecharge = 0.1;
        primaryPowerRecharge = 2.5;
        primaryShotSpeed = 0.75;
        primaryShotLife = 0.5;
        primaryShotSize = 0.3;

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
        for (var ii :Number = -0.3; ii <= 0.3; ii += 0.3) {
            sf.addShot(new ShotSprite(
                    val[0], val[1], val[2], val[3] + ii, val[4], hitPower, val[5], sf));
        }
    }

    override public function secondaryShot () :void
    {
    }

    protected static var SPREAD :Number = 0.1;

    // Shooting sounds.
    [Embed(source="rsrc/ships/raptor/beam.mp3")]
    protected static var beamSound :Class;

    public const BEAM :Sound = Sound(new beamSound());

    [Embed(source="rsrc/ships/raptor/beam_tri.mp3")]
    protected static var triBeamSound :Class;

    public const TRI_BEAM :Sound = Sound(new triBeamSound());

    // Ship spawning.
    [Embed(source="rsrc/ships/raptor/spawn.mp3")]
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
    [Embed(source="rsrc/ships/raptor/ship.swf#ship_movie_01")]
    public const SHIP_ANIM :Class;

    [Embed(source="rsrc/ships/raptor/ship_shield.swf")]
    public const SHIELD_ANIM :Class;

    [Embed(source="rsrc/ships/raptor/ship_explosion_big.swf")]
    public const EXPLODE_ANIM :Class;

    [Embed(source="rsrc/ships/raptor/beam.swf")]
    public const SHOT_ANIM :Class;
}
}
