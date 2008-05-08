package lawsanddisorder.component {

import flash.display.Sprite;
import flash.text.TextField;
import flash.geom.Point;
import flash.events.MouseEvent;
import flash.events.Event;

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
        makeLawButton.y = 90;
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

         _ctx.broadcast(_ctx.board.player.playerName + " got " + cards.length + " monies for making a new law.");
        _ctx.board.player.getMonies(cards.length);
        enabled = false;
        _ctx.state.startEnactingLaws();

        // tell other players and ourself about the new law
        var newLawData :Object = this.getSerializedCards();
        _ctx.sendMessage(Laws.NEW_LAW, newLawData);

        // clear cards from new law and remove them from hand
        clear(false);
        _ctx.board.createLawButton.newLawCreated();
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
     * TODO like createLaw this method of moving cards should be improved
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
            _ctx.board.player.hand.addCards(cardArray, false);
        }
        else {
            _ctx.board.player.hand.removeCards(cardArray, true);
        }
    }

    /**
     * First child is the background, second is the create button
     */
    override protected function getStartingChildIndex () :int
    {
        return 2;
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