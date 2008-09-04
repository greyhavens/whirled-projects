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

        var saucer :SaucerShipTypeResources = ClientConstants.SHIP_RSRC_SAUCER;
        var movieClass :Class = (mine.ownerId == ClientContext.myId ? saucer.mineFriendly :
            saucer.mineEnemy);
        addChild(MovieClip(new movieClass()));

        x = (_mine.bX + 0.5) * Constants.PIXELS_PER_TILE;
        y = (_mine.bY + 0.5) * Constants.PIXELS_PER_TILE;
    }

    protected function onExploded (...ignored) :void
    {
        removeChildAt(0);

        var saucer :SaucerShipTypeResources = ClientConstants.SHIP_RSRC_SAUCER

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

        ClientContext.game.playSoundAt(saucer.mineExplodeSound, _mine.bX, _mine.bY);
    }

    protected var _mine :Mine;
}

}
