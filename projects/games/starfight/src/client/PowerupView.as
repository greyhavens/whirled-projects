package client {

import flash.display.MovieClip;
import flash.display.Sprite;
import flash.media.Sound;

public class PowerupView extends Sprite
{
    public function PowerupView (powerup :Powerup)
    {
        _powerup = powerup;
        _powerup.addEventListener(Powerup.CONSUMED, onConsumed);
        _powerup.addEventListener(Powerup.DESTROYED, onDestroyed);

        var powMovie :MovieClip = MovieClip(new (Resources.getClass(MOVIES[powerup.type]))());
        addChild(powMovie);

        x = (_powerup.bX + 0.5) * Codes.PIXELS_PER_TILE;
        y = (_powerup.bY + 0.5) * Codes.PIXELS_PER_TILE;
    }

    protected function sound () :Sound
    {
        return Resources.getSound(MOVIES[_powerup.type] + ".wav");
    }

    protected function onConsumed (...ignored) :void
    {
        AppContext.game.playSoundAt(sound(), _powerup.bX, _powerup.bY);
    }

    protected function onDestroyed (...ignored) :void
    {
        if (this.parent != null) {
            this.parent.removeChild(this);
        }
    }

    protected var _powerup :Powerup;

    protected static const MOVIES :Array = [
        "powerup_shield", "powerup_engine", "powerup_gun", "powerup_health"
    ];
}

}
