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
 * Manages mouse events on interface objects such as cards and laws.
 * Controls card dragging and performs various actions according to the
 * current state.
 */
public class MouseEventHandler
{
    /**
     * Constructor - add event listeners and maybe get the board if it's setup
     */
    public function MouseEventHandler(ctx :Context)
    {
        _ctx = ctx;
    }
    
    /**
     * When a card is clicked
     */
    public function cardClick (event :MouseEvent) :void
    {
        var card :Card = Card(getParent(DisplayObject(event.target), Card));
    
        if (mode == State.MODE_SELECT_HAND_CARDS) {
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
        else if (mode == State.MODE_MOVE_WHEN) {
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
        if (mode == State.MODE_DEFAULT) {
        	// you can move any card in your hand during default mode
        }
        // when exchanging a verb
        else if (mode == State.MODE_EXCHANGE_VERB) {
            if (card.group != Card.VERB) {
                _ctx.notice("That card is not a verb.");
                return;
            }
        }
        // when exchanging a subject
        else if (mode == State.MODE_EXCHANGE_SUBJECT) {
            if (card.group != Card.SUBJECT) {
                _ctx.notice("Card is not a subject.");
                return;
            }
        }
        // when dragging a when from your hand to a law
        else if (mode == State.MODE_MOVE_WHEN) {
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
        card.startDrag(false);
        card.dragging = true;
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
        // get the card being dragged
        var card :Card = Card(getParent(DisplayObject(event.target), Card));
        
        // Shift cards around in hand and new law
        if (mode == State.MODE_DEFAULT) {
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
        
        /*
        if (mode == State.MODE_EXCHANGE_SUBJECT || mode == State.MODE_EXCHANGE_VERB || mode == State.MODE_MOVE_WHEN) {
            var targetLaw :Law = Law(getParent(card.dropTarget, Law));
            
            if (targetLaw == null) {
                return;
            }
            if (mode == State.MODE_EXCHANGE_VERB && targetLaw.hasGivesTarget()) {
                return;
            }
            if (mode == State.MODE_MOVE_WHEN && targetLaw.when != -1) {
                return;
            }
        }
        */
        
        if (mode == State.MODE_EXCHANGE_SUBJECT) {
            // get card this is hovering over
            var targetSubjectCard :Card = Card(getParent(card.dropTarget, Card));
            if (targetSubjectCard == null || !(targetSubjectCard.cardContainer is Law) 
                || targetSubjectCard.group != Card.SUBJECT) {
                setMouseOverCard(null);
                return;
            }
            // if it's a verb/subject in a law, highlight it
            setMouseOverCard(targetSubjectCard);
        }
        
        else if (mode == State.MODE_EXCHANGE_VERB) {
            // get card this is hovering over
            var targetVerbCard :Card = Card(getParent(card.dropTarget, Card));
            if (targetVerbCard == null || !(targetVerbCard.cardContainer is Law) 
                || targetVerbCard.group != Card.VERB) {
                setMouseOverCard(null);
                return;
            }
            // can't switch a gives with a target to a loses/gets
            var targetLaw :Law = Law(getParent(card.dropTarget, Law));
            if (targetLaw.hasGivesTarget()) {
                setMouseOverCard(null);
                return;
            }
            
            // if it's a verb/subject in a law, highlight it
            setMouseOverCard(targetVerbCard);
        }
        
        else if (mode == State.MODE_MOVE_WHEN) {
            // get the law this is hovering over
            var whenlessLaw :Law = Law(getParent(card.dropTarget, Law));
            if (whenlessLaw == null || whenlessLaw.when != -1) {
                setMouseOverLaw(null);
                return;
            }
            // if it's a valid law to drop on, highlight it
            setMouseOverLaw(whenlessLaw);
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
        card.dragging = false;
        card.removeEventListener(MouseEvent.MOUSE_MOVE, draggingCard);
    
        // normally you can drag cards onto new laws, onto job, or rearrange in your hand.
        if (mode == State.MODE_DEFAULT) {            
            var dropTarget :DisplayObject = DisplayObject(getParent(card.dropTarget, DisplayObject));
            if (dropTarget == null) {
                returnCard(card);
                return;
            }
            var mousePosition :Point = new Point(event.stageX, event.stageY);
            
            // drop card in hand
            // TODO dropTarget doesn't work with hidden hitArea, but hitTestPoint does - why?
            if (_ctx.board.player.hand.hitTestPoint(event.stageX, event.stageY)) {
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
            
            // drop card in a new law
            if (_ctx.board.newLaw.isTarget(dropTarget)) {
                if (!_ctx.board.contains(_ctx.board.newLaw)) {
                    return;
                }
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
            
            // change job by dragging a subject onto the job area
            // TODO job gets disabled twice: inefficient
            // TODO can this logic be moved to job?
            else if (_ctx.board.player.job.isTarget(dropTarget)) {
                if (card.group == Card.SUBJECT) {
                    if (!_ctx.state.hasFocus()) {
                    	_ctx.notice("You can change jobs right now.");
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
        else if (mode == State.MODE_EXCHANGE_VERB || mode == State.MODE_EXCHANGE_SUBJECT) {
            
            // get card this was dropped on.
            var targetCard :Card = Card(getParent(card.dropTarget, Card));
            
            // stop highlighting the card we're over
            setMouseOverCard(null);
            
            if (targetCard == null || !(targetCard.cardContainer is Law) ||
                (mode == State.MODE_EXCHANGE_VERB && targetCard.group != Card.VERB) || 
                (mode == State.MODE_EXCHANGE_SUBJECT && targetCard.group != Card.SUBJECT)) {
                returnCard(card);
                return;
            }
                
            // is the verb a gives followed by a subject?
            var targetLaw :Law = Law(targetCard.cardContainer);
            if (mode == State.MODE_EXCHANGE_VERB && targetLaw.hasGivesTarget()) {
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
            targetLaw.removeCards(new Array(targetCard), false);
            targetLaw.addCards(new Array(card), true, targetIndex);
            _ctx.board.player.hand.addCards(new Array(targetCard));
            
            // select card and law so listener function knows what happened
            selectedCards = new Array(targetCard);
            selectedLaw = targetLaw;
            doneMode();
        }
        
        else if (mode == State.MODE_MOVE_WHEN) {
            
            // stop highlighting the law we're over
            setMouseOverLaw(null);
            
            // get the law this was dropped on.
            var whenlessLaw :Law = Law(getParent(card.dropTarget, Law));
            
            if (whenlessLaw == null || whenlessLaw.when != -1) {
                _ctx.notice("That law already has a when card.");
                returnCard(card);
                return;
            }
            // add when to the end of the law
            _ctx.board.removeCard(card);
            card.cardContainer.removeCards(new Array(card));
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
        if (mode == State.MODE_SELECT_OPPONENT) {
            var opponent :Opponent = Opponent(getParent(DisplayObject(event.target), Opponent));
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
        if (mode == State.MODE_SELECT_LAW) {
            var target :DisplayObject = DisplayObject(event.target);
            selectedLaw = Law(getParent(target, Law));
            doneMode();
        }
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
     * Unhighlight the card we're currently over, and highlight the new one.  Also if
     * we are dragging a card, highlight it to show that this is a good place to drop it.
     */
    protected function setMouseOverCard (card :Card) :void
    {
        if (mouseOverCard == card) {
            return;
        }
        if (mouseOverCard != null) {
            mouseOverCard.highlighted = false;
        }
        mouseOverCard = card;
        if (card != null) {
            card.highlighted = true;
            if (activeCard != null) {
                activeCard.highlighted = true;
            }
        }
        else {
            if (activeCard != null) {
                activeCard.highlighted = false;
            }           
        }
    }
    
    
    
    /**
     * Unhighlight the law we're currently over, and highlight the new one.  Also if
     * we are dragging a card, highlight it to show that this is a good place to drop it.
     * TODO combine law and card? Interface highlightable?
     */
    protected function setMouseOverLaw (law :Law) :void
    {
        if (mouseOverLaw == law) {
            return;
        }
        if (mouseOverLaw != null) {
            mouseOverLaw.highlighted = false;
        }
        mouseOverLaw = law;
        if (law != null) {
            law.highlighted = true;
            if (activeCard != null) {
                activeCard.highlighted = true;
            }
        }
        else {
            if (activeCard != null) {
                activeCard.highlighted = false;
            }           
        }
    }
    
    
    /** Card that is temporarily highlighted because the mouse is over it */
    public var mouseOverCard :Card = null;
    
    /** Law that is temporarily highlighted because the mouse is over it */
    public var mouseOverLaw :Law = null;
    
    /** Context */
    protected var _ctx :Context;
    
    
    protected function get state () :State
    {
    	return _ctx.state;
    }
    
    /**
     * TODO fix these references     */
    protected function get mode () :int
    {
    	return _ctx.state.mode;
    }
    protected function set selectedCards (cards :Array) :void
    {
        _ctx.state.selectedCards = cards;
    }
    protected function get selectedCards () :Array
    {
        return _ctx.state.selectedCards;
    }
    protected function set selectedOpponent (opponent :Opponent) :void
    {
        _ctx.state.selectedOpponent = opponent;
    }
    protected function set selectedLaw (law :Law) :void
    {
        _ctx.state.selectedLaw = law;
    }
    
    
    protected function get selectedGoal () :int
    {
        return _ctx.state.selectedGoal;
    }
    protected function get selectCardsTargetPlayer () :Player
    {
        return _ctx.state.selectCardsTargetPlayer;
    }
    
    protected function doneMode () :void
    {
    	_ctx.state.doneMode();
    }
    protected function get activeCard () :Card
    {
        return _ctx.state.activeCard;
    }
    protected function set activeCard (card :Card) :void
    {
        _ctx.state.activeCard = card;
    }
    
}
}