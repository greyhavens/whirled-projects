package {

import mx.core.MovieClipAsset;
import flash.media.Sound;
import flash.media.SoundTransform;

public class RhinoShipType extends ShipType
{
    public function RhinoShipType () :void
    {
        name = "Rhino";
        turnAccelRate = 1.25;
        forwardAccel = 0.01;
        backwardAccel = -0.007;
        friction = 0.95;
        turnFriction = 0.825;

        hitPower = 0.2;
        primaryShotCost = 0.2;
        primaryShotRecharge = 0.4;
        primaryPowerRecharge = 6;
        primaryShotSpeed = 1.5;
        primaryShotLife = 2.5;
        primaryShotSize = 0.1;

        secondaryShotCost = 0.5;
        secondaryShotRecharge = 3;
        secondaryPowerRecharge = 20;

        armor = 1.5;
        size = 1.2;

        ENGINE_MOV.gotoAndStop(2);
    }

    override public function primaryShot (sf :StarFight, val :Array) :void
    {
        var left :Number = val[3] + Math.PI/2;
        var right :Number = val[3] - Math.PI/2;
        var leftOffsetX :Number = Math.cos(left) * 0.5;
        var leftOffsetY :Number = Math.sin(left) * 0.5;
        var rightOffsetX :Number = Math.cos(right) * 0.5;
        var rightOffsetY :Number = Math.sin(right) * 0.5;

        var damage :Number = (val[6] == ShotSprite.SPREAD ? hitPower * 1.5 : hitPower);

        sf.addShot(new ShotSprite(val[0] + leftOffsetX, val[1] + leftOffsetY,
                val[2], val[3], val[4], damage, val[5], sf));
        sf.addShot(new ShotSprite(val[0] + rightOffsetX, val[1] + rightOffsetY,
                val[2], val[3], val[4], damage, val[5], sf));
    }

    // Shooting sounds.
    [Embed(source="rsrc/ships/rhino/beam.mp3")]
    protected static var beamSound :Class;

    public const BEAM :Sound = Sound(new beamSound());

    [Embed(source="rsrc/ships/rhino/beam_tri.mp3")]
    protected static var triBeamSound :Class;

    public const TRI_BEAM :Sound = Sound(new triBeamSound());

    // Ship spawning
    [Embed(source="rsrc/ships/rhino/spawn.mp3")]
    protected static var spawnSound :Class;

    public const SPAWN :Sound = Sound(new spawnSound());

    // Looping sound - this is a movieclip to make the looping work without
    //  hiccups.  This is pretty hacky - we can't control the looping sound
    //  appropriately, so we just manipulate the volume.  So, the sounds are
    //  always running, just sometimes really quietly.  Bleh.

    // Engine hum.
    [Embed(source="rsrc/ships/rhino/engine_sound.swf#sound_main")]
    public static var engineSound :Class;

    public const ENGINE_MOV :MovieClipAsset =
        MovieClipAsset(new engineSound());

    // Animations
    [Embed(source="rsrc/ships/rhino/ship.swf#ship_movie_01_alt")]
    public const SHIP_ANIM :Class;

    [Embed(source="rsrc/ships/rhino/ship_shield.swf")]
    public const SHIELD_ANIM :Class;

    [Embed(source="rsrc/ships/rhino/ship_explosion_big.swf")]
    public const EXPLODE_ANIM :Class;

    [Embed(source="rsrc/ships/rhino/beam.swf")]
    public const SHOT_ANIM :Class;

}
}
