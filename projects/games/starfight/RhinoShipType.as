package {

import mx.core.MovieClipAsset;
import flash.media.Sound;
import flash.media.SoundTransform;

public class RhinoShipType extends ShipType
{
    public function RhinoShipType () :void
    {
        name = "Rhino";
        turnAccelRate = 4000.0;
        forwardAccel = 6.0;
        backwardAccel = -2;
        friction = 0.1;
        turnFriction = 0.05;

        hitPower = 0.2;
        primaryShotCost = 0.2;
        primaryShotRecharge = 0.4;
        primaryPowerRecharge = 4;
        primaryShotSpeed = 30;
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
        var left :Number = val[6] + Math.PI/2;
        var right :Number = val[6] - Math.PI/2;
        var leftOffsetX :Number = Math.cos(left) * 0.5;
        var leftOffsetY :Number = Math.sin(left) * 0.5;
        var rightOffsetX :Number = Math.cos(right) * 0.5;
        var rightOffsetY :Number = Math.sin(right) * 0.5;

        var damage :Number = (val[2] == ShotSprite.SUPER ? hitPower * 1.5 : hitPower);

        sf.addShot(new MissileShotSprite(val[3] + leftOffsetX, val[4] + leftOffsetY,
                val[5], val[6], val[0], damage, primaryShotLife, val[1], sf));
        sf.addShot(new MissileShotSprite(val[3] + rightOffsetX, val[4] + rightOffsetY,
                val[5], val[6], val[0], damage, primaryShotLife, val[1], sf));
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
