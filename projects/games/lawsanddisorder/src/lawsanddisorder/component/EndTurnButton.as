package lawsanddisorder.component {

import flash.display.Sprite;
import flash.text.TextField;
import flash.events.MouseEvent;
import flash.events.Event;
import flash.utils.Timer;
import flash.events.TimerEvent;

import com.whirled.game.MessageReceivedEvent;
import com.whirled.game.StateChangedEvent;

import lawsanddisorder.*;

/**
 * Contains a turn indicator and button for ending the turn.  This component handles turn end as
 * well as turn start for the player.
 */
public class EndTurnButton extends Button
{
    /**
     * Constructor
     */
    public function EndTurnButton (ctx :Context, board :Board)
    {
        super(ctx);
        _ctx.control.game.addEventListener(StateChangedEvent.TURN_CHANGED, turnChanged);
        addEventListener(MouseEvent.CLICK, endTurnButtonClicked);
        enabled = false;
        text = "end turn";
        board.addEventListener(MouseEvent.CLICK, mouseClicked);

        addEventListener(Event.REMOVED_FROM_STAGE, removedFromStage);
    }

    /**
     * End turn button is no longer being displayed; stop the timer.
     */
    protected function removedFromStage (event :Event) :void
    {
        if (afkTimer != null) {
            afkTimer.stop();
        }
    }

    /**
     * Handler for end turn button
     */
    protected function endTurnButtonClicked (event :MouseEvent) :void
    {
        if (!enabled) {
            return;
        }
        if (!_ctx.state.hasFocus()) {
            _ctx.log("You can't end the turn right now.");
            return;
        }

        endTurn();
    }

    /**
     * When the game ends, display that the player's turn is over, but do not
     * make them discard or send a signal to the server.
     */
    public function gameEnded () :void
    {
        afkTimer.stop();
        enabled = false;
        _ctx.eventHandler.dispatchEvent(new Event(EventHandler.PLAYER_TURN_ENDED));
        _ctx.board.player.jobEnabled = false;
    }

    /**
     * End the player's turn.
     */
    protected function endTurn () :void
    {
        afkTimer.stop();
        enabled = false;
        _ctx.eventHandler.dispatchEvent(new Event(EventHandler.PLAYER_TURN_ENDED));
        _ctx.board.player.jobEnabled = false;
        _ctx.board.player.hand.discardDown(discardDownComplete);
    }

    /**
     * Called after player has finished discarding down to the maximum hand size
     * and may now complete their turn.
     */
    protected function discardDownComplete () :void
    {
        _ctx.control.game.startNextTurn();
    }

    /**
     * Turn changed.  Draw 2 cards then trigger any START_TURN laws for this player's job.
     */
    protected function turnChanged (event :StateChangedEvent) :void
    {
        var turnHolder :Player = _ctx.board.getTurnHolder();
        if (turnHolder == null) {
            return;
        }
        if (turnHolder == _ctx.board.player) {
            startTurn();
        }
        else {
            _ctx.notice(turnHolder.playerName + "'s turn.");
        }
        updateDisplay();
    }

    /**
     * The player's turn just started.
     */
    protected function startTurn () :void
    {
        enabled = true;
        _ctx.notice("It's my turn.");
        _ctx.board.newLaw.enabled = true;
        _ctx.board.player.jobEnabled = true;
        _ctx.eventHandler.dispatchEvent(new Event(EventHandler.PLAYER_TURN_STARTED));
        _ctx.board.player.hand.drawCard(2);

        startAFKTimer();
    }

    /**
     * Handler for click somewhere on the board.  Restart the AFK timer if it's
     * the player's turn.
     */
    protected function mouseClicked (event :MouseEvent) :void
    {
        if (_ctx.board.isMyTurn()) {
            afkTurnsSkipped = 0;
            startAFKTimer();
        }
    }

    /**
     * Start or re-start the timer that waits for input then declares the
     * player AFK and boots them from the game.
     */
    protected function startAFKTimer () :void
    {
        if (afkTimer != null) {
           afkTimer.stop();
        }
        // 30000 = 30 seconds
        afkTimer = new Timer(30000, 1);
        afkTimer.addEventListener(TimerEvent.TIMER, firstAFKWarning);
        afkTimer.start();
    }

    /**
     * Called after 30 seconds of being afk.  Give a warning and reset the timer
     * to 30 seconds before showing the second warning.
     */
    protected function firstAFKWarning (event :TimerEvent) :void
    {
        // restart time if player is waiting for another player
        if (!_ctx.state.hasFocus(false)) {
            startAFKTimer();
            return;
        }
        _ctx.notice("Hello?  It's your turn and you haven't moved in 30 seconds'!");
        afkTimer.stop();
        // 20000 = 20 seconds
        afkTimer = new Timer(20000, 1);
        afkTimer.addEventListener(TimerEvent.TIMER, secondAFKWarning);
        afkTimer.start();
    }

    /**
     * Called after 50 seconds of being afk.  Give a warning and reset the timer
     * to 10 seconds to give them one more chance before they are booted.
     */
    protected function secondAFKWarning (event :TimerEvent) :void
    {
        // restart time if player is waiting for another player
        if (!_ctx.state.hasFocus(false)) {
            startAFKTimer();
            return;
        }
        _ctx.notice("Your turn will end automatically in 10 more seconds of inactivity.");
        _ctx.broadcast(_ctx.board.player.playerName + " may be away from their keyboard.");
        afkTimer.stop();
        // 10000 = 10 seconds
        afkTimer = new Timer(10000, 1);
        afkTimer.addEventListener(TimerEvent.TIMER, afkEndTurn);
        afkTimer.start();
    }

    /**
     * Kick the player out of the game because they are AFK
     */
    protected function afkEndTurn (event :TimerEvent) :void
    {
        // restart time if player is waiting for another player
        if (!_ctx.state.hasFocus(false)) {
            startAFKTimer();
            return;
        }

        afkTimer.stop();

        // already skipped 2 turns, 3rd time is a boot
        if (afkTurnsSkipped == 2) {
            _ctx.broadcast(_ctx.board.player.playerName + " booted after skipping 3 turns.");
            _ctx.kickPlayer();
        }
        else {
            afkTurnsSkipped++;
            _ctx.broadcast(_ctx.board.player.playerName + "'s turn skippped due to inactivity - strike " + afkTurnsSkipped + ".");
            endTurn();
        }
    }

    /** Timer for determining if a player is AFK */
    protected var afkTimer :Timer = null;

    /** After you skip 2 turns, on the third turn you're booted. */
    protected var afkTurnsSkipped :int = 0;

}
}