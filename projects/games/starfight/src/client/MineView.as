package client {

import flash.display.MovieClip;
import flash.display.Sprite;
import flash.events.Event;

public class MineView extends Sprite
{
    public function MineView (mine :Mine)
    {
        _mine = mine;
        _mine.addEventListener(Mine.EXPLODED, onExploded);

        var saucer :SaucerShipType = Codes.SHIP_TYPE_SAUCER;
        addChild(MovieClip(new (mine.active ? saucer.mineEnemy : saucer.mineFriendly)()));

        x = (_mine.bX + 0.5) * Codes.PIXELS_PER_TILE;
        y = (_mine.bY + 0.5) * Codes.PIXELS_PER_TILE;
    }

    protected function onExploded (...ignored) :void
    {
        removeChildAt(0);

        var saucer :SaucerShipType = Codes.SHIP_TYPE_SAUCER;

        var thisMineView :MineView = this;
        var expMovie :MovieClip = MovieClip(new (saucer.mineExplode)());
        addChild(expMovie);

        // remove from the display list when the explosion movie completes
        expMovie.addEventListener(Event.COMPLETE, function (event :Event) :void {
            expMovie.removeEventListener(Event.COMPLETE, arguments.callee);
            if (thisMineView.parent != null) {
                thisMineView.parent.removeChild(thisMineView);
            }
        });

        AppContext.game.playSoundAt(saucer.mineExplodeSound, _mine.bX, _mine.bY);
    }

    protected var _mine :Mine;
}

}
