package view {

import flash.display.Sprite;

public class ShotView extends Sprite
{
    public function ShotView (shot :ShotSprite)
    {
        _shot = shot;
        _shot.addEventListener(ShotSprite.HIT, handleHit);
    }

    /**
     * Sets the sprite position for this ship based on its board pos and
     *  another pos which will be the center of the screen.
     */
    public function setPosRelTo (otherX :Number, otherY: Number) :void
    {
        x = ((_shot.boardX - otherX) * Codes.PIXELS_PER_TILE) + (Codes.GAME_WIDTH * 0.5);
        y = ((_shot.boardY - otherY) * Codes.PIXELS_PER_TILE) + (Codes.GAME_HEIGHT * 0.5);
    }

    protected function handleHit (e :ShotHitEvent) :void
    {
    }

    protected var _shot :ShotSprite;
}

}
