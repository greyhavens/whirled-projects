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
public class Obstacle extends Sprite
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

    public var type :int;

    /** Board-coords. */
    public var bX :Number;
    public var bY :Number;

    public function Obstacle (type :int, x :int, y :int, anim :Boolean) :void
    {
        this.type = type;
        this.x = x * Codes.PIXELS_PER_TILE;
        this.y = y * Codes.PIXELS_PER_TILE;
        if (type != WALL) {
            this.x += Codes.PIXELS_PER_TILE/2;
            this.y += Codes.PIXELS_PER_TILE/2;
        }

        bX = x;
        bY = y;

        if (anim) {
            setupGraphics();
        }
    }

    protected function setupGraphics () :void
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

    /**
     * Get a value for how much bounce ships should get off the obstacle.
     */
    public function getElasticity () :Number
    {
        // TODO: Something different for different obstacles.
        return 0.75;
    }

    /**
     * Unserialize our data from a byte array.
     */
    public function readFrom (bytes :ByteArray) :void
    {
        type = bytes.readInt();
        x = bytes.readInt();
        y = bytes.readInt();
        bX = x;
        bY = y;
        if (type != WALL) {
            bX -= Codes.PIXELS_PER_TILE/2;
            bY -= Codes.PIXELS_PER_TILE/2;
        }
        bX /= Codes.PIXELS_PER_TILE;
        bY /= Codes.PIXELS_PER_TILE;

        setupGraphics();
    }

    /**
     * Serialize our data to a byte array.
     */
    public function writeTo (bytes :ByteArray) :ByteArray
    {
        bytes.writeInt(type);
        bytes.writeInt(x);
        bytes.writeInt(y);

        return bytes;
    }

    public function tick (time :int) :void
    {
        if (type != WALL) {
            rotation = (rotation + (360 * time / 10000)) % 360;
        }
    }

    protected static const OBS_MOVIES :Array = [
        "meteor1", "meteor2", "junk_metal"
    ];
}
}
