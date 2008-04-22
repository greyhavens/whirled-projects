package lawsanddisorder.component {

import flash.display.Sprite;
import flash.geom.Point;
import flash.text.TextField;
import flash.events.MouseEvent;
import flash.display.DisplayObject;

import lawsanddisorder.*;

/**
 * Area containing cards for a law
 */
public class Law extends CardContainer
{
    /**
     * Constructor
     */
    public function Law (ctx :Context, id :int)
    {
        _id = id;
        addEventListener(MouseEvent.CLICK, ctx.state.mouseEventHandler.lawClick);
        super(ctx);
    }
    
    /**
     * Draw the law area
     */
    override protected function initDisplay () :void
    {
    	var background :Sprite = new LAW_BACKGROUND();
    	addChild(background);
        
        var lawNum :TextField = Content.defaultTextField(1.0, "left");
        lawNum.text = "Law " + displayId + ":";
        lawNum.x = 5;
        lawNum.y = 8;
        addChild(lawNum);
    }
    
    /**
     * Rearrange law when cards are added or subtracted
     */
    override protected function updateDisplay () :void
    {
        var cardX :Number = 45;
        for (var i :int = 0; i < cards.length; i++) {          
            // update text version of the law
            var card :Card = cards[i];
            card.x = cardX;
            card.y = 8;
            cardX += card.width + 5;
        }
    }
    
    /**
     * Called whenever a law is enacted.  Parse through it and perform any actions needed of 
     * our player.  Assumes this is a valid law.  Ignores WHEN cards.  Only the subject player
     * performs the enacting.  If the player is called upon to select a card/opponent, this
     * function will be called again once the selection has been made.
     */
    public function enactLaw () :void
    {
        // get the player who gets/loses/gives
        var fromPlayer :Player = _ctx.board.deck.getPlayerByJobId(cards[0].type);
        if (fromPlayer == null) {
        	// the control player speaks for the absent job to tell everyone this law has been enacted
        	if (_ctx.control.game.amInControl()) {
                _ctx.sendMessage(Laws.ENACT_LAW_DONE, id);
        	}
            return;
        }
        
        // determine if our player has nothing to do here
        if (fromPlayer != _ctx.board.player) {
        	_ctx.state.waitingForOpponent = fromPlayer;
            return;
        }
        
        var toPlayer :Player = null;
        
        // get the verb
        var verb :int = cards[1].type;
        
        // get the player who recieves if verb is gives
        if (verb == Card.GIVES) {
            // SUBJECT VERB:GIVES SUBECT OBJECT
            if (cards[2].group == Card.SUBJECT) {
                toPlayer = _ctx.board.deck.getPlayerByJobId(cards[2].type);
            }
            // SUBJECT VERB:GIVES OBJECT (toPlayer must be selected)
            else if (toPlayer == null) {
                toPlayer = _ctx.state.selectedOpponent;
                if (toPlayer == null) {
                    // return here once an opponent has been selected
                    _ctx.broadcastOthers("(law " + displayId + " triggered): waiting for " + fromPlayer.playerName + " to pick an opponent.");
                    _ctx.state.selectOpponent(enactLaw);
                    return;
                }
            }
        }
        
        // get the object to get/lose/give and the amount of it
        var object :int;
        var amount :int;
        // SUBECT VERB OBJECT
        if (cards[2].group == Card.OBJECT) {
            object = cards[2].type;
            amount = cards[2].value;
        }
        // SUBJECT VERB:GIVES SUBECT OBJECT
        else {
            object = cards[3].type;
            amount = cards[3].value;
        }
        
        // perform the getting / losing / giving
        // this message will be broadcast to all players
        var message :String;
                
        // GETS
        if (verb == Card.GETS) {
            if (object == Card.MONIE) {
                fromPlayer.getMonies(amount);
                message = fromPlayer.playerName + " got " + amount + " monies";
            }
            else {
            	if (_ctx.board.deck.numCards < amount) {
            		message = fromPlayer.playerName + " would have got " + amount + " cards, but there was " + _ctx.board.deck.numCards + " left in the deck";
                    amount = _ctx.board.deck.numCards;
            	}
            	else {
            	    message = fromPlayer.playerName + " got " + amount + " cards";	
            	}
                fromPlayer.getCards(amount);
            }
        }
        
        // LOSES or GIVES
        else if (verb == Card.LOSES || verb == Card.GIVES) {
            if (object == Card.MONIE) {
                if (fromPlayer.monies < amount) {
                    amount = fromPlayer.monies;
                }
                fromPlayer.loseMonies(amount);
                
                // GIVES monies to somebody
                if (verb == Card.GIVES && toPlayer != null) {
                    toPlayer.getMonies(amount);
                    message = fromPlayer.playerName + " gave " + amount + " monies to " + toPlayer.playerName;
                }
                else {
                	message = fromPlayer.playerName + " lost " + amount + " monies";
                }
            }
            else {
                var selectedCards :Array = _ctx.state.selectedCards;
                if (selectedCards == null) {
                    // return to here once player has selected X cards
                    _ctx.broadcastOthers("(law " + displayId + " triggered): waiting for " + fromPlayer.playerName + " to pick card(s).");
                    _ctx.state.selectCards(amount, enactLaw);
                    return;
                }
                
                // GIVES cards to somebody
                if (verb == Card.GIVES && toPlayer != null) {
                    fromPlayer.giveCardsTo(selectedCards, toPlayer);
                	if (selectedCards.length < amount) {
                        message = fromPlayer.playerName + " would have given " + toPlayer.playerName + " " + amount + " cards, but had " + selectedCards.length + " to give";
                	}
                	else {
                		message = fromPlayer.playerName + " gave " + amount + " cards to " + toPlayer.playerName;
                	}

                }
                // LOSES / GIVES cards to nobody
                else {
                    fromPlayer.loseCards(selectedCards);
                	if (selectedCards.length < amount) {
                        message = fromPlayer.playerName + " would have lost " + amount + " cards, but had " + selectedCards.length + " to lose";
                    }
                    else {
                        message = fromPlayer.playerName + " lost " + amount + " cards";
                    }
                }
            }
        }
        
        _ctx.broadcast("(law " + displayId + " triggered): " + message + ".");
        
        _ctx.state.deselectCards();
        _ctx.state.deselectOpponent();
        _ctx.sendMessage(Laws.ENACT_LAW_DONE, id);
    }
    
    /**
     * If this law ends with a WHEN card, return the type (START_TURN, etc).  Else return -1.
     */
    public function get when () :int
    {
        if (cards == null || cards.length == 0) {
            _ctx.log("WTF cards empty when getting law.when");
            return -1;
        }
        var lastCard :Card = cards[cards.length-1];
        if (lastCard.group == Card.WHEN) {
            return lastCard.type;
        }
        return -1;
    }
    
    /**
     * Returns the type of the first card in the law (eg JUDGE or BANKER).
     */
    public function get subject () :int
    {
        if (cards == null || cards.length == 0) {
            _ctx.log("WTF cards empty when getting law.subject");
            return -1;
        }
        var firstCard :Card = cards[0];
        return firstCard.type;
    }
    
    /**
     * Called when the law contents change; tell the server about the new card set
     */
    override protected function setDistributedData () :void
    { 	
        _ctx.eventHandler.setData(Laws.LAWS_DATA, getSerializedCards(), _id, true);
    }
    
    /**
     * Public function to allow setting distributed hand data
     * TODO make setDistributedData public or find another solution
     */
    public function setDistributedLawData () :void
    {
        setDistributedData();
    }
        
    /**
     * First child is the background, second is the law # textfield     */
    override protected function getStartingChildIndex () :int
    {
    	return 2;
    }
    
    /**
     * Is this law of the form SUBJECT GIVES TARGET OBJECT {WHEN}+?
     * Assumes a valid law format.
     * TODO don't calculate this every time for finished laws; calculate it once and properly
     */
    public function hasGivesTarget () :Boolean
    {
        if (cards == null || cards.length == 0) {
            _ctx.log("WTF no cards duing law.hasGivesTarget");
            return false;
        }
        if (cards[1].type == Card.GIVES && cards[2].group == Card.SUBJECT) {
            return true;
        }
        return false;
    }
    
    /** Fetch the index of the law in the list of laws */
    public function get id () :int {
        return _id;
    }
    
    /**
     * ID starts at zero, but when displaying we start from 1     */
    public function get displayId () :int {
        return (_id + 1);
    }
    
    /** Return the text version of this law */
    public function get text () :String {
    	return _text;
    }
    
    /** For testing, return this law as a string */
    override public function toString () :String {
    	return "Law " + _id + " [" + _text + "]";
    }
    
    /**
     * Is the law displaying that it is selected?
     */
    public function get highlighted () :Boolean {
        return _highlighted;
    }
    
    /**
     * Change whether the law appears selected, by highlighting
     * all the cards in it.
     */
    public function set highlighted (value :Boolean) :void {
        _highlighted = value;
        for each (var card :Card in cards) {
            card.highlighted = _highlighted;
        }
    }
    
    /** Is the law highlighted? */
    protected var _highlighted :Boolean = false;
    
    /** Text version of the law */
    protected var _text :String
    
    /** Index of this law in the list of laws */
    private var _id :int;
    
    /** Contains the compacted text version of the law */
    protected var lawText :Sprite
    
    /** Background image for the entire board */
    [Embed(source="../../../rsrc/components.swf#law")]
    protected static const LAW_BACKGROUND :Class;
}
}