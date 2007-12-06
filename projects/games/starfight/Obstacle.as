package {

import flash.display.Bitmap;
import flash.display.Graphics;
import flash.display.MovieClip;
import flash.display.PixelSnapping;
import flash.display.Sprite;

import flash.media.Sound;

import flash.events.Event;

import flash.utils.ByteArray;


/**
 * Represents something in the world that ships may interact with.
 */
public class Obstacle extends BoardObject
{
    /** Constants for types of obstacles. */
    public static const ASTEROID_1 :int = 0;
    public static const ASTEROID_2 :int = 1;
    public static const JUNK :int = 2;
    public static const WALL :int = 3;

    public static const LEFT :int = 0;
    public static const RIGHT :int = 1;
    public static const UP :int = 2;
    public static const DOWN :int = 3;

    public var health :Number;

    public static function readObstacle (bytes :ByteArray) :Obstacle
    {
        var obs :Obstacle = new Obstacle(0, 0, 0, false);
        obs.reload(bytes);
        return obs;
    }

    public function Obstacle (type :int, x :int, y :int, anim :Boolean = true) :void
    {
        super(type, x, y, anim);
        health = 1.0;
    }

    /**
     * Get a value for how much bounce ships should get off the obstacle.
     */
    public function getElasticity () :Number
    {
        // TODO: Something different for different obstacles.
        return 0.75;
    }

    public function tick (time :int) :void
    {
        if (type != WALL) {
            rotation = (rotation + (360 * time / 10000)) % 360;
        }
    }

    override public function damage (damage :Number) :Boolean
    {
        if (health < 0 || type == WALL) {
            return false;
        }
        health -= damage;
        return health < 0;
    }

    override public function arrayName () :String
    {
        return "obstacles";
    }

    override public function hitSound () :Sound
    {
        var sound :Sound;
        switch (type) {
        case ASTEROID_1:
        case ASTEROID_2:
            sound = Resources.getSound("asteroid_hit.wav");
            break;
        case JUNK:
            sound = Resources.getSound("junk_hit.wav");
            break;
        case WALL:
        default:
            sound = Resources.getSound("metal_hit.wav");
            break;
        }
        return sound;
    }

    public function collisionSound () :Sound
    {
        switch (type) {
        case ASTEROID_1:
        case ASTEROID_2:
            return Resources.getSound("collision_asteroid2.wav");
        case JUNK:
            return Resources.getSound("collision_junk.wav");
        case WALL:
        default:
            return Resources.getSound("collision_metal3.wav");
        }
    }

    override public function readFrom (bytes :ByteArray) :void
    {
        super.readFrom(bytes);
        //health = bytes.readFloat();
    }

    override public function writeTo (bytes :ByteArray) :ByteArray
    {
        bytes = super.writeTo(bytes);
        //bytes.writeFloat(health);
        return bytes;
    }

    public function explode (callback :Function) :void
    {
        if (OBS_EXPLODE[type] == null) {
            callback();
        } else {
            removeChildAt(0);
            var obsMovie :MovieClip = MovieClip(new (Resources.getClass(OBS_EXPLODE[type]))());
            obsMovie.addEventListener(Event.COMPLETE, function (event :Event) :void
                {
                    callback();
                });
            addChild(obsMovie);
        }
    }


    override protected function setPosition () :void
    {
        super.setPosition();
        if (type != WALL) {
            x += Codes.PIXELS_PER_TILE/2;
            y += Codes.PIXELS_PER_TILE/2;
        }
    }

    override protected function setupGraphics () :void
    {
        if (type == WALL) {
            var obsBitmap :Bitmap = Resources.getBitmap("box_bitmap.gif");
            obsBitmap.pixelSnapping = PixelSnapping.ALWAYS;
            addChild(obsBitmap);
        } else {
            var obsMovie :MovieClip = MovieClip(new (Resources.getClass(OBS_MOVIES[type]))());
            addChild(obsMovie);
            rotation = Math.random()*360;
        }
    }

    protected static const OBS_MOVIES :Array = [
        "meteor1", "meteor2", "junk_metal"
    ];
    protected static const OBS_EXPLODE :Array = [
        "asteroid_explosion", "asteroid_explosion", null, null
    ];
}
}
