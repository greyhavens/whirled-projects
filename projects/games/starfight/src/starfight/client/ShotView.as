package starfight.client {

import flash.display.Sprite;

import starfight.*;

public class ShotView extends Sprite
{
    public function ShotView (shot :Shot)
    {
        _shot = shot;
        _shot.addEventListener(Shot.HIT, handleHit);
    }

    /**
     * Sets the sprite position for this ship based on its board pos and
     *  another pos which will be the center of the screen.
     */
    public function setPosRelTo (otherX :Number, otherY: Number) :void
    {
        x = ((_shot.boardX - otherX) * Constants.PIXELS_PER_TILE) + (Constants.GAME_WIDTH * 0.5);
        y = ((_shot.boardY - otherY) * Constants.PIXELS_PER_TILE) + (Constants.GAME_HEIGHT * 0.5);
    }

    protected function handleHit (e :ShotHitEvent) :void
    {
    }

    protected var _shot :Shot;
}

}
