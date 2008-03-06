package {

import flash.display.Graphics;
import flash.display.Sprite;

import flash.events.MouseEvent;

import flash.utils.Dictionary;

import com.threerings.util.StringUtil;

import com.whirled.game.*;

/**
 * Clickfest: sample game.
 */
[SWF(width="700", height="500")]
public class ClickFest extends Sprite
{
    public static const WIDTH :int = 700;
    public static const HEIGHT :int = 500;

    public static const GRANUL :int = 2;

    public function ClickFest ()
    {
        // turn off mouse handling, we'll turn it on again later just for players
        mouseChildren = false;
        // create a sub-sprite for receiving mouse events and drawing the game board..
        var spr :Sprite = new Sprite();
        spr.addEventListener(MouseEvent.CLICK, handleMouseClick);
        addChild(spr);
        _drawArea = spr.graphics;

        // create the game control
        _ctrl = new GameControl(this);

        // set up our listeners
        _ctrl.game.addEventListener(StateChangedEvent.GAME_STARTED, gameStarted);
        _ctrl.game.addEventListener(StateChangedEvent.GAME_ENDED, gameEnded);
        _ctrl.net.addEventListener(PropertyChangedEvent.PROPERTY_CHANGED, propChanged);
        _ctrl.net.addEventListener(ElementChangedEvent.ELEMENT_CHANGED, elemChanged);

        // do some other fun stuff
        _ctrl.local.feedback("Welcome to ClickFest!\n\n" +
            "The object of the game is simple: Click like the wind!\n\n" +
            "You are awarded " + POINTS_NEW + " point for clicking on a " +
            "new point, or " + POINTS_OVER_OTHER + " points for clicking on " +
            "a point of another player's color. Be careful, you'll get " +
            POINTS_OVER_SELF + " points for clicking on your own point.\n\n" +
            "The first player to " + SCORE_TO_WIN + " points wins.");

        // see what our index is. If -1, we're not a player, just a watcher.
        _myId = _ctrl.game.getMyId();

        // pick a color and insert it for ourselves
        var myColor :uint = (int(256 * Math.random()) << 16) | (int(256 * Math.random()) << 8) |
            int(256 * Math.random());
        _ctrl.net.setIn(COLORS, _myId, myColor);

        updateScores(_ctrl.net.get(SCORES) as Dictionary);

        // if the game is being played right now, we
        if (_ctrl.game.isInPlay()) {
            clearDrawArea();

            // fill in any already-marked spots
            var dots :Dictionary = _ctrl.net.get(DOTS) as Dictionary;
            for (var key :Object in dots) {
                drawDot(int(key), dots[key]);
            }

            // if we're a real player, start listening for clicks!
            mouseChildren = true;
        }
    }

    protected function clearDrawArea () :void
    {
        _drawArea.clear();
        // must fill with black so that we get clicks
        _drawArea.beginFill(0x330000);
        _drawArea.drawRect(0, 0, WIDTH, HEIGHT);
    }

    protected function gameStarted (event :StateChangedEvent) :void
    {
        clearDrawArea();
        mouseChildren = true;
        _ctrl.local.feedback("GO!!!!");

        // use amInControl() to coordinate something so that only one player does it
        if (_ctrl.game.amInControl()) {
            _localScores = new Dictionary();
            _ctrl.net.set(SCORES, null);
        }
    }

    protected function handleMouseClick (event :MouseEvent) :void
    {
        var key :int = int(event.localY / GRANUL) * WID + int(event.localX / GRANUL);
        _ctrl.net.setIn(DOTS, key, _myId);
    }

    protected function propChanged (event :PropertyChangedEvent) :void
    {
        if (event.name == SCORES) {
            // the entire scores array changed
            updateScores(event.newValue as Dictionary);
        }
    }

    protected function elemChanged (event :ElementChangedEvent) :void
    {
        if (event.name == SCORES) {
            var obj :Object = {};
            obj[event.key] = event.newValue;
            _ctrl.local.setMappedScores(obj);
            return;
        }

        if (event.name != DOTS) {
            return;
        }

        var key :int = event.key;
        var playerId :int = int(event.newValue);

        // go ahead and draw the click
        drawDot(key, playerId);

        // if we're in control, figure out the new number of points
        if (_ctrl.game.amInControl()) {
            var prev :Object = event.oldValue;
            var points :int;
            if (prev == null) {
                points = POINTS_NEW; // we're the first person to click there
            } else if (prev === playerId) {
                points = POINTS_OVER_SELF; // oops, we clicked on our own dot!
            } else {
                points = POINTS_OVER_OTHER; // yay! We clicked on our opponent's dot.
            }

            var newScore :int = int(_localScores[playerId]) + points;
            _localScores[playerId] = newScore;

            // update the score- here we're just updating our own element in the score array
            _ctrl.net.setIn(SCORES, playerId, newScore);

            // did we just win? End the game with us as the winner..
            if (newScore >= SCORE_TO_WIN) {
                var losers :Array = _ctrl.game.seating.getPlayerIds();
                losers.splice(losers.indexOf(playerId), 1);
                _ctrl.game.endGameWithWinners([ playerId ], losers,
                    GameSubControl.WINNERS_TAKE_ALL);
            }
        }
    }

    protected function drawDot (key :int, player :int) :void
    {
        var y :int = int(key / WID) * GRANUL;
        var x :int = int(key % WID) * GRANUL;

        _drawArea.beginFill(uint(_ctrl.net.get(COLORS)[player]));
        _drawArea.drawRect(x, y, GRANUL, GRANUL);
    }

    protected function updateScores (scores :Dictionary) :void
    {
        if (scores == null) {
            _ctrl.local.clearScores(0);
        } else {
            _ctrl.local.setMappedScores(scores);
        }
    }

    protected function gameEnded (event :StateChangedEvent) :void
    {
        // stop listening for clicks
        mouseChildren = false;
    }

    protected var _ctrl :GameControl;

    protected var _myId :int;

    protected var _drawArea :Graphics;

    protected var _localScores :Dictionary = new Dictionary();

    protected static const SCORES :String = "scores";

    protected static const DOTS :String = "p";

    protected static const COLORS :String = "color";

    protected static const WID :int = int(WIDTH / GRANUL);

    protected static const POINTS_NEW :int = 1;
    protected static const POINTS_OVER_OTHER :int = 5;
    protected static const POINTS_OVER_SELF :int = -10;
    protected static const SCORE_TO_WIN :int = 100;
}
}
