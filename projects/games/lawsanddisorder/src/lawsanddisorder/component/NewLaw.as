package lawsanddisorder.component {

import flash.display.Sprite;
import flash.text.TextField;
import flash.geom.Point;
import flash.events.MouseEvent;
import lawsanddisorder.Context;

/**
 * Area for creating a new law
 */
public class NewLaw extends CardContainer
{
    /**
     * Constructor
     */
    public function NewLaw (ctx :Context)
    {
        super(ctx);
    }
    
    /**
     * Draw the new law area
     */
    override protected function initDisplay () :void
    {
        // end turn button
        makeLawButton = new TextField();
        makeLawButton.text = "create";
        makeLawButton.x = 350;
        makeLawButton.y = 60;
        addChild(makeLawButton);
        enabled = false;
        
        // draw the bg
        graphics.clear();
        graphics.beginFill(0xFF5555);
        graphics.drawRect(0, 0, 380, 80);
        graphics.endFill();
        
        title.text = "Drag cards here then press 'create' to make a new law"
        title.width = 400;
    }
    
    /**
     * Rearrange hand when cards are added or subtracted
     */
    override protected function updateDisplay () :void
    {
        // position the cards horizontally and display each
        for (var i :int = 0; i < cards.length; i++) {
            var card :Card = cards[i];
            card.x = i * CARD_SPACING_X;
            card.y = 20;
        }
    }
    
    /**
     * Determine if the contents of the card array form a valid law.
     */
    public function isValidLaw () :Boolean
    {
        if (cards == null) {
            _ctx.log("WTF cards are null in isValidLaw");
            return false;    
        }
        
        if (cards.length < 3) {
            return false;
        }
        if (cards[0].group != Card.SUBJECT) {
            return false;
        }
        if (cards[1].group != Card.VERB) {
            return false;
        }
        if (cards[2].group == Card.OBJECT) {
            if (cards.length == 3) {
                // SUBECT VERB OBJECT
                return true;
            }
            if (cards[3].group == Card.WHEN) {
                if (cards.length == 4) {
                    // SUBJECT VERB OBJECT WHEN
                    return true;    
                }
            }
        }
        else if (cards[1].type == Card.GIVES) {
            if (cards[2].group != Card.SUBJECT) {
                return false;
            }
            if (cards[3].group != Card.OBJECT) {
                return false;
            }
            if (cards.length == 4) {
                // SUBJECT VERB:GIVES SUBECT OBJECT
                return true;
            }
            if (cards[4].group == Card.WHEN) {
                if (cards.length == 5) {
                    // SUBJECT VERB:GIVES SUBJECT OBJECT WHEN
                    return true;
                }
            }
        }
        return false;
    }
    
    /**
     * Make law button was pressed
     */
    protected function makeLawButtonClicked (event :MouseEvent) :void
    {
        if (!_enabled) {
            _ctx.log("WTF tried to create a law while disabled");
            return;
        }
        if (!isValidLaw()) {
            _ctx.notice("That is not a legal law.");
            return;
         }
 
 		_ctx.broadcast(_ctx.board.player.playerName + " created a new law.");
        _ctx.board.player.getMonies(cards.length);
        
        var law :Law = createLaw();
        _ctx.board.laws.addNewLaw(law);
    }
    
    /**
     * Move the cards from this law into a new law and return it.  Also disable the create new 
     * law function because players can only create one law in a turn.
     * TODO make removing cards more efficient
     */
    protected function createLaw () :Law
    {
        enabled = false;
        _ctx.state.performingAction = true;
        
        // make a copy of the card array
        var cardArray :Array = new Array();
        for (var i :int = 0; i < cards.length; i++) {
            cardArray[i] = cards[i];
        }
        removeCards(cardArray);
        
        var law :Law = new Law(_ctx, _ctx.board.laws.numLaws);
        law.addCards(cardArray);
        return law;
    }
    
    /**
     * Do nothing when the new law contents changed; tell opponents only when the new law is done.
     */
    override public function setDistributedData () :void
    {
        // do nothing
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
     */
    override public function shiftCards (point :Point) :void
    {
        // localize the point to our coordinate map
        var localPoint :Point = globalToLocal(point);
        
        // position the cards horizontally and display each
        for (var i :int = 0; i < cards.length; i++) {
            var card :Card = cards[i];
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
     * Prevent or allow the player to create a new law.
     */
    public function set enabled (value :Boolean) :void
    {
        if (value) {
            makeLawButton.addEventListener(MouseEvent.CLICK, makeLawButtonClicked);
            makeLawButton.textColor = 0x000000;
        }
        else {
            makeLawButton.removeEventListener(MouseEvent.CLICK, makeLawButtonClicked);
            makeLawButton.textColor = 0x999999;
        }
        _enabled = value;
    }
    
    /**
     * Return the enabled/disabled state.
     */
    public function get enabled () :Boolean {
        return _enabled;
    }
    
    /**
     * Return all cards in new law to the player's hand.
     * TODO like createLaw this method of moving cards should be improved
     */
    public function clear () :void
    {
        if (cards.length == 0) {
            return;
        }
        // make a copy of the cards
        var cardArray :Array = new Array();
        for (var i :int = 0; i < cards.length; i++) {
            cardArray[i] = cards[i];
        }
        // remove them from here, add them to hand
        removeCards(cardArray);        
        _ctx.board.player.hand.addCards(cardArray);
    }
    
    /** Can the player make a new law right now? 
     * TODO better to have lawAlreadyCreatedThisTurn? */
    protected var _enabled :Boolean = false;
    
    /** Press this button to complete the new law */
    protected var makeLawButton :TextField;
}
}