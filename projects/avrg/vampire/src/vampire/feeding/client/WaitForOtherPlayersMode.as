package vampire.feeding.client {

import com.whirled.contrib.simplegame.AppMode;
import com.whirled.contrib.simplegame.objects.SimpleTimer;

import flash.display.MovieClip;

public class WaitForOtherPlayersMode extends AppMode
{
    override protected function setup () :void
    {
        // If several seconds have elapsed, and other players still haven't checked in,
        // they're probably reading the directions. Let the player know what's going on.
        addObject(new SimpleTimer(DELAY, displayAlert));
    }

    protected function displayAlert () :void
    {
        var movie :MovieClip = ClientCtx.instantiateMovieClip("blood", "waiting_panel");
        movie.x = 170;
        movie.y = 80;
        _modeSprite.addChild(movie);
    }

    protected static const DELAY :Number = 1.5;
}

}
