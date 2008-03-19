package simon {

import com.threerings.util.ArrayUtil;
import com.whirled.AVRGameControlEvent;

import flash.display.InteractiveObject;
import flash.display.MovieClip;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.text.TextField;

public class CloudViewController
{
    public function CloudViewController ()
    {
        var cloudClass :Class = SimonMain.resourcesDomain.getDefinition("cloud") as Class;
        _cloud = new cloudClass();

        SimonMain.sprite.addChild(_cloud);

        // collapse/expand buttons
        var collapseButton :InteractiveObject = _cloud[COLLAPSE_BUTTON_NAME];
        var expandButton :InteractiveObject = _cloud[EXPAND_BUTTON_NAME];

        collapseButton.addEventListener(MouseEvent.CLICK, toggleCollapse, false, 0, true);
        expandButton.addEventListener(MouseEvent.CLICK, toggleCollapse, false, 0, true);

        // scroll buttons
        var scrollUpButton :InteractiveObject = _cloud[SCROLL_UP_BUTTON_NAME];
        var scrollDownButton :InteractiveObject = _cloud[SCROLL_DOWN_BUTTON_NAME];

        scrollUpButton.addEventListener(MouseEvent.CLICK, handleScrollUp, false, 0, true);
        scrollDownButton.addEventListener(MouseEvent.CLICK, handleScrollDown, false, 0, true);

        // quit button
        var quitButton :InteractiveObject = _cloud[QUIT_BUTTON_NAME];
        quitButton.addEventListener(MouseEvent.CLICK, quit, false, 0, true);

        // other events
        SimonMain.model.addEventListener(SharedStateChangedEvent.NEW_SCORES, handleNewScores, false, 0, true);
        SimonMain.model.addEventListener(SharedStateChangedEvent.NEXT_PLAYER, handleNextPlayer, false, 0, true);

        SimonMain.control.addEventListener(AVRGameControlEvent.SIZE_CHANGED, handleSizeChanged, false, 0, true);

        // setup initial state
        _collapsed = true;
        this.toggleCollapse();

        this.updateNamesAndScores();
    }

    public function destroy () :void
    {
        SimonMain.sprite.removeChild(_cloud);

        SimonMain.model.removeEventListener(SharedStateChangedEvent.NEW_SCORES, handleNewScores);
        SimonMain.model.removeEventListener(SharedStateChangedEvent.NEXT_PLAYER, handleNextPlayer);

        SimonMain.control.removeEventListener(AVRGameControlEvent.SIZE_CHANGED, handleSizeChanged);
    }

    protected function toggleCollapse (...ignored) :void
    {
        _collapsed = !_collapsed;

        var newLoc :Point = this.properLocation;
        _cloud.x = newLoc.x;
        _cloud.y = newLoc.y;

        var collapseButton :InteractiveObject = _cloud[COLLAPSE_BUTTON_NAME];
        var expandButton :InteractiveObject = _cloud[EXPAND_BUTTON_NAME];

        collapseButton.visible = !_collapsed;
        collapseButton.mouseEnabled = !_collapsed;

        expandButton.visible = _collapsed;
        expandButton.mouseEnabled = _collapsed;
    }

    protected function quit (...ignored) :void
    {
        SimonMain.quit();
    }

    protected function updateNamesAndScores () :void
    {
        var currentPlayers :Array = SimonMain.model.curState.players;   // players currently playing
        var allPlayers :Array = SimonMain.model.getPlayerOids();        // all the players, playing or not

        // remove current players from all players
        for each (var playerId :int in currentPlayers) {
            ArrayUtil.removeAll(allPlayers, playerId);
        }

        // splice the two lists together
        var playerList :Array = currentPlayers.slice();
        //playerList.splice(-1, 0, allPlayers); // why doesn't this work?
        for each (playerId in allPlayers) {
            playerList.push(playerId);
        }

        // handle scroll buttons
        _firstVisibleRow = Math.min(_firstVisibleRow, playerList.length - NUM_ROWS);
        _firstVisibleRow = Math.max(_firstVisibleRow, 0);

        var canScrollUp :Boolean = _firstVisibleRow > 0;
        var canScrollDown :Boolean = playerList.length > (_firstVisibleRow + NUM_ROWS);

        var scrollUpButton :InteractiveObject = _cloud[SCROLL_UP_BUTTON_NAME];
        var scrollDownButton :InteractiveObject = _cloud[SCROLL_DOWN_BUTTON_NAME];

        scrollUpButton.visible = canScrollUp;
        scrollUpButton.mouseEnabled = canScrollUp;

        scrollDownButton.visible = canScrollDown;
        scrollDownButton.mouseEnabled = canScrollDown;

        // draw the names and scores
        var playerString :String = "";
        var scoreString :String = "";

        var numNames :int = Math.min(playerList.length - _firstVisibleRow, NUM_ROWS);

        for (var i :int = _firstVisibleRow; i < _firstVisibleRow + numNames; ++i) {

            playerId = playerList[i];

            var playerName :String = SimonMain.getPlayerName(playerId);
            var playerScore :int = SimonMain.model.curScores.getPlayerScore(playerName);

            playerString += playerName + "\n";
            scoreString += (playerScore > 0 ? playerScore + "\n" : "\n");
        }

        var playerText :TextField = _cloud[PLAYER_LIST_NAME];
        playerText.text = playerString;

        var scoreText :TextField = _cloud[SCORE_LIST_NAME];
        scoreText.text = scoreString;

    }

    protected function handleNewScores (...ignored) :void
    {
        this.updateNamesAndScores();
    }

    protected function handleNextPlayer (...ignored) :void
    {
        this.updateNamesAndScores();
    }

    protected function handleScrollUp (...ignored) :void
    {
        _firstVisibleRow -= 1;
        this.updateNamesAndScores();
    }

    protected function handleScrollDown (...ignored) :void
    {
        _firstVisibleRow += 1;
        this.updateNamesAndScores();
    }

    protected function handleSizeChanged (...ignored) :void
    {
        var loc :Point = this.properLocation;

        _cloud.x = loc.x;
        _cloud.y = loc.y;
    }

    protected function get properLocation () :Point
    {
        var offset :Point = (_collapsed ? COLLAPSED_OFFSET : EXPANDED_OFFSET);

        var loc :Point;

        if (SimonMain.control.isConnected()) {
            var stageSize :Rectangle = SimonMain.control.getStageSize(true);

            loc = (null != stageSize
                    ? new Point(stageSize.right + offset.x, stageSize.top + offset.y)
                    : new Point(0, 0));

        } else {
            loc = new Point(700 + offset.x, offset.y);
        }

        return loc;
    }

    protected var _cloud :MovieClip;
    protected var _collapsed :Boolean;
    protected var _firstVisibleRow :int;

    protected static const COLLAPSED_OFFSET :Point = new Point(0, 0);
    protected static const EXPANDED_OFFSET :Point = new Point(-220, 0);

    protected static const NUM_ROWS :int = 14;

    protected static const COLLAPSE_BUTTON_NAME :String = "collapse";
    protected static const EXPAND_BUTTON_NAME :String = "expand";
    protected static const QUIT_BUTTON_NAME :String = "quit";
    protected static const SCROLL_UP_BUTTON_NAME :String = "scroll_up";
    protected static const SCROLL_DOWN_BUTTON_NAME :String = "scroll_down";
    protected static const PLAYER_LIST_NAME :String = "players";
    protected static const SCORE_LIST_NAME :String = "scores";

}

}
