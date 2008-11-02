package lawsanddisorder.component {

import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.text.TextField;

import lawsanddisorder.*;

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
     * Determine if the contents of the card array form a valid law.  If a cardList is provided
     * use that, otherwise use the cardlist inside this NewLaw.
     */
    public function isValidLaw (cardList :Array = null) :Boolean
    {
        if (cardList == null) {
            cardList = cards;
        }
        
        if (cardList == null) {
            _ctx.error("cardList are null in isValidLaw");
            return false;
        }

        if (cardList.length < 3) {
            return false;
        }
        if (cardList[0].group != Card.SUBJECT) {
            return false;
        }
        if (cardList[1].group != Card.VERB) {
            return false;
        }
        if (cardList[2].group == Card.OBJECT) {
            if (cardList.length == 3) {
                // SUBECT VERB OBJECT
                return true;
            }
            if (cardList[3].group == Card.WHEN) {
                if (cardList.length == 4) {
                    // SUBJECT VERB OBJECT WHEN
                    return true;
                }
            }
        }
        else if (cardList[1].type == Card.GIVES) {
            if (cardList[2].group != Card.SUBJECT) {
                return false;
            }
            if (cardList[3].group != Card.OBJECT) {
                return false;
            }
            if (cardList.length == 4) {
                // SUBJECT VERB:GIVES SUBECT OBJECT
                return true;
            }
            if (cardList[4].group == Card.WHEN) {
                if (cardList.length == 5) {
                    // SUBJECT VERB:GIVES SUBJECT OBJECT WHEN
                    return true;
                }
            }
        }
        return false;
    }
    
    /**
     * Determine which player, if any, a law represented by an array of cards will benefit.
     */
    public function isGoodFor (cardList :Array = null) :Player
    {
        if (!isValidLaw(cardList)) {
            _ctx.error("law is invalid in NewLaw.isGoodFor");
            return null;
        }
        
        // return the player who GETS something
        if (cardList[1].type == Card.GETS) {
            return _ctx.board.deck.getPlayerByJobId(cardList[0].type);
        
        // return the player who receives something
        } else if (cardList[1].type == Card.GIVES && cardList[2].group == Card.SUBJECT) {
            return _ctx.board.deck.getPlayerByJobId(cardList[2].type);
        
        // return null because a player only LOSES or GIVES (to their choice of player)
        } else {
            return null;
        }
    }
    
    /**
     * Determine which player, if any, a law represented by an array of cards will hurt.
     */
    public function isBadFor (cardList :Array = null) :Player
    {
        if (!isValidLaw(cardList)) {
            _ctx.error("law is invalid in NewLaw.isBadFor");
            return null;
        }

        // return the player who LOSES or GIVES something
        if (cardList[1].type == Card.GIVES || cardList[1].type == Card.LOSES) {
            return _ctx.board.deck.getPlayerByJobId(cardList[0].type);
        
        // return null because a player only GETS something
        } else {
            return null;
        }
    }
    
    /**
     * Given a list of cards and a player, award monies and make a new law.
     */
    public function makeLaw (cardList :Array, player :Player) :void
    {
        if (player == _ctx.player) {
            _ctx.broadcastOthers(player.name + " got " + cardList.length 
                + " monies for making a law.");
            _ctx.notice("You got " + cardList.length + " monies for making a law.");
        } else {
            _ctx.broadcast(player.name + " got " + cardList.length 
                + " monies for making a law.");
        }
        player.getMonies(cardList.length);
        _ctx.state.startEnactingLaws();

        // tell other players that cards have been removed from hand, and the new law created
        //_ctx.sendMessage(Laws.NEW_LAW, getSerializedCards(cardList));
        _ctx.eventHandler.setData(Laws.LAWS_DATA, getSerializedCards(cardList), 
            _ctx.board.laws.numLaws, true);
        _ctx.eventHandler.dispatchEvent(new Event(Laws.NEW_LAW));
        player.hand.removeCards(cardList, true);
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

        // if point is not supplied, just arrange cards normally
        if (point == null) {
            for (i = 0; i < cards.length; i++) {
                card = cards[i];
                card.x = CARD_LEFT_START + i * CARD_SPACING_X;
                card.y = 17;
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
                card.x = CARD_LEFT_START + (i+1) * CARD_SPACING_X;
            }
            else {
                card.x = CARD_LEFT_START + i * CARD_SPACING_X;
            }
        }
    }

    /**
     * Draw the new law area
     */
    override protected function initDisplay () :void
    {
        var background :Sprite = new NEWLAW_BACKGROUND();
        addChild(background);

        makeLawButton = new Button(_ctx);
        makeLawButton.text = "create";
        makeLawButton.addEventListener(MouseEvent.CLICK, makeLawButtonClicked);
        makeLawButton.enabled = false;
        makeLawButton.x = 150;
        makeLawButton.y = 85;
        addChild(makeLawButton);
    }

    /**
     * Rearrange hand when cards are added or subtracted
     */
    override protected function updateDisplay () :void
    {
        arrangeCards();
    }

    /**
     * Make law button was pressed
     */
    protected function makeLawButtonClicked (event :MouseEvent) :void
    {
        if (!_enabled) {
            _ctx.error("tried to create a law while disabled");
            return;
        }
        if (!isValidLaw()) {
            _ctx.notice("That is not a legal law.");
            return;
        }
        
        enabled = false;
        makeLaw(cards, _ctx.player);

        // clear cards from new law and remove them from hand
        clear(false);
        _ctx.board.createLawButton.newLawCreated();
    }

    /**
     * Prevent or allow the player to create a new law.
     */
    public function set enabled (value :Boolean) :void
    {
        makeLawButton.enabled = value;
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
     */
    protected function clear (backToHand :Boolean = true) :void
    {
        if (cards.length == 0) {
            return;
        }
        // make a copy of the cards
        var cardArray :Array = new Array();
        for (var i :int = 0; i < cards.length; i++) {
            cardArray[i] = cards[i];
        }
        // remove them from here, add them to hand - do not tell other players
        removeCards(cardArray, false);

        if (backToHand) {
            _ctx.player.hand.addCards(cardArray, false);
        }
    }

    /**
     * Begin displaying the new law area
     */
    public function show () :void
    {
        if (!_ctx.board.contains(this)) {
            _ctx.board.addChild(this);
        }
    }

    /**
     * Return cards and hide the new law area
     */
    public function hide () :void
    {
        clear();
        if (_ctx.board.contains(this)) {
            _ctx.board.removeChild(this);
        }
    }

    /** Can the player make a new law right now?
     * TODO better to have lawAlreadyCreatedThisTurn? */
    protected var _enabled :Boolean = false;

    /** Press this button to complete the new law */
    protected var makeLawButton :Button;

    /** Background image for the entire board */
    [Embed(source="../../../rsrc/components.swf#newlaw")]
    protected static const NEWLAW_BACKGROUND :Class;

    /** Cards are spaced further apart */
    protected static const CARD_SPACING_X :int = 69;

    /** Cards start at this x value */
    protected static const CARD_LEFT_START :int = 44;
}
}