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
     * TODO Use splice instead of a for loop to grab top X cards from deck
     */
    public function setup () :void
    {
        var cardArray :Array = new Array();
        for (var i :int = 1; i <= DEFAULT_HAND_SIZE; i++) {
            var card :Card = _ctx.board.deck.drawCard();
            if (card == null) {
            	_ctx.log("WTF couldn't draw cards from deck when creating hand.");
            }
            cardArray.push(card);
        }
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
        return index;
    }
    
    /**
     * Shift cards out of the way as another card is being dragged over them.
     * TODO what if there are too many cards to fit?
     */
    override public function arrangeCards (point :Point = null) :void
    {
    	var i :int;
    	var card :Card;
    	
    	// if no point is supplied, arrange as normal.
    	if (point == null) {
	        for (i = 0; i < cards.length; i++) {
	            card = cards[i];
	            card.x = i * CARD_SPACING_X;
	            card.y = 10;
	        }
	        return;
    	}
    	
        // localize the point to our coordinate map
        var localPoint :Point = globalToLocal(point);
        
        // position the cards horizontally and display each
        for (i = 0; i < cards.length; i++) {
            card = cards[i];
            // if the card would overlap the point or be to its right, shift it right
            if ((i+1) * CARD_SPACING_X > localPoint.x) {
                card.x = (i+1) * CARD_SPACING_X;
            }
            else {
                card.x = i * CARD_SPACING_X;
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
    protected var MAX_HAND_SIZE :int = 12;
    
    /** Draw this number of cards at the start of the game */
    protected var DEFAULT_HAND_SIZE :int = 7;
}
}