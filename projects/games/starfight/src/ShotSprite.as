package {

import flash.display.MovieClip;
import flash.display.Sprite;

public class ShotSprite extends Sprite {

    public static const NORMAL :int = 0;
    public static const SUPER :int = 1;

    /** Position. */
    public var boardX :Number;
    public var boardY :Number;

    public var complete :Boolean;

    public var shipId :int;

    public var shipType :int;

    public var ttl :Number;

    public var damage :Number;

    public function ShotSprite (x :Number, y :Number, shipId :int, damage :Number, ttl :Number,
            shipType :int, game :StarFight) :void
    {
        boardX = x;
        boardY = y;
        this.shipId = shipId;
        this.damage = damage;
        this.ttl = ttl;
        this.shipType = shipType;
        complete = false;
        _game = game;
    }

    /**
     * Allow our shot to update itself.
     */
    public function tick (board :BoardController, time :Number) :void
    {
    }

    /**
     * Sets the sprite position for this ship based on its board pos and
     *  another pos which will be the center of the screen.
     */
    public function setPosRelTo (otherX :Number, otherY: Number) :void
    {
        x = ((boardX - otherX) * Codes.PIXELS_PER_TILE) + Constants.WIDTH/2;
        y = ((boardY - otherY) * Codes.PIXELS_PER_TILE) + Constants.HEIGHT/2;
    }

    protected var _game :StarFight;

    /** Our shot animation. */
    protected var _shotMovie :MovieClip;
}
}
