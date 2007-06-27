package {

import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.text.TextField;

import com.threerings.ezgame.PlayersDisplay;

public class ReversiPlayersDisplay extends PlayersDisplay
{
    override protected function createHeader () :TextField
    {
        return null; // no header
    }

    override protected function createPlayerIcon (id :int, name :String) :DisplayObject
    {
        var piece :MovieClip;
        if (_gameCtrl.seating.getPlayerPosition(id) == 0) {
            piece = MovieClip(new white_piece());
        } else {
            piece = MovieClip(new black_piece());
        }
        piece.width = 25;
        piece.height = 25;
        return piece;
    }

    override function getBorderSpacing () :int
    {
        return 0;
    }

    override function drawBorder (maxWidth :int) :void
    {
        // no border
    }
}
}
