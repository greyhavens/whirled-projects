package lawsanddisorder.component {

import flash.display.Sprite;
import flash.geom.Point;
import flash.text.TextField;
import flash.events.MouseEvent;
import lawsanddisorder.*;
import flash.display.DisplayObject;

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
        addEventListener(MouseEvent.CLICK, ctx.state.lawClick);
        super(ctx);
    }
    
    /**
     * Draw the law area
     */
    override protected function initDisplay () :void
    {
        // draw the bg
        graphics.clear();
        graphics.beginFill(0x999955);
        graphics.drawRect(0, 0, 380, 20);
        graphics.endFill();
        
        lawText = new TextField();
        lawText.width = 400;
        lawText.height = 25;
        addChild(lawText);
        
        cardDisplayArea = new Sprite();
        cardDisplayArea.graphics.beginFill(0x999955);
        cardDisplayArea.graphics.drawRect(0, 0, 340, 80);
        cardDisplayArea.y = -25;
        cardDisplayArea.x = 40;
        addEventListener(MouseEvent.ROLL_OVER, rollOver);
        addEventListener(MouseEvent.ROLL_OUT, rollOut);
        cardDisplayArea.addEventListener(MouseEvent.ROLL_OUT, rollOut);
    }
    
    /**
     * Rearrange hand when cards are added or subtracted
     * TODO do the highlighting elsewhere to avoid rewriting text every time
     */
    override protected function updateDisplay () :void
    {
        var text :String = "Law " + _id + ":   ";
        for (var i :int = 0; i < cards.length; i++) {
            
            // update text version of the law
            var card :Card = cards[i];
            text += card.text + "   ";
            
            // position the card horizontally in the card display area
            card.x = i * CARD_SPACING_X;
            card.y = 10;
        }
        lawText.text = text;
        
        // draw a border, highlighted or not
        if (_highlighted) {
            graphics.lineStyle(5, 0xFFFF00);
        }
        else {
            graphics.lineStyle(5, 0x999955);
        }
        graphics.drawRect(2.5, 2.5, 375, 15);
    }
    
    /**
     * When child cards are added via the CardContainer class, instead add them to
     * a separate display object that can be displayed and hidden at will.
     */
    override public function addChild (child :DisplayObject) :DisplayObject
    {
        if (child is Card) {
            return cardDisplayArea.addChild(child);
        }
        else {
            return super.addChild(child);
        }
    }
    
    /**
     * When child cards are removed via the CardContainer class, instead removed them from
     * a separate display object that can be displayed and hidden at will.
     */
    override public function removeChild (child :DisplayObject) :DisplayObject
    {
        if (child is Card) {
            return cardDisplayArea.removeChild(child);
        }
        else {
            return super.removeChild(child);
        }
    }
    
    /**
     * When CardContainer class checks whether this contains a card, instead check the
     * card display object.
     */
    override public function contains (child :DisplayObject) :Boolean
    {
        if (child is Card) {
            return cardDisplayArea.contains(child);
        }
        else {
            return super.contains(child);
        }
    }
    
    /**
     * Called whenever a law is enacted.  Parse through it and perform any actions needed of 
     * our player.  Assumes this is a valid law.  Ignores WHEN cards.  Only the subject player
     * performs the enacting.  If the player is called upon to select a card/opponent, this
     * function will be called again once the selection has been made.
     * 
     * TODO straighten out this logic.  toPlayer is particularly confusing: can be null because
     *      no player is that job, or null because a player hasn't been chosen.
     */
    public function enactLaw () :void
    {
        // get the player who gets/loses/gives
        var fromPlayer :Player = _ctx.board.deck.getPlayerByJobId(cards[0].type);
        if (fromPlayer == null) {
            _ctx.sendMessage(Laws.ENACT_LAW_DONE, id);
            return;
        }
        
        // determine if our player has nothing to do here
        if (fromPlayer != _ctx.board.player) {
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
        
        // GETS
        if (verb == Card.GETS) {
            if (object == Card.MONIE) {
                fromPlayer.getMonies(amount);
                _ctx.broadcast(fromPlayer.playerName + " got " + amount + " monies.");
            }
            else {
                fromPlayer.getCards(amount);
                _ctx.broadcast(fromPlayer.playerName + " got " + amount + " cards.");
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
                    _ctx.broadcast(fromPlayer.playerName + " gave " + amount + " monies to " + toPlayer.playerName);
                }
                else {
                	_ctx.broadcast(fromPlayer.playerName + " lost " + amount + " monies.");
                }
            }
            else {
                var selectedCards :Array = _ctx.state.selectedCards;
                if (selectedCards == null) {
                    // return to here once player has selected X cards
                    _ctx.state.selectCards(amount, enactLaw);
                    return;
                }
                
                // GIVES cards to somebody
                if (verb == Card.GIVES && toPlayer != null) {
                    fromPlayer.giveCardsTo(selectedCards, toPlayer);
                    _ctx.broadcast(fromPlayer.playerName + " gave " + amount + " cards to " + toPlayer.playerName);
                }
                // LOSES / GIVES cards to nobody
                else {
                    fromPlayer.loseCards(selectedCards);
                    _ctx.broadcast(fromPlayer.playerName + " lost " + amount + " cards.");
                }
            }
        }
        
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
        _ctx.eventHandler.setData(Laws.LAWS_DATA, getSerializedCards(), _id);
    }
    
    /**
     * Display or hide the cards area.  If displaying, automatically hide it again after a
     * delay.
     */
    public function set showCards (value :Boolean) :void
    {
        if (value && !contains(cardDisplayArea)) {
        	_ctx.board.laws.bringToFront(this);
            addChild(cardDisplayArea);
            EventHandler.invokeLater(3, function () :void {showCards = false;});
        }
        else if (!value && contains(cardDisplayArea)) {
            removeChild(cardDisplayArea);
        }
    }
    
    /**
     * Triggered by the mouse entering the compacted law area.  Display the card area containing
     * the cards.
     */
    protected function rollOver (event :MouseEvent) :void
    {
        showCards = true;
    }
    
    /**
     * Triggered by the mouse exiting the card display area.  Hide the card display area and
     * return to the compact law display.
     */
    protected function rollOut (event :MouseEvent) :void
    {
        showCards = false;
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
    
    /** Is the law highlighted because it's selected? */
    public function get highlighted () :Boolean {
        return _highlighted;
    }
    
    /** Highlight the law because it's selected. */
    public function set highlighted (value :Boolean) :void {
        _highlighted = value;
        updateDisplay();
    }
    
    /** Cards are shown here */
    protected var cardDisplayArea :Sprite;
    
    /** Is the law highlighted? */
    private var _highlighted :Boolean = false;
    
    /** Index of this law in the list of laws */
    private var _id :int;
    
    /** Contains the compacted text version of the law */
    protected var lawText :TextField
}
}