package lawsanddisorder {

import flash.events.Event;
import flash.events.MouseEvent;
import flash.display.DisplayObject;
import flash.geom.Point;
import flash.utils.Timer;
import flash.events.TimerEvent;

import com.whirled.game.MessageReceivedEvent;
import com.whirled.game.PropertyChangedEvent;
import com.threerings.util.HashMap;

import lawsanddisorder.component.*;

/**
 * Manages modes and ui logic, eg dragging cards & selecting opponents.
 */
public class State
{
    /**
     * Constructor - add event listeners and maybe get the board if it's setup
     */
    public function State(ctx :Context)
    {
        _ctx = ctx;
        mouseEventHandler = new MouseEventHandler(_ctx);
    }

    /**
     * Game is being unloaded; stop any timers.
     */
    public function unload () :void
    {
        if (modeReminderTimer!= null) {
            modeReminderTimer.stop();
        }
    }

    /**
     * Setup to wait for the player to select an opponent.  Listener function will be called
     * when an opponent is selected.  Fire a delayed reminder message after some time.
     */
    public function selectOpponent (listener :Function) :void
    {
        if (mode != MODE_DEFAULT) {
            _ctx.log("WTF mode is not default when selecting opponent.  Continuing...");
        }

        var message :String = "Please select an opponent.";
        //_ctx.notice(message);
        startModeReminder(message, selectRandomOpponent);
        modeListener = listener;
        mode = MODE_SELECT_OPPONENT;
    }

    /**
     * Setup to wait for the player to select numCards cards from targetPlayer's hand.  If
     * numCards is greater than the number of cards in the hand, wait to select all the cards in
     * the hand.
     */
    public function selectCards (numCards :int, listener :Function, targetPlayer :Player = null) :void
    {
        if (mode != MODE_DEFAULT) {
            _ctx.log("WTF mode is not default when selecting cards.  Continuing...");
        }

        // default to the current player
        if (targetPlayer == null) {
            targetPlayer = _ctx.board.player;
        }

        // target player has no cards to lose, return now.
        if (targetPlayer.hand.numCards == 0) {
            _ctx.notice("You had to select " + numCards + " card(s), but there are none to select.");
            selectedCards = new Array();
            selectedGoal = 0;
            listener();
            return;
        }

        // force player to select all cards in hand.
        if (numCards > targetPlayer.hand.numCards) {
            numCards = targetPlayer.hand.numCards;
        }

        var message :String;
        if (targetPlayer == _ctx.board.player) {
            message = "Please select " + numCards + " card(s) from your hand.";
        }
        else {
            message = "Please select " + numCards + " card(s) from " + targetPlayer.playerName + "'s hand.";
        }
        //_ctx.notice(message);
        startModeReminder(message, selectRandomCards);

        modeListener = listener;
        mode = MODE_SELECT_HAND_CARDS;
        selectedGoal = numCards;
        selectedCards = new Array();
        selectCardsTargetPlayer = targetPlayer;
    }

    /**
     * Setup to wait for the player to select a law.  Listener function will be called
     * when a law is selected.
     */
    public function selectLaw (listener :Function) :void
    {
        if (mode != MODE_DEFAULT) {
            _ctx.log("WTF mode is not default when selecting law.  Continuing...");
        }
        var message :String = "Please select a law.";
        //_ctx.notice(message);
        startModeReminder(message, cancelUsingPower);
        modeListener = listener;
        mode = MODE_SELECT_LAW;
    }

    /**
     * Setup and wait for the player to exchange a verb from their hand with one in a law.
     */
    public function exchangeVerb (listener :Function) :void
    {
        var message :String = "Please drag a red card from your hand drop it over a red card in a law";
        //_ctx.notice(message);
        startModeReminder(message, cancelUsingPower);
        modeListener = listener;
        mode = MODE_EXCHANGE_VERB;
    }

    /**
     * Setup and wait for the player to exchange a subject from their hand with one in a law.
     */
    public function exchangeSubject (listener :Function) :void
    {
        var message :String = "Please drag a blue card from your hand and drop it over a blue card in a law";
        //_ctx.notice(message);
        startModeReminder(message, cancelUsingPower);
        modeListener = listener;
        mode = MODE_EXCHANGE_SUBJECT;
    }

    /**
     * Setup and wait for the player to move a WHEN card from their hand to a law, or from
     * a law to their hand.
     */
    public function moveWhen (listener :Function) :void
    {
        var message :String = "Please drag a purple card from your hand onto a law, or select a purple card in a law to take";
        //_ctx.notice(message);
        startModeReminder(message, cancelUsingPower);
        modeListener = listener;
        mode = MODE_MOVE_WHEN;
    }

    /**
     * Enter this mode whenever laws start to trigger.
     */
    public function startEnactingLaws () :void
    {
        if (mode != MODE_DEFAULT) {
            _ctx.log("WTF mode was " + mode + " in startEnactingLaws.");
        }
        enactingLaws = true;
    }

    /**
     * Go back to default mode once laws are done being enacted
     */
    public function doneEnactingLaws () :void
    {
        if (mode != MODE_DEFAULT) {
            _ctx.log("WTF done triggering laws in mode " + mode);
        }
        enactingLaws = false;
        waitingForOpponent = null;
    }

    /**
     * Stop selecting cards
     * TODO clearing goal and listener helpful / necessary?
     */
    public function deselectCards () :void
    {
        if (selectedCards != null) {
           for (var i :int = 0; i < selectedCards.length; i++) {
               var card :Card = selectedCards[i];
               card.highlighted = false;
           }
        }
        selectedCards = null;
        selectedGoal = 0;
        selectCardsTargetPlayer = null;
        modeListener = null;
    }

    /**
     * Stop selecting opponent
     */
    public function deselectOpponent () :void
    {
        if (selectedOpponent != null) {
            selectedOpponent.highlighted = false;
        }
        selectedOpponent = null;
        modeListener = null;
    }

    /**
     * Stop selecting a law
     */
    public function deselectLaw () :void
    {
        selectedLaw = null;
        modeListener = null;
    }

    /**
     * Can the player interact with buttons, etc on their board?  If in default mode and
     * during the player's turn, return true.
     */
    public function hasFocus (displayNotices :Boolean = true) :Boolean
    {
       // if (_performingAction) {
         //   _ctx.notice("You can't interact with the board while performing an action.");
        //}
        //if (mode == MODE_DEFAULT && _ctx.control.game.isMyTurn() && !_performingAction) {
        if (mode == MODE_DEFAULT && _ctx.control.game.isMyTurn() && !enactingLaws) {
            return true;
        }
        if (enactingLaws && waitingForOpponent != null) {
            if (displayNotices) {
                _ctx.notice("Waiting for " + waitingForOpponent.playerName);
            }
        }
        else if (mode != MODE_DEFAULT) {
            if (displayNotices) {
               _ctx.notice("Busy performing another action.");
            }
        }
        else if (!_ctx.control.game.isMyTurn()) {
            if (displayNotices) {
               _ctx.notice("Not your turn.");
            }
        }
        else {
            if (displayNotices) {
               _ctx.notice("WTF The game is waiting for you.");
            }
        }
        return false;
    }

    /**
     * Reset the mode to MODE_DEFAULT and deselect all items.
     */
    public function cancelMode () :void
    {
        startModeReminder(null);
        mode = MODE_DEFAULT;
        deselectCards();
        deselectOpponent();
        deselectLaw();
    }

    /**
     * Finished getting user input; reset to default mode but keep selected cards/opponents/laws,
     * then call the listener function that is waiting for the mode to complete.
     */
    public function doneMode () :void
    {
        startModeReminder(null);
        mode = MODE_DEFAULT;
        if (modeListener != null) {
            modeListener();
        }
    }

    /**
     * Set a timer to display a reminder notice after every 10 seconds in the mode.  If message
     * is null, instead cancel the notice timer.  If a listener function is supplied, this will
     * be run in place of the 5th reminder message, after which the timer will be cancelled.
     */
    protected function startModeReminder (message :String, listener :Function = null, reminderNum :int = 1) :void
    {
        if (message == null) {
            if (modeReminderTimer != null) {
                modeReminderTimer.stop();
                modeReminderTimer = null;
            }
            return;
        }
        var reminderText :String;

        // first time through
        if (reminderNum == 1) {
            _ctx.notice(message);
            reminderText = "We're waiting for you.  ";
            if (modeReminderTimer != null) {
                _ctx.log("WTF mode reminder timer is not null - continuing");
                modeReminderTimer.stop();
            }
        }
        else if (reminderNum == 2) {
            reminderText = "Just take all day why doncha.  ";
        }
        else if (reminderNum == 3) {
            reminderText = "Come on, just eenie meenie minie moe.  ";
        }
        else if (reminderNum == 4 && listener != null) {
            reminderText = "We're going to play on without you!  ";
        }
        // stop the timer and run the "time's up" listener
        else if (reminderNum == 5 && listener != null) {
            startModeReminder(null);
            listener();
            return;
        }
        // display this indefinitely
        else {
            reminderText = "Helloooooo!  ";
        }
        modeReminderTimer = new Timer(10000, 1);
        modeReminderTimer.addEventListener(TimerEvent.TIMER,
            function () :void {
                _ctx.notice(reminderText + message);
                startModeReminder(message, listener, reminderNum+1)
            });
        modeReminderTimer.start();
    }

    /**
     * Player took too long to use their ability; cancel it.  Don't need
     * to cancel mode here; job.cancelUsePower() will deal with all that.
     *
     * TODO wow spaghetti - use events?
     */
    protected function cancelUsingPower () :void
    {
        _ctx.board.player.job.cancelUsePower();
        _ctx.board.usePowerButton.cancelUsingPower();
    }

    /**
     * Selects [selectedGoal] random cards from [selectCardsTargetPlayer]'s hand,
     * as if the player was doing it themselves.
     */
    protected function selectRandomCards () :void
    {
        _ctx.notice("Selecting " + selectedGoal + " random card(s) for you.");
        if (selectCardsTargetPlayer == null)  {
            _ctx.log("WTF select cards target player is null when selecting random cards.");
            return;
        }
        if (selectCardsTargetPlayer.hand.numCards < selectedGoal) {
            _ctx.log("WTF not enough cards in hand to select.");
            return;
        }
        if (selectedCards == null) {
            _ctx.log("WTF selected cards is null when selecting random cards");
            return;
        }

        selectedCards = selectCardsTargetPlayer.hand.getRandomCards(selectedGoal);
        doneMode();
    }

    /**
     * Selects a random opponent, as if the player was doing it themselves.
     */
    protected function selectRandomOpponent () :void
    {
        _ctx.notice("Selecting a random opponent for you.");
        selectedOpponent = _ctx.board.opponents.getRandomOpponent();
        doneMode();
    }

    /**
     * Handler for start turn event.  Begin the AFK timer
     */
    protected function turnStarted (event :Event) :void
    {
        mode = MODE_DEFAULT;
    }

    /** The card being actively dragged, for notification purposes */
    public var activeCard :Card = null;

    /** Array of currently selected cards */
    public var selectedCards :Array = null;

    /** Currently selected opponents */
    public var selectedOpponent :Opponent = null;

    /** Currently selected law */
    public var selectedLaw :Law = null;

    /** Which player are we waiting for during MODE_TRIGGER_LAWS */
    public var waitingForOpponent :Player = null;

    /** Timer for reminder notices when waiting for user input */
    protected var modeReminderTimer :Timer = null;

    /** Context */
    protected var _ctx :Context;

    /** Current wait mode - waiting for player to do what? */
    public var mode :int = 0;

    /** This function will be called when the mode is complete */
    protected var modeListener :Function = null;

    /** Waiting for player to select this many cards/opponents/etc */
    public var selectedGoal :int = 0;

    /** Player from whose hands the cards must be selected */
    public var selectCardsTargetPlayer :Player = null;

    /** Normal mode; not waiting on player for anything */
    public static const MODE_DEFAULT :int = 0;

    /** Waiting for player to select an opponent */
    public static const MODE_SELECT_OPPONENT :int = 1;

    /** Waiting for player to select cards from their hand */
    public static const MODE_SELECT_HAND_CARDS :int = 2;

    /** Waiting for player to select an exiting law */
    public static const MODE_SELECT_LAW :int = 3;

    /** Swapping a verb in hand with one in a law */
    public static const MODE_EXCHANGE_VERB :int = 4;

    /** Swapping a subject in hand with one in a law */
    public static const MODE_EXCHANGE_SUBJECT :int = 5;

    /** Moving a when card to or from a law */
    public static const MODE_MOVE_WHEN :int = 6;

    /**
     * Waiting for laws to finish triggering, which may require selecting cards,
     * or waiting for an opponent to select cards, etc.  Will be complete when Laws.triggeringWhen
     * has finished trigging all applicable laws, then focus may be returned to the player.
     */
     protected var enactingLaws :Boolean = false;

    /** Deals with card click events, card dragging, etc */
    public var mouseEventHandler :MouseEventHandler;
}
}