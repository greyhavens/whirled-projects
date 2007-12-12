package {

import flash.display.DisplayObject;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Graphics;
import flash.display.MovieClip;
import flash.display.PixelSnapping;
import flash.display.Sprite;

import flash.geom.Matrix;

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
    public var w :int;
    public var h :int;

    public static function readObstacle (bytes :ByteArray) :Obstacle
    {
        var obs :Obstacle = new Obstacle(0, 0, 0, false);
        obs.reload(bytes);
        return obs;
    }

    public function Obstacle (
        type :int, x :int, y :int, anim :Boolean = true, w :int = 0, h :int = 0) :void
    {
        super(type, x, y, false);
        health = 1.0;
        this.w = w;
        this.h = h;
        if (anim) {
            setupGraphics();
        }
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
        w = bytes.readInt();
        h = bytes.readInt();
    }

    override public function writeTo (bytes :ByteArray) :ByteArray
    {
        bytes = super.writeTo(bytes);
        bytes.writeInt(w);
        bytes.writeInt(h);
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
                    obsMovie.removeEventListener(Event.COMPLETE, arguments.callee);
                    callback();
                });
            addChild(obsMovie);
        }
    }

    public function showObs () :Boolean
    {
        return numChildren > 0;
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
            if (w == 0 || h == 0) {
                return;
            }
            var data :BitmapData = new BitmapData(
                    w * Codes.PIXELS_PER_TILE, h * Codes.PIXELS_PER_TILE);
            var drawData :BitmapData = Resources.getBitmapData("box_bitmap.gif");
            var matrix :Matrix;
            for (var yy :int = 0; yy < h; yy++) {
                for (var xx :int = 0; xx < w; xx++) {
                    matrix = new Matrix();
                    matrix.translate(xx * Codes.PIXELS_PER_TILE, yy * Codes.PIXELS_PER_TILE);
                    data.draw(drawData, matrix);
                }
            }
            addChild(new Bitmap(data));
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
