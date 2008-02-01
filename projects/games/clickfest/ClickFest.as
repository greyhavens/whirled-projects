package {

import flash.display.Graphics;
import flash.display.Sprite;

import flash.events.MouseEvent;

import com.whirled.GameSubControl;
import com.whirled.WhirledGameControl;

import com.threerings.ezgame.PropertyChangedEvent;
import com.threerings.ezgame.StateChangedEvent;
import com.threerings.ezgame.MessageReceivedEvent;

[SWF(width="400", height="400")]
public class ClickFest extends Sprite
{
    public function ClickFest ()
    {
        var spr :Sprite = new Sprite();
        spr.addEventListener(MouseEvent.CLICK, mouseClicked);
        addChild(spr);

        _drawArea = spr.graphics;

        _ctrl = new WhirledGameControl(this);

        // set up our listeners
        _ctrl.game.addEventListener(StateChangedEvent.GAME_STARTED, gameStarted);
        _ctrl.game.addEventListener(StateChangedEvent.GAME_ENDED, gameEnded);
        _ctrl.net.addEventListener(PropertyChangedEvent.PROPERTY_CHANGED, propChanged);

        // do some other fun stuff
        _ctrl.local.feedback("Welcome to ClickFest!\n\n" +
            "The object of the game is simple: Click like the wind!\n\n" +
            "You are awarded " + POINTS_NEW + " point for clicking on a " +
            "new point, or " + POINTS_OVER_OTHER + " points for clicking on " +
            "a point of another player's color. Be careful, you'll get " +
            POINTS_OVER_SELF + " points for clicking on your own point.\n\n" +
            "The first player to " + SCORE_TO_WIN + " points wins.");

        if (_ctrl.game.isInPlay()) {
            clearDrawArea();

            // fill in any already-marked spots
            for (var key :String in _ctrl.net.getPropertyNames("p")) {
                drawClick(key, _ctrl.net.get(key));
            }
        }
    }

    protected function clearDrawArea () :void
    {
        _drawArea.clear();
        // must fill with black so that we get clicks
        _drawArea.beginFill(0x330000);
        _drawArea.drawRect(0, 0, 400, 400);
    }

    protected function gameStarted (event :StateChangedEvent) :void
    {
        clearDrawArea();
        _myScore = 0;
        _ctrl.local.feedback("GO!!!!");

        // start processing!
        mouseChildren = true;
    }

    protected function mouseClicked (event :MouseEvent) :void
    {
        var myIdx :int = _ctrl.game.seating.getMyPosition();
        var key :String = "p" + event.localX + ":" + event.localY;

        var prev :Object = _ctrl.net.get(key);
        var points :int;
        if (prev == null) {
            points = POINTS_NEW;

        } else if (prev === myId) {
            points = POINTS_OVER_SELF;

        } else {
            points = POINTS_OVER_OTHER;
        }

        _ctrl.net.set(key, myIdx);

        _myScore += points;
        if (_myScore >= SCORE_TO_WIN) {
            var myId :int = _ctrl.game.getMyId();
            var losers :Array = _ctrl.game.seating.getPlayerIds();
            losers.splice(losers.indexOf(myId), 1);

            _ctrl.game.endGameWithWinners([ myId ], losers, GameSubControl.WINNERS_TAKE_ALL);
        }
    }

    protected function propChanged (event :PropertyChangedEvent) :void
    {
        if (event.name.charAt(0) == "p") {
            drawClick(event.name, event.newValue);
        }
    }

    protected function drawClick (propName :String, value :Object) :void
    {
        var player :int = int(value);

        var coords :Array =
            propName.substr(1, propName.length - 1).split(":");
        var x :Number = parseInt(coords[0]);
        var y :Number = parseInt(coords[1]);

        _drawArea.beginFill(uint(COLORS[player]));
        _drawArea.drawRect(x, y, 1, 1);
    }

    protected function gameEnded (event :StateChangedEvent) :void
    {
        mouseChildren = false;
    }

    protected var _ctrl :WhirledGameControl;

    protected var _myScore :int;

    protected var _drawArea :Graphics;

    protected static const COLORS :Array = [ 0x66FF00 , 0x6600FF ];

    protected static const POINTS_NEW :int = 1;
    protected static const POINTS_OVER_OTHER :int = 5;
    protected static const POINTS_OVER_SELF :int = -10;
    protected static const SCORE_TO_WIN :int = 100;
}
}
