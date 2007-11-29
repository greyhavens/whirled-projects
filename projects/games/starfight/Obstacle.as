package {

import flash.display.Graphics;

import flash.utils.ByteArray;

import flash.display.Bitmap;
import flash.display.MovieClip;
import flash.display.PixelSnapping;
import flash.display.Sprite;


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

    public static function readObstacle (bytes :ByteArray) :Obstacle
    {
        var obs :Obstacle = new Obstacle(0, 0, 0, false);
        obs.readFrom(bytes);
        return obs;
    }

    public function Obstacle (type :int, x :int, y :int, anim :Boolean = true) :void
    {
        super(type, x, y, anim);
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
}
}
