package simon {

import com.threerings.util.ArrayUtil;
import com.whirled.avrg.AVRGameControlEvent;
import com.whirled.contrib.simplegame.objects.*;
import com.whirled.contrib.simplegame.resource.*;

import flash.display.DisplayObject;
import flash.display.InteractiveObject;
import flash.display.MovieClip;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.text.TextField;

public class CloudViewController extends SceneObject
{
    public static const NAME :String = "CloudViewController";

    public function CloudViewController ()
    {
        _cloud = SwfResource.instantiateMovieClip("ui", "cloud");
    }

    override public function get displayObject () :DisplayObject
    {
        return _cloud;
    }

    override public function get objectName () :String
    {
        return NAME;
    }

    override protected function addedToDB () :void
    {
        // collapse/expand buttons
        var collapseButton :InteractiveObject = _cloud[COLLAPSE_BUTTON_NAME];
        var expandButton :InteractiveObject = _cloud[EXPAND_BUTTON_NAME];
        var helpButton :InteractiveObject = _cloud[HELP_BUTTON_NAME];

        collapseButton.addEventListener(MouseEvent.CLICK, toggleCollapse, false, 0, true);
        expandButton.addEventListener(MouseEvent.CLICK, toggleCollapse, false, 0, true);
        helpButton.addEventListener(MouseEvent.CLICK, toggleHelp, false, 0, true);

        // scroll buttons
        var scrollUpButton :InteractiveObject = _cloud[SCROLL_UP_BUTTON_NAME];
        var scrollDownButton :InteractiveObject = _cloud[SCROLL_DOWN_BUTTON_NAME];

        scrollUpButton.addEventListener(MouseEvent.CLICK, handleScrollUp, false, 0, true);
        scrollDownButton.addEventListener(MouseEvent.CLICK, handleScrollDown, false, 0, true);

        // quit button
        var quitButton :InteractiveObject = _cloud[QUIT_BUTTON_NAME];
        quitButton.addEventListener(MouseEvent.CLICK, quit, false, 0, true);

        // other events
        SimonMain.model.addEventListener(SimonEvent.GAME_STATE_CHANGED, updateStatusText, false, 0, true);
        SimonMain.model.addEventListener(SimonEvent.NEW_SCORES, updateNamesAndScores, false, 0, true);
        SimonMain.model.addEventListener(SimonEvent.NEXT_PLAYER, updateNamesAndScores, false, 0, true);
        SimonMain.model.addEventListener(SimonEvent.PLAYERS_CHANGED, updateNamesAndScores, false, 0, true);

        SimonMain.control.local.addEventListener(AVRGameControlEvent.SIZE_CHANGED, handleSizeChanged, false, 0, true);

        // setup initial state
        _collapsed = true;
        this.toggleCollapse();
        this.handleSizeChanged();
        this.updateNamesAndScores();
        this.updateStatusText();
    }

    override protected function removedFromDB () :void
    {
        SimonMain.model.removeEventListener(SimonEvent.GAME_STATE_CHANGED, updateStatusText);
        SimonMain.model.removeEventListener(SimonEvent.NEW_SCORES, updateNamesAndScores);
        SimonMain.model.removeEventListener(SimonEvent.NEXT_PLAYER, updateNamesAndScores);
        SimonMain.model.removeEventListener(SimonEvent.PLAYERS_CHANGED, updateNamesAndScores);

        SimonMain.control.local.removeEventListener(AVRGameControlEvent.SIZE_CHANGED, handleSizeChanged);
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

    protected function toggleHelp (...ignored) :void
    {
        var gameMode :GameMode = this.db as GameMode;
        gameMode.helpScreenVisible = !(gameMode.helpScreenVisible);
    }

    protected function quit (...ignored) :void
    {
        SimonMain.quit();
    }

    protected function updateStatusText (...ignored) :void
    {
        // Has this player played a game yet? Tell them they will join at the beginning
        // of the next round if not.
        _hasPlayedGame = (_hasPlayedGame ||  ArrayUtil.contains(SimonMain.model.curState.players, SimonMain.localPlayerId));

        switch (SimonMain.model.curState.gameState) {

        case State.STATE_WAITINGFORPLAYERS:
            var numPlayersNeeded :int = Constants.MIN_MP_PLAYERS_TO_START - SimonMain.model.getPlayerOids().length;
            this.statusTextField.text = "Get " + (numPlayersNeeded == 1 ? "a friend" : String(numPlayersNeeded) + " friends") + " to play!";
            break;

        case State.STATE_WEHAVEAWINNER:
            var winnerId :int = SimonMain.model.curState.roundWinnerId;
            var patternEmpty :Boolean = SimonMain.model.curState.pattern.length == 0;

            if (winnerId != 0 && !patternEmpty) {
                var winnerName :String = SimonMain.getPlayerName(SimonMain.model.curState.roundWinnerId);
                this.statusTextField.text = winnerName + " wins!";
            } else {
                this.statusTextField.text = "No winner this round";
            }
            break;

        default:
            if (!_hasPlayedGame) {
                this.statusTextField.text = "You're in the next round!";
            } else {
                this.statusTextField.text = "";
            }
            break;
        }
    }

    protected function updateNamesAndScores (...ignored) :void
    {
        var state :State = SimonMain.model.curState;

        // start with players who are currently playing
        var playerList :Array = state.playersInState(State.PLAYER_READY);

        // add in all other players
        for each (var playerId :int in state.players) {
            if (playerList.indexOf(playerId) < 0) {
                playerList.push(playerId);
            }
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
            var playerScoreObj :Score = SimonMain.model.curScores.getScore(playerId);
            var playerScore :int = (null == playerScoreObj ? 0 : playerScoreObj.score);

            var playerIsIn :Boolean = state.getPlayerState(playerId) == State.PLAYER_READY;
            var playerIsActive :Boolean = (playerIsIn && state.curPlayerOid == playerId);

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
            var stageSize :Rectangle = SimonMain.control.local.getStageSize(true);

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

    protected function get statusTextField () :TextField
    {
        return _cloud[STATUS_TEXT_NAME];
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
    protected static const HELP_BUTTON_NAME :String = "help";
    protected static const QUIT_BUTTON_NAME :String = "quit";
    protected static const SCROLL_UP_BUTTON_NAME :String = "scroll_up";
    protected static const SCROLL_DOWN_BUTTON_NAME :String = "scroll_down";
    protected static const PLAYER_LIST_NAME :String = "players";
    protected static const SCORE_LIST_NAME :String = "scores";
    protected static const STATUS_TEXT_NAME :String = "status";

}

}
