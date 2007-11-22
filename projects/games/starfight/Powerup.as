package {

import flash.display.MovieClip;
import flash.display.Sprite;

import flash.utils.ByteArray;

public class Powerup extends Sprite
{
    public static const SHIELDS :int = 0;
    public static const SPEED :int = 1;
    public static const SPREAD :int = 2;
    public static const HEALTH :int = 3;
    public static const COUNT :int = 3;

    public var type :int;
    public var boardX :int;
    public var boardY :int;

    public static const SOUNDS :Array = [
        "powerup_shield.wav", "powerup_engine.wav", "powerup_shot.wav"
    ];

    public function Powerup (type :int, boardX :int, boardY :int) :void
    {
        this.type = type;
        this.boardX = boardX;
        this.boardY = boardY;

        x = (boardX + 0.5) * Codes.PIXELS_PER_TILE;
        y = (boardY + 0.5) * Codes.PIXELS_PER_TILE;

        setupGraphics();
    }

    protected function setupGraphics () :void
    {
        var powMovie :MovieClip = MovieClip(new (Resources.getClass(MOVIES[type]))());
        addChild(powMovie);
    }

    /**
     * Unserialize our data from a byte array.
     */
    public function readFrom (bytes :ByteArray) :void
    {
        type = bytes.readInt();
        x = bytes.readInt();
        y = bytes.readInt();
        boardX = (x - Codes.PIXELS_PER_TILE/2) / Codes.PIXELS_PER_TILE;
        boardY = (y - Codes.PIXELS_PER_TILE/2) / Codes.PIXELS_PER_TILE;

        removeChildAt(0);
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

    protected static const MOVIES :Array = [
        "powerup_shield", "powerup_engine", "powerup_gun", "powerup_health"
    ];
}
}
