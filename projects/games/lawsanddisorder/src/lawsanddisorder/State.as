package lawsanddisorder {

import flash.events.MouseEvent;
import flash.display.DisplayObject;
import flash.geom.Point;
import flash.utils.Timer;
import flash.events.TimerEvent;

import com.threerings.ezgame.MessageReceivedEvent;
import com.threerings.ezgame.PropertyChangedEvent;
import com.threerings.util.HashMap;
import com.whirled.WhirledGameControl;
import lawsanddisorder.component.*;

/**
 * Manages modes and ui logic, eg dragging cards & selecting opponents.
 * TODO this class is overgrown; can some of it be moved?
 * TODO use MODE_MYTURN or MODE_NOTTURN instead of _ctx.control.game.isMyTurn()
 */
public class State
{
    /**
     * Constructor - add event listeners and maybe get the board if it's setup
     */
    public function State(ctx :Context)
    {
        _ctx = ctx;
    }
    
    /**
     * When a card is clicked
     */
    public function cardClick (event :MouseEvent) :void
    {
        var card :Card = Card(getParent(DisplayObject(event.target), Card));
    
        if (mode == MODE_SELECT_HAND_CARDS) {
            if (modeListener == null || selectedCards == null) {
                _ctx.log("WTF selected listener or cards is null when selecting card");
                return;
            }
            if (selectedCards.length >= selectedGoal) {
                _ctx.log("WTF already selected enough cards");
                return;
            }
            if (card.cardContainer != selectCardsTargetPlayer.hand) {
            	return;
            }
            
            if (selectedCards.indexOf(card) >= 0) {
	            var index :int = selectedCards.indexOf(card);
	            selectedCards.splice(index, 1);
	            card.highlighted = false;
	            return;
	        }
            selectedCards.push(card);
            card.highlighted = true;
            // # of selected cards goal reached; reset mode then call listener
            if (selectedCards.length == selectedGoal) {
            	doneMode();
            }
        }
        
        // clicking on a when card in a law to move it into the hand
        else if (mode == MODE_MOVE_WHEN) {
            if (!(card.cardContainer is Law)) {
                return;
            }
            if (card.group != Card.WHEN) {
                _ctx.notice("That card isn't a when card.");
                return;
            }
            
            // select card and law so listener function knows what happened
            selectedCards = new Array(card);
            selectedLaw = Law(card.cardContainer);
            card.cardContainer.removeCards(selectedCards);
            _ctx.board.player.hand.addCards(selectedCards);
            doneMode();
        }
    }
    
    /**
     * When a card is pressed, determine if we should start dragging it
     */
    public function cardMouseDown (event :MouseEvent) :void
    {
        var card :Card = Card(getParent(DisplayObject(event.target), Card));
        
        // you can only drag cards in your hand or in new law
        if (card.cardContainer != _ctx.board.player.hand && card.cardContainer != _ctx.board.newLaw) {
            return;
        }

        // by default you can drag cards in hand or newlaw around
        if (mode == MODE_DEFAULT) {
        	if (_performingAction) {
                return;
            }
        }
        // when exchanging a verb
        else if (mode == MODE_EXCHANGE_VERB) {
            if (card.group != Card.VERB) {
                _ctx.notice("That card is not a verb.");
                return;
            }
        }
        // when exchanging a subject
        else if (mode == MODE_EXCHANGE_SUBJECT) {
            if (card.group != Card.SUBJECT) {
                _ctx.notice("Card is not a subject.");
                return;
            }
        }
        // when dragging a when from your hand to a law
        else if (mode == MODE_MOVE_WHEN) {
            if (card.group != Card.WHEN) {
                _ctx.notice("Card is not a when card");
                return;
            }
        }
        // all other modes
        else {
        	return;
        }
        
        startDragging(card);
    }
    
    /**
     * Move a card to the board area and start dragging it.
     */
    private function startDragging (card :Card) :void
    {
        card.startDrag(true);
        card.addEventListener(MouseEvent.MOUSE_MOVE, draggingCard);
        activeCard = card;
        
        card.cardContainer.removeCards(new Array(card), false);
        card.x = _ctx.board.mouseX - 25;
        card.y = _ctx.board.mouseY - 10;
        _ctx.board.addChild(card);
    }
    
    /**
     * Called while dragging card.  Indicate if the card is being dragged over a legal drop zone.
     */
    protected function draggingCard (event :MouseEvent) :void
    {
        var card :Card = Card(event.target);
        
        // Shift cards around in hand and new law
        if (mode == MODE_DEFAULT) {
            var targetContainer :CardContainer = CardContainer(getParent(card.dropTarget, CardContainer));
            if (targetContainer == null) {
                return;
            }
            if (targetContainer != _ctx.board.player.hand && targetContainer != _ctx.board.newLaw) {
                return;
            }
            // don't rearrange new law if it isn't your turn
            if (!_ctx.control.game.isMyTurn() && targetContainer == _ctx.board.newLaw) {
            	return;
            }
            
            // arrange cards to make room for the new card
            var mousePosition :Point = new Point(event.stageX, event.stageY);
            targetContainer.arrangeCards(mousePosition);
            EventHandler.invokeLater(3, function () :void {targetContainer.arrangeCards();});
            return;
        }
        
        if (mode == MODE_EXCHANGE_SUBJECT || mode == MODE_EXCHANGE_VERB || mode == MODE_MOVE_WHEN) {
            var targetLaw :Law = Law(getParent(card.dropTarget, Law));
            
            if (targetLaw == null) {
                return;
            }
            if (mode == MODE_EXCHANGE_VERB && targetLaw.hasGivesTarget()) {
                return;
            }
            if (mode == MODE_MOVE_WHEN && targetLaw.when != -1) {
                return;
            }
            targetLaw.showCards = true;
        }
        
        if (mode == MODE_EXCHANGE_SUBJECT) {
            // get card this is hovering over
            var targetSubjectCard :Card = Card(getParent(card.dropTarget, Card));
            if (targetSubjectCard == null || !(targetSubjectCard.cardContainer is Law) 
                || targetSubjectCard.group != Card.SUBJECT) {
                return;
            }
            // if it's a verb/subject in a law, highlight it
            targetSubjectCard.highlighted = true;
            EventHandler.invokeLater(3, function () :void {targetSubjectCard.highlighted = false});
        }
        
        else if (mode == MODE_EXCHANGE_VERB) {
            // get card this is hovering over
            var targetVerbCard :Card = Card(getParent(card.dropTarget, Card));
            if (targetVerbCard == null || !(targetVerbCard.cardContainer is Law) 
                || targetVerbCard.group != Card.VERB) {
                return;
            }
            
            // is the verb a gives followed by a subject?
            var targetVerbLaw :Law = Law(targetVerbCard.cardContainer);
            if (targetVerbLaw.hasGivesTarget()) {
                return;
            }
            
            // if it's a verb/subject in a law, highlight it
            targetVerbCard.highlighted = true;
            EventHandler.invokeLater(3, function () :void {targetVerbCard.highlighted = false});
        }
        
        else if (mode == MODE_MOVE_WHEN) {
            // get the law this is hovering over
            var whenlessLaw :Law = Law(getParent(card.dropTarget, Law));
            if (whenlessLaw == null || whenlessLaw.when != -1) {
                return;
            }
            // if it's a valid law to drop on, highlight it
            whenlessLaw.highlighted = true;
            EventHandler.invokeLater(3, function () :void {whenlessLaw.highlighted = false});
        }
    }
    
    /**
     * When a card is released after dragging
     */
    public function cardMouseUp (event :MouseEvent) :void
    {
    	var card :Card = Card(getParent(DisplayObject(event.target), Card));
        if (!card.dragging) {
            return;
        }

        card.stopDrag();
        card.removeEventListener(MouseEvent.MOUSE_MOVE, draggingCard);
    
        // normally you can drag cards onto new laws, onto job, or rearrange in your hand.
        if (mode == MODE_DEFAULT) {
            
            if (_performingAction) {
            	_ctx.log("WTF dropping card while performing an action");
                returnCard(card);
                return;
            }
            
            var dropTarget :DisplayObject = DisplayObject(getParent(card.dropTarget, DisplayObject));
            if (dropTarget == null) {
                returnCard(card);
                return;
            }

            var mousePosition :Point = new Point(event.stageX, event.stageY);
            
            // drop card in a new law
            if (_ctx.board.newLaw.isTarget(dropTarget)) {
                if (!_ctx.control.game.isMyTurn()) {
                    _ctx.notice("It's not your turn.");
                    returnCard(card);
                    return;
                }
                if (!_ctx.board.newLaw.enabled) {
                    _ctx.notice("You've already made a law this turn.");
                    returnCard(card);
                    return;
                }
                _ctx.board.removeCard(card);
                var newLawCardIndex :int = _ctx.board.newLaw.getCardIndexByPoint(mousePosition);
                if (card.cardContainer == _ctx.board.newLaw) {
                	// moved card around inside newlaw, do not distribute
                	_ctx.board.newLaw.addCards(new Array(card), false, newLawCardIndex);
                }
                else {
                	// added card from hand to newlaw, do not distribute
                    card.cardContainer.removeCards(new Array(card), false);
                    _ctx.board.newLaw.addCards(new Array(card), false, newLawCardIndex);
                }
                return;
            }
            
            // drop card in hand
            else if (_ctx.board.player.hand.isTarget(dropTarget)) {
                _ctx.board.removeCard(card);
                var handCardIndex :int = _ctx.board.player.hand.getCardIndexByPoint(mousePosition);
                if (card.cardContainer == _ctx.board.player.hand) {
                	// moved card around inside hand, do not distribute
                    _ctx.board.player.hand.addCards(new Array(card), false, handCardIndex);
                }
                else {
                	// moved card from newlaw to hand, do not distribute
                    card.cardContainer.removeCards(new Array(card), false);
                    _ctx.board.player.hand.addCards(new Array(card), false, handCardIndex);
                }
                return;
            }
            
            // change job by dragging a subject onto the job area
            // TODO job gets disabled twice: inefficient
            // TODO can this logic be moved to job?
            else if (_ctx.board.player.job.isTarget(dropTarget)) {
                if (card.group == Card.SUBJECT) {
	                if (!_ctx.control.game.isMyTurn()) {
	                    _ctx.notice("It's not your turn.");
	                    returnCard(card);
	                    return;
	                }
                    if (!_ctx.board.player.jobEnabled) {
                        _ctx.notice("You already changed jobs once this turn.");
                        returnCard(card);
                        return;
                    }
                    if (card.type == _ctx.board.player.job.id) {
                    	_ctx.notice("You're already " + _ctx.board.player.job.name);
                    	returnCard(card);
                    	return;
                    }
                    _ctx.board.player.jobEnabled = false;
                    _ctx.board.removeCard(card);
                    // TODO distribute or remove discard pile
                    _ctx.board.deck.discardPile.addCards(new Array(card), false);
                    // now tell other players that card was removed from hand
                    _ctx.board.player.hand.setDistributedHandData();
                    var job :Job = _ctx.board.deck.getJob(card.type);
                    _ctx.board.deck.switchJobs(job, _ctx.board.player);
                    return;
                }
            }
        
            returnCard(card);
            return;
        }
        
        // switching verb/subject in hand with verb in a law
        else if (mode == MODE_EXCHANGE_VERB || mode == MODE_EXCHANGE_SUBJECT) {
            
            // get card this was dropped on.
            var targetCard :Card = Card(getParent(card.dropTarget, Card));
            
            if (targetCard == null || !(targetCard.cardContainer is Law) ||
                (mode == MODE_EXCHANGE_VERB && targetCard.group != Card.VERB) || 
                (mode == MODE_EXCHANGE_SUBJECT && targetCard.group != Card.SUBJECT)) {
                returnCard(card);
                return;
            }
                
            // is the verb a gives followed by a subject?
            var targetLaw :Law = Law(targetCard.cardContainer);
            if (mode == MODE_EXCHANGE_VERB && targetLaw.hasGivesTarget()) {
                _ctx.notice("You can't exchange with that gives card.");
                returnCard(card);
                return;
            }
            
            // get the law containing that card
            var targetIndex :int = targetLaw.indexOfCard(targetCard);
            if (targetIndex == -1) {
                _ctx.log("WTF target index is -1 when exchanging cards");
            }
            _ctx.board.removeCard(card);
            targetLaw.removeCards(new Array(targetCard));
            targetLaw.addCards(new Array(card), true, targetIndex);
            _ctx.board.player.hand.addCards(new Array(targetCard));
            
            // select card and law so listener function knows what happened
            selectedCards = new Array(targetCard);
            selectedLaw = targetLaw;
            doneMode();
        }
        
        else if (mode == MODE_MOVE_WHEN) {
            // get the law this was dropped on.
            var whenlessLaw :Law = Law(getParent(card.dropTarget, Law));
            
            if (whenlessLaw == null || whenlessLaw.when != -1) {
                _ctx.notice("That law already has a when card.");
                returnCard(card);
                return;
            }
            // add when to the end of the law
            _ctx.board.removeCard(card);
            whenlessLaw.addCards(new Array(card));
            
            // select law so listener function knows what happened
            selectedLaw = whenlessLaw;
            doneMode();
        }
    }
    
    /**
     * Return card to its card container when failing to drag it to a new object.  No need
     * to redistribute data as the card never really left.
     */
    protected function returnCard (card :Card) :void
    {
        if (card.cardContainer == null) {
            _ctx.log("WTF null parent when returning card - going to hand instead.");
            card.cardContainer = _ctx.board.player.hand;
        }
        _ctx.board.removeCard(card);
        card.cardContainer.addCards(new Array(card), false);
    }
    
    /**
     * Handles click events on opponents
     */
    public function opponentClick (event :MouseEvent) :void
    {
        if (mode == MODE_SELECT_OPPONENT) {
        	var opponent :Opponent = Opponent(getParent(DisplayObject(event.target), Opponent));
            if (modeListener == null) {
                _ctx.log("WTF selected listener is null when selecting opponent");
                return;
            }
            if (selectedOpponent != null) {
                _ctx.log("WTF opponent already selected");
                return;
            }
            // select opponent, reset mode then call listener
            opponent.highlighted = true;
            selectedOpponent = opponent;
            doneMode();
        }
    }
    
    /**
     * Handles click events on laws
     */
    public function lawClick (event :MouseEvent) :void
    {
        if (mode == MODE_SELECT_LAW) {
            if (modeListener == null) {
                _ctx.log("WTF selected listener is null when selecting law");
                return;
            }
            if (selectedLaw != null) {
                _ctx.log("WTF law already selected");
                return;
            }
            if (!(event.target is DisplayObject)) {
                _ctx.log("WTF target isn't a display object?");
                return;
            }
            var target :DisplayObject = DisplayObject(event.target);
            selectedLaw = Law(getParent(target, Law));
            if (selectedLaw == null) {
                _ctx.log("WTF target didn't have a parent Law?");
                return;
            }

            doneMode();
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
        _ctx.notice(message);
        setModeReminder(message);
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
            _ctx.notice("You had to select " + numCards + " cards, but there are none to select.");
            selectedCards = new Array();
            selectedGoal = 0;
            listener();
        }
        
        // force player to select all cards in hand.
        if (numCards > targetPlayer.hand.numCards) {
            numCards = targetPlayer.hand.numCards;
        }
        
        var message :String;
        if (targetPlayer == _ctx.board.player) {
            message = "Please select " + numCards + " cards from your hand.";
        }
        else {
        	message = "Please select " + numCards + " cards from " + targetPlayer.playerName + "'s hand.";
        }
        _ctx.notice(message);
        setModeReminder(message);
        
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
        _ctx.notice(message);
        setModeReminder(message);
        modeListener = listener;
        mode = MODE_SELECT_LAW;
    }
    
    /**
     * Setup and wait for the player to exchange a verb from their hand with one in a law.
     */
    public function exchangeVerb (listener :Function) :void
    {
        var message :String = "Please drag a verb from your hand drop it over a verb in a law"; 
        _ctx.notice(message);
        setModeReminder(message);
        modeListener = listener;
        mode = MODE_EXCHANGE_VERB;
    }
    
    /**
     * Setup and wait for the player to exchange a subject from their hand with one in a law.
     */
    public function exchangeSubject (listener :Function) :void
    {
        var message :String = "Please drag a subject from your hand and drop it over a subject in a law";
        _ctx.notice(message);
        setModeReminder(message);
        modeListener = listener;
        mode = MODE_EXCHANGE_SUBJECT;
    }
    
    /**
     * Setup and wait for the player to move a WHEN card from their hand to a law, or from
     * a law to their hand.
     */
    public function moveWhen (listener :Function) :void
    {
    	var message :String = "Please drag a when card from your hand to a law, or select a when card in a law to take"; 
        _ctx.notice(message);
        setModeReminder(message);
        modeListener = listener;
        mode = MODE_MOVE_WHEN;
    }
    
    /**
     * Stop selecting cards
     * TODO clearing goal and listener helful / necessary?
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
        if (selectedLaw != null) {
            selectedLaw.highlighted = false;
        }
        selectedLaw = null;
        modeListener = null;
    }
    
    /**
     * Returns the object if it's the right class type, or the first parent object that matches
     * the given class.  Stop if we hit the board then return null.
     */
    protected function getParent (object :DisplayObject, className :Class) :DisplayObject
    {
        var displayObject :DisplayObject = object;
        while (displayObject != _ctx.board) {
            try {
	            if (displayObject is className) {
	            	// toString() will throw a securityError on access denied
	            	// TODO find another way to do this
	            	displayObject.toString();
	                return displayObject;
	            }
	            if (displayObject == null) {
	                return null;
	            }
                displayObject = displayObject.parent;
            }
            // security errors may occur when moving out of the game bounds or too far up the tree
            catch (securityError :SecurityError) {
                return null;
            }
        }
        return null;
    }
    
    /**
     * Can the player interact with buttons, etc on their board?  If in default mode and
     * during the player's turn, return true.
     */
    public function get interactMode () :Boolean
    {
        if (_performingAction) {
            _ctx.notice("You can't interact with the board while performing an action.");
        }
        if (mode == MODE_DEFAULT && _ctx.control.game.isMyTurn() && !_performingAction) {
            return true;
        }
        return false;
    }
    
    /**
     * Just completed triggering laws after an action; return focus to the player.
     */
    public function set performingAction (value :Boolean) :void
    {
        if (!_performingAction && !value) {
            _ctx.log("WTF, finished triggering when but wasn't performing an action.");
        }
        if (_performingAction && value) {
            _ctx.log("WTF, started performing an action while still triggering.");
        }
        _performingAction = value;
    }
    
    /**
     * Reset the mode to MODE_DEFAULT and deselect all items.
     */
    public function cancelMode () :void
    {
    	setModeReminder(null);
        mode = MODE_DEFAULT;
        deselectCards();
        deselectOpponent();
        deselectLaw();
    }
    
    /**
     * Finished getting user input; reset to default mode but keep selected cards/opponents/laws,
     * then call the listener function that is waiting for the mode to complete.     */
    public function doneMode () :void
    {
        setModeReminder(null);
        mode = MODE_DEFAULT;
        if (modeListener != null) {
            modeListener();
        }
    }
    
    /**
     * Set a timer to display a reminder notice after every 10 seconds in the mode.  If message
     * is null, instead cancel the notice timer.
     * TODO add listener for 4th reminder, eg pick a random card or opponent     */
    protected function setModeReminder (message :String, reminderNum :int = 1) :void
    {
    	if (message == null && modeReminderTimer != null) {
    		modeReminderTimer.stop();
    		modeReminderTimer = null;
    		return;
    	}
    	var reminderText :String;
    	if (reminderNum == 1) {
    		reminderText = "We're waiting for you.  ";
    		if (modeReminderTimer != null) {
                _ctx.log("WTF mode reminder timer is not null - continuing");
            }
    	}
    	else if (reminderNum == 2) {
    		reminderText = "Come on, just eenie meenie minie moe.  ";
    	}
    	else if (reminderNum == 3) {
    		reminderText = "Just take all day why doncha!  ";
    	}
    	else {
    		reminderText = "Helloooooo!  ";
    	}
    	modeReminderTimer = new Timer(10000, 1);
        modeReminderTimer.addEventListener(TimerEvent.TIMER, 
            function () :void {_ctx.notice(reminderText + message); setModeReminder(message, reminderNum+1) });
        modeReminderTimer.start();
    }
    
    /** The card being actively dragged, for notification purposes */
    public var activeCard :Card = null;
    
    /** Array of currently selected cards 
     * TODO use getters */
    public var selectedCards :Array = null;
    
    /** Currently selected opponents */
    public var selectedOpponent :Opponent = null;
    
    /** Currently selected law */
    public var selectedLaw :Law = null;
    
    /** Timer for reminder notices when waiting for user input */
    protected var modeReminderTimer :Timer = null;
    
    /** Context */
    protected var _ctx :Context;
    
    /** Current wait mode - waiting for player to do what? */
    protected var mode :int = 0;
    
    /** This function will be called when the mode is complete */
    protected var modeListener :Function = null;
    
    /** Waiting for player to select this many cards/opponents/etc */
    protected var selectedGoal :int = 0;
    
    /** Player from whose hands the cards must be selected */
    protected var selectCardsTargetPlayer :Player = null;
    
    /** Normal mode; not waiting on player for anything */
    protected static const MODE_DEFAULT :int = 0;
    
    /** Waiting for player to select an opponent */
    protected static const MODE_SELECT_OPPONENT :int = 1;
    
    /** Waiting for player to select cards from their hand */
    protected static const MODE_SELECT_HAND_CARDS :int = 2;
    
    /** Waiting for player to select an exiting law */
    protected static const MODE_SELECT_LAW :int = 3;
    
    /** Swapping a verb in hand with one in a law */
    protected static const MODE_EXCHANGE_VERB :int = 4;
    
    /** Swapping a subject in hand with one in a law */
    protected static const MODE_EXCHANGE_SUBJECT :int = 5;
    
    /** Moving a when card to or from a law */
    protected static const MODE_MOVE_WHEN :int = 6;
    
    /** 
     * Special mode when waiting for an action to complete, which may require selecting cards,
     * or waiting for an opponent to select cards, etc.  Will be complete when Laws.triggeringWhen
     * has finished trigging all applicable laws, then focus may be returned to the player. 
     */
    protected var _performingAction :Boolean = false;
}
}