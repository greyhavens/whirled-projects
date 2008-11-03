package lawsanddisorder.component {

import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.text.TextField;
import flash.utils.Timer;

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
        _ctx.eventHandler.addMessageListener(EventHandler.TURN_CHANGED, turnChanged);
        addEventListener(MouseEvent.CLICK, endTurnButtonClicked);
        enabled = false;
        text = "end turn";
        board.addEventListener(MouseEvent.CLICK, mouseClicked);

        addEventListener(Event.REMOVED_FROM_STAGE, removedFromStage);
    }

    /**
     * Called by an ai player when they finish their turn.
     */
    public function aiTurnEnded () :void
    {
        discardDownComplete();
    }

    /**
     * When the game ends, display that the player's turn is over, but do not make them discard
     * or send a signal to the server.
     */
    public function gameEnded () :void
    {
        stopAFKTimer();
        enabled = false;
        _ctx.eventHandler.dispatchEvent(new Event(EventHandler.MY_TURN_ENDED));
        _ctx.player.jobEnabled = false;
    }

    /**
     * The last card in the deck was just drawn, this is now the last turn of the game.
     */
    public function lastTurn () :void
    {
        _ctx.broadcast("The deck is empty - the game will end when " 
            + _ctx.board.players.turnHolder.name + "'s turn is over.", null, true);
        isLastTurn = true;
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
            enabled = false;
            // end the turn as soon as the player has focus again
            _ctx.eventHandler.addEventListener(State.FOCUS_GAINED, endTurn);
            return;
        }

        endTurn();
    }
    
    /**
     * End the player's turn, possibly triggered when focus was gained.
     */
    protected function endTurn (event :Event = null, autoDiscard :Boolean = false) :void
    {
        _ctx.eventHandler.removeEventListener(State.FOCUS_GAINED, endTurn);
        stopAFKTimer();
        enabled = false;
        _ctx.eventHandler.dispatchEvent(new Event(EventHandler.MY_TURN_ENDED));
        _ctx.player.jobEnabled = false;
        
        if (isLastTurn) {
            // skip to the punch
            discardDownComplete();
        } else {
            _ctx.player.hand.discardDown(discardDownComplete, autoDiscard);
        }
    }

    /**
     * Called after player has finished discarding down to the maximum hand size and may now
     * complete their turn.  This is the last thing to be run before the next turn starts, and
     * this is where the game will end.
     */
    protected function discardDownComplete () :void
    {
        // If this was the last turn of the game, end the game now.
        if (isLastTurn) {
            isLastTurn = false;
            _ctx.eventHandler.endGame();
            return;
        }
        _ctx.sendMessage(EventHandler.TURN_CHANGED);
    }
    
    /**
     * Someone ended the turn with a TURN_CHANGED message event.  Next up may be a real 
     * player or an AI.
     */
    protected function turnChanged (event :Event) :void
    {
        //_ctx.log("EndTurnButton.turnChanged");
        // during rematches this is sent by the server before GAME_STARTED; ignore it
        if (!_ctx.gameStarted) {
            return;
        }
        
        _ctx.board.players.advanceTurnHolder();

        if (_ctx.board.players.turnHolder == _ctx.player) {
            startTurn();
            
        } else {
            _ctx.notice("\nIt's " + _ctx.board.players.turnHolder.name + "'s turn.");
            // controller plays the AI turns
            if (_ctx.board.players.turnHolder as AIPlayer && _ctx.player.isController) {
                AIPlayer(_ctx.board.players.turnHolder).startTurn();
            }
        }
        updateDisplay();
        
        // dispatch the TURN_CHANGED event to other components
        _ctx.eventHandler.dispatchEvent(new Event(EventHandler.TURN_CHANGED));
    }

    /**
     * The player's turn just started.  Draw 2 cards then trigger any START_TURN laws for this 
     * player's job.
     */
    protected function startTurn () :void
    {
        //_ctx.log("EndTurnButton.startTurn");
        // after 3 afk turns, skip the remainder of the player's turns
        if (booted) {
            _ctx.broadcast("Skipping " + _ctx.player.playerName + "'s turn after 3 strikes.");
            endTurn(null, true);
            return;
        }
        
        enabled = true;
        _ctx.notice("\nIt's your turn.");
        _ctx.board.newLaw.enabled = true;
        _ctx.player.jobEnabled = true;
        _ctx.eventHandler.dispatchEvent(new Event(EventHandler.MY_TURN_STARTED));
        _ctx.player.hand.drawCard(Deck.CARDS_AT_START_OF_TURN);

        startAFKTimer();
    }

    /**
     * Handler for click somewhere on the board.  Restart the AFK timer if it's the player's
     * turn and there is another human player in the game.
     */
    protected function mouseClicked (event :MouseEvent) :void
    {
        if (_ctx.board.players.isMyTurn()) {
            afkTurnsSkipped = 0;
            startAFKTimer();
            if (displayingAFKNotice) {
                _ctx.notice("");
                displayingAFKNotice = false;
            }
        }
    }

    /**
     * Start or re-start the timer that waits for input then declares the player AFK and boots
     * them from the game.
     */
    protected function startAFKTimer () :void
    {
        if (_ctx.board.players.numHumanPlayers == 1) {
            return;
        }
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
        stopAFKTimer();
        _ctx.notice("Hello?  It's your turn and you haven't moved in 30 seconds'!");
        displayingAFKNotice = true;
        // 20000 = 20 seconds
        afkTimer = new Timer(20000, 1);
        afkTimer.addEventListener(TimerEvent.TIMER, secondAFKWarning);
        afkTimer.start();
    }

    /**
     * Called after 50 seconds of being afk.  Give a warning and reset the timer to 10 seconds
     * to give them one more chance before they are booted.
     */
    protected function secondAFKWarning (event :TimerEvent) :void
    {
        // restart time if player is waiting for another player
        if (!_ctx.state.hasFocus(false)) {
            startAFKTimer();
            return;
        }
        stopAFKTimer();
        _ctx.notice("If you don't move in 10 seconds your turn will end.");
        displayingAFKNotice = true;
        _ctx.broadcast(_ctx.player.name + " may be away from their keyboard.");
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

        stopAFKTimer();

        // already skipped 2 turns, 3rd time is a boot
        if (afkTurnsSkipped == 2) {
            _ctx.broadcast("Three strikes and " + _ctx.player.playerName + 
                " is out, and will skip the rest of their turns.");
            booted = true;
            endTurn(null, true);
            
        } else {
            afkTurnsSkipped++;
            _ctx.broadcast(_ctx.player.name + 
                "'s turn skippped due to inactivity - strike " + afkTurnsSkipped + ".");
            endTurn(null, true);
        }
    }

    /**
     * Stop the timer.
     */
    protected function stopAFKTimer () :void
    {
        if (_ctx.board.players.numHumanPlayers == 1) {
            return;
        }
        if (afkTimer != null) {
            afkTimer.stop();
            if (displayingAFKNotice) {
                _ctx.notice("");
                displayingAFKNotice = false;
            }
        }
    }
    
    /** If this player has been booted, skip their turns. */
    public var booted :Boolean = false;
    
    /** Timer for determining if a player is AFK */
    protected var afkTimer :Timer = null;

    /** After you skip 2 turns, on the third turn you're booted. */
    protected var afkTurnsSkipped :int = 0;
    
    /** To remember to clear the notice if player moves */
    protected var displayingAFKNotice :Boolean = false;
    
    /** True if this player or an AI they control is taking the last turn of the game */
    protected var isLastTurn :Boolean = false;
}
}
