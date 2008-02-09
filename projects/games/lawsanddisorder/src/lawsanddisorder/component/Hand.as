package lawsanddisorder.component {

import flash.display.Sprite;
import flash.geom.Point;
import flash.text.TextField;
import flash.events.MouseEvent;
import lawsanddisorder.Context;
import com.threerings.ezgame.PropertyChangedEvent;

/**
 * Container for a player's cards.
 */
public class Hand extends CardContainer
{
    /** The name of the hand data distributed value. */
    public static const HAND_DATA :String = "handData";
    
    /**
     * Constructor
     */
    public function Hand (ctx :Context, player :Player)
    {
        this.player = player;
        ctx.eventHandler.addPropertyListener(HAND_DATA, handsChanged);
        super(ctx);
    }
    
    /**
     * Called by first user during game start.  Draw a fresh hand.
     */
    public function setup () :void
    {
    	var cardArray :Array = _ctx.board.deck.drawStartingHand(DEFAULT_HAND_SIZE);
        addCards(cardArray);
    }
    
    /**
     * Draw the hand area and cards
     */
    override protected function initDisplay () :void
    {
        // background doesn't recieve onclick, etc mouse messages
        mouseEnabled = false;
        graphics.beginFill(0x55FFEE);
        graphics.drawRect(-10, 0, 680, 80);
        graphics.endFill();
        
        removeChild(title);
        
        // TODO use a hitmap so graphics can be one big image in Board
        //var hitmap :Sprite = new Sprite();
        // draw the hand bg
        //graphics.clear();
        //hitmap.graphics.beginFill(0x55FFEE);
        //hitmap.graphics.drawRect(-10, 0, 680, 80);
        //hitmap.graphics.endFill();
        //this.hitArea = hitmap;
    }
    
    /**
     * Rearrange hand when cards are added or subtracted
     */
    override protected function updateDisplay () :void
    {
    	arrangeCards();
    }
    
    /*
     * TODO fix issue with this and use it instead of discard down?
     *      Issue is this function doesn't block other players from doing things that interfere
     * Override addCards to force discard first if too many cards in hand     *
    override public function addCards (cardArray :Array, distribute :Boolean = true, insertIndex :int = -1) :void
    {
    	var discardNum :int = cards.length + cardArray.length - MAX_HAND_SIZE;
    	if (discardNum > 0) {
            _ctx.notice("You may not have more than " + MAX_HAND_SIZE + " cards.  Please choose and discard " + discardNum);
            //discardDownListener = listener;
            var cardsSelectedListener :Function = function () :void {
                player.loseCards(_ctx.state.selectedCards);
                _ctx.state.deselectCards();
                addCards(cardArray, distribute, insertIndex);
            };
            _ctx.state.selectCards(discardNum, cardsSelectedListener);
    	}
    	else {
    		_ctx.log("yer cards are fine");
    	   super.addCards(cardArray, distribute, insertIndex);
    	}
    }
    */
    
    /**
     * Draw a card (or X cards, if numCards is provided) from the deck.
     */
    public function drawCard (numCards :int = 1) :void
    {
        var cardArray :Array = new Array();
        for (var i :int = 1; i <= numCards; i++) {
            var card :Card = _ctx.board.deck.drawCard();
            if (card == null) {
            	// no more cards in the deck!
                break;
            }
            cardArray.push(card);
        }
        addCards(cardArray);
        
        // if the deck is ever empty after drawing from it, game ends
        // TODO move this to deck and go one more round
        if (_ctx.board.deck.numCards == 0) {
        	_ctx.eventHandler.endGame();
        }
    }
    
    /**
     * Called whenever distributed card data needs updating
     */
    override protected function setDistributedData () :void
    {
        _ctx.eventHandler.setData(HAND_DATA, getSerializedCards(), player.id);
    }
    
    /**
     * Public function to allow setting distributed hand data
     * TODO make setDistributedData public or find another solution     */
    public function setDistributedHandData () :void
    {
    	setDistributedData();
    }
    
    /**
     * Returns the index of the card at a given global point, or -1 for none.
     */
    override public function getCardIndexByPoint (point :Point) :int
    {
        var localPoint :Point = globalToLocal(point);
        // cards are spaced CARD_SPACING_X apart starting at 0
        var index :int = Math.floor(localPoint.x / CARD_SPACING_X);
        if (index < 0) {
        	index = 0;
        }
        if (index > cards.length) {
        	index = cards.length;
        }
        return index;
    }
    
    /**
     * Shift cards out of the way as another card is being dragged over them.
     */
    override public function arrangeCards (point :Point = null) :void
    {
    	var i :int;
    	var card :Card;
    	
    	// adjust the spacing depeding on the number of cards
    	var cardSpacingX :int = CARD_SPACING_X;
    	if (cards.length > MAX_HAND_SIZE) {
    		cardSpacingX = (MAX_HAND_SIZE * CARD_SPACING_X) / cards.length;
    	}
    	
    	// if no point is supplied, arrange as normal.
    	if (point == null) {
	        for (i = 0; i < cards.length; i++) {
	            card = cards[i];
	            card.x = i * cardSpacingX;
	            card.y = 10;
	        }
	        return;
    	}
    	
        // localize the point to our coordinate map
        var localPoint :Point = globalToLocal(point);
        
        // position the cards horizontally
        for (i = 0; i < cards.length; i++) {
            card = cards[i];
            // if the card would overlap the point or be to its right, shift it right
            if ((i+1) * cardSpacingX > localPoint.x) {
                card.x = (i+1) * cardSpacingX;
            }
            else {
                card.x = i * cardSpacingX;
            }
        }
    }
    
    /**
     * Handler for changes to distributed hand data.  If it's data for this hand,
     * update the hand display.
     */
    protected function handsChanged (event :PropertyChangedEvent) :void
    {
        if (event.index == player.id) {
            setSerializedCards(event.newValue);
        }
    }
    
    /**
     * If player has more than the maximum allowed number of cards in their hand, force them to
     * select and discard the excess number of cards.  When finished, call the listener function.
     */
    public function discardDown (listener :Function) :void
    {
    	if (cards.length <= MAX_HAND_SIZE) {
    		listener();
    		return;
    	}
    	_ctx.notice("You have too many cards... please discard down to " + MAX_HAND_SIZE);
    	discardDownListener = listener;
    	_ctx.state.selectCards(cards.length - MAX_HAND_SIZE, discardDownCardsSelected);
    }
    
    /**
     * Called when the player has selected cards to be discarded.
     */
    protected function discardDownCardsSelected () :void
    {
    	player.loseCards(_ctx.state.selectedCards);
    	_ctx.state.deselectCards();
    	discardDownListener();
    }
    
    /** Record the listener function while selecting cards to discard. */
    protected var discardDownListener :Function;
    
    /** Player owning this hand */
    protected var player :Player;
    
    /** Player must go down to this many cards at end of turn */
    protected var MAX_HAND_SIZE :int = 11;
    
    /** Draw this number of cards at the start of the game */
    protected var DEFAULT_HAND_SIZE :int = 7;
}
}