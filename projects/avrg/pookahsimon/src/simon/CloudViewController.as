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
        SimonMain.model.addEventListener(SharedStateChangedEvent.GAME_STATE_CHANGED, updateText, false, 0, true);
        SimonMain.model.addEventListener(SharedStateChangedEvent.NEW_SCORES, updateText, false, 0, true);
        SimonMain.model.addEventListener(SharedStateChangedEvent.NEXT_PLAYER, updateText, false, 0, true);

        SimonMain.control.addEventListener(AVRGameControlEvent.SIZE_CHANGED, handleSizeChanged, false, 0, true);

        // setup initial state
        _collapsed = true;
        this.toggleCollapse();
        this.handleSizeChanged();
        this.updateText();
    }

    public function destroy () :void
    {
        SimonMain.sprite.removeChild(_cloud);

        SimonMain.model.removeEventListener(SharedStateChangedEvent.GAME_STATE_CHANGED, updateText);
        SimonMain.model.removeEventListener(SharedStateChangedEvent.NEW_SCORES, updateText);
        SimonMain.model.removeEventListener(SharedStateChangedEvent.NEXT_PLAYER, updateText);

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

    protected function updateText (...ignored) :void
    {
        switch (SimonMain.model.curState.gameState) {

        case SharedState.WAITING_FOR_GAME_START:
            this.drawWaitingForGameStartText();
            break;

        case SharedState.WE_HAVE_A_WINNER:
            this.drawWinnerText();
            break;

        default:
            this.drawNamesAndScores();
            break;
        }
    }

    protected function drawWaitingForGameStartText () :void
    {
        this.canScrollUp = false;
        this.canScrollDown = false;

        var waitingForPlayers :int = Constants.MIN_MP_PLAYERS_TO_START - SimonMain.model.getPlayerOids().length;

        this.playersTextField.text = String(waitingForPlayers) + " more " + (waitingForPlayers == 1 ? "player" : "players") + "\nneeded";
        this.scoresTextField.text = "";
    }

    protected function drawWinnerText () :void
    {
        this.canScrollUp = false;
        this.canScrollDown = false;

        var winnerName :String = SimonMain.getPlayerName(SimonMain.model.curState.roundWinnerId);

        this.playersTextField.text = winnerName + "\nwins!";
        this.scoresTextField.text = "";
    }

    protected function drawWaitForNextRoundText () :void
    {
        this.canScrollUp = false;
        this.canScrollDown = false;

        this.playersTextField.text = "You will\nplay when\nthe next\nround\nbegins";
        this.scoresTextField.text = "";
    }

    protected function drawNamesAndScores () :void
    {
        var currentPlayers :Array = SimonMain.model.curState.players;   // players currently playing

        // Has this player played a game yet? Tell them they will join at the beginning
        // of the next round if not.
        _hasPlayedGame = (_hasPlayedGame ||  ArrayUtil.contains(currentPlayers, SimonMain.localPlayerId));
        if (!_hasPlayedGame) {
            this.drawWaitForNextRoundText();
            return;
        }

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

        this.canScrollUp = _firstVisibleRow > 0;
        this.canScrollDown = playerList.length > (_firstVisibleRow + NUM_ROWS);

        // draw the names and scores
        var playerString :String = "";
        var scoreString :String = "";

        var numNames :int = Math.min(playerList.length - _firstVisibleRow, NUM_ROWS);

        for (var i :int = _firstVisibleRow; i < _firstVisibleRow + numNames; ++i) {

            playerId = playerList[i];

            var playerName :String = SimonMain.getPlayerName(playerId);
            var playerScore :int = SimonMain.model.curScores.getPlayerScore(playerName);

            var playerIsIn :Boolean = (i < currentPlayers.length);
            var playerIsActive :Boolean = (playerIsIn && SimonMain.model.curState.curPlayerOid == playerId);

            var colorString :String;
            var boldText :Boolean;

            if (playerIsActive) {
                colorString = ACTIVE_PLAYER_COLOR;
                boldText = true;
            } else if (playerIsIn) {
                colorString = IN_PLAYER_COLOR;
                boldText = false;
            } else {
                colorString = OUT_PLAYER_COLOR;
                boldText = false;
            }

            var textPrefix :String = (boldText ? "<b>" : "") + "<font color='" + colorString + "'>";
            var textSuffix :String = "</font>" + (boldText ? "</b>" : "");

            playerString += textPrefix + playerName + textSuffix + "\n";
            scoreString += textPrefix + (playerScore > 0 ? String(playerScore) : "") + textSuffix + "\n";
        }

        this.playersTextField.htmlText = playerString;
        this.scoresTextField.htmlText = scoreString;
    }

    protected function handleScrollUp (...ignored) :void
    {
        _firstVisibleRow -= 1;
        this.updateText();
    }

    protected function handleScrollDown (...ignored) :void
    {
        _firstVisibleRow += 1;
        this.updateText();
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

    protected function set canScrollUp (val :Boolean) :void
    {
        var scrollUpButton :InteractiveObject = _cloud[SCROLL_UP_BUTTON_NAME];
        scrollUpButton.visible = val;
        scrollUpButton.mouseEnabled = val;
    }

    protected function set canScrollDown (val :Boolean) :void
    {
        var scrollDownButton :InteractiveObject = _cloud[SCROLL_DOWN_BUTTON_NAME];
        scrollDownButton.visible = val;
        scrollDownButton.mouseEnabled = val;
    }

    protected function get playersTextField () :TextField
    {
        return _cloud[PLAYER_LIST_NAME];
    }

    protected function get scoresTextField () :TextField
    {
        return _cloud[SCORE_LIST_NAME];
    }

    protected var _cloud :MovieClip;
    protected var _collapsed :Boolean;
    protected var _firstVisibleRow :int;
    protected var _hasPlayedGame :Boolean;

    protected static const COLLAPSED_OFFSET :Point = new Point(0, -20);
    protected static const EXPANDED_OFFSET :Point = new Point(-220, -20);

    protected static const NUM_ROWS :int = 10;

    protected static const ACTIVE_PLAYER_COLOR :String = "#000000";
    protected static const IN_PLAYER_COLOR :String = "#818181";
    protected static const OUT_PLAYER_COLOR :String = "#CDCDCD";

    protected static const COLLAPSE_BUTTON_NAME :String = "collapse";
    protected static const EXPAND_BUTTON_NAME :String = "expand";
    protected static const QUIT_BUTTON_NAME :String = "quit";
    protected static const SCROLL_UP_BUTTON_NAME :String = "scroll_up";
    protected static const SCROLL_DOWN_BUTTON_NAME :String = "scroll_down";
    protected static const PLAYER_LIST_NAME :String = "players";
    protected static const SCORE_LIST_NAME :String = "scores";

}

}
