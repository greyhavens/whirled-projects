package {

import flash.events.Event;
import flash.media.Sound;
import flash.utils.ByteArray;

/**
 * Represents something in the world that ships may interact with.
 */
public class Obstacle extends BoardObject
{
    public static const EXPLODED :String = "Exploded";

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
        var obs :Obstacle = new Obstacle(0, 0, 0);
        obs.reload(bytes);
        return obs;
    }

    public function Obstacle (type :int, x :int, y :int, w :int = 0, h :int = 0) :void
    {
        super(type, x, y);
        health = 1.0;
        this.w = w;
        this.h = h;
    }

    /**
     * Get a value for how much bounce ships should get off the obstacle.
     */
    public function getElasticity () :Number
    {
        // TODO: Something different for different obstacles.
        return 0.75;
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

    public function explode () :void
    {
        dispatchEvent(new Event(EXPLODED));
    }

    protected static const OBS_MOVIES :Array = [
        "meteor1", "meteor2", "junk_metal"
    ];
    protected static const OBS_EXPLODE :Array = [
        "asteroid_explosion", "asteroid_explosion", null, null
    ];
}
}
