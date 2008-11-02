package lawsanddisorder.component {

import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.text.TextField;

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
        addEventListener(MouseEvent.ROLL_OVER, ctx.state.mouseEventHandler.lawMouseOver);
        addEventListener(MouseEvent.ROLL_OUT, ctx.state.mouseEventHandler.lawMouseOut);
        super(ctx);
    }

    /**
     * Return this law as a sentence
     */
    override public function toString () :String
    {
        var string :String = "";
        for each (var card :Card in cards) {
            string += card.text + " ";
        }
        string = string.substr(0, string.length - 1);
        return string;
    }

    /**
     * Draw the law area
     */
    override protected function initDisplay () :void
    {
        var background :Sprite = new LAW_BACKGROUND();
        addChild(background);
    }

    /**
     * Rearrange law when cards are added or subtracted
     */
    override protected function updateDisplay () :void
    {
        var cardX :Number = 9;
        for (var i :int = 0; i < cards.length; i++) {
            // update text version of the law
            var card :Card = cards[i];
            card.x = cardX;
            card.y = 7;
            cardX += card.width + 0;
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
            // control player speaks for the absent job to tell everyone this law has been enacted
            if (_ctx.control.game.amInControl()) {
                _ctx.sendMessage(Laws.ENACT_LAW_DONE, id);
            }
            return;
        }

        // keep going only if we are the law subject, or are controlling an ai player subject
        var fromAIPlayer :AIPlayer = (fromPlayer as AIPlayer);
        //if (fromPlayer != _ctx.player && (fromAIPlayer == null || !fromAIPlayer.isController)) {
        if (fromPlayer != _ctx.player && (fromAIPlayer == null || !_ctx.player.isController)) {
            _ctx.state.waitingForOpponent = fromPlayer;
            return;
        }

        // get the verb
        var verb :int = cards[1].type;

        // get the player who recieves if verb is gives
        var toPlayer :Player = null;
        if (verb == Card.GIVES) {
            // SUBJECT VERB:GIVES SUBECT OBJECT
            if (cards[2].group == Card.SUBJECT) {
                toPlayer = _ctx.board.deck.getPlayerByJobId(cards[2].type);
            }
            // SUBJECT VERB:GIVES OBJECT (toPlayer must be selected)
            else if (toPlayer == null) {               
                if (fromAIPlayer != null) {
                    toPlayer = fromAIPlayer.selectOpponent(this);
                } else {
                    toPlayer = _ctx.state.selectedPlayer;
                    if (toPlayer == null) {
                        // return here once an opponent has been selected
                        _ctx.broadcastOthers("Waiting for " +  fromPlayer.name + 
                            " to pick an opponent to give to.", fromPlayer, true);
                        _ctx.state.selectOpponent(enactLaw);
                        return;
                    }
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
                message = " got " + Content.monieCount(amount);
            }
            else {
                if (_ctx.board.deck.numCards < amount) {
                    message = " would have got " + Content.cardCount(amount) + ", but there ";
                    if (amount == 1) {
                        message += "was only 1 left!";
                    } else if (amount == 0) {
                        message += "were none left!";
                    } else {
                        message += "were only " + amount + " left!";
                    }
                    amount = _ctx.board.deck.numCards;
                } else {
                    message = " got " + Content.cardCount(amount);
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
                    message = " gave " + Content.monieCount(amount) +  
                        " to " + toPlayer.name;
                }
                else {
                    message = " lost " + Content.monieCount(amount);
                }
            }
            else {
                var selectedCards :Array;
                if (fromAIPlayer != null) {
                    selectedCards = fromAIPlayer.selectCards(amount, this);
                } else {
                    selectedCards = _ctx.state.selectedCards;
                    if (selectedCards == null) {
                        // return to here once player has selected X cards
                        _ctx.broadcastOthers("Waiting for " +  fromPlayer.name + " to pick " + 
                            Content.cardCount(amount) + " to lose.", fromPlayer, true);
                        _ctx.state.selectCards(amount, enactLaw);
                        return;
                    }
                }

                // GIVES cards to somebody
                if (verb == Card.GIVES && toPlayer != null) {
                    fromPlayer.giveCardsTo(selectedCards, toPlayer);
                    if (selectedCards.length < amount) {
                        message = " would have given " + 
                            toPlayer.name + " " + Content.cardCount(amount) +  
                            ", but had " + selectedCards.length + " to give";
                    } else {
                        message = " gave " + Content.cardCount(amount) + 
                            " to " + toPlayer.name;
                    }
                }
                // LOSES / GIVES cards to nobody
                else {
                    fromPlayer.discardCards(selectedCards);
                    if (selectedCards.length < amount) {
                        message = " would have lost " + Content.cardCount(amount) + 
                            ", but had " + selectedCards.length + " to lose";
                    } else {
                        message = " lost " + Content.cardCount(amount);
                    }
                }
            }
        }

        if (fromPlayer == _ctx.player) {
            _ctx.notice("(law): You" + message + ".");
            _ctx.broadcastOthers("(law): " + fromPlayer.name + message + ".");
        } else {
            _ctx.broadcast("(law): " + fromPlayer.name + message + ".");
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
            _ctx.error("cards empty when getting law.when");
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
            _ctx.error("cards empty when getting law.subject");
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
     * Called when the contents of this law change; determine whether there's a gives target.
     */
    override public function setSerializedCards (serializedCards :Object, 
        distributeData :Boolean = false) :void
    {
        super.setSerializedCards(serializedCards, distributeData);
        
        if (cards == null || cards.length < 3) {
            _ctx.error("no or not enough cards duing law.setSerializedCards");
            return;
        }
            
        if (cards[1].type == Card.GIVES && cards[2].group == Card.SUBJECT) {
            _hasGivesTarget = true;
        } else {
            _hasGivesTarget = false;
        }
    }

    /**
     * Is this law of the form SUBJECT GIVES TARGET OBJECT {WHEN}+?
     */
    public function hasGivesTarget () :Boolean
    {
        return _hasGivesTarget;
    }

    /** Fetch the index of the law in the list of laws */
    public function get id () :int {
        return _id;
    }

    /**
     * ID starts at zero, but when displaying we start from 1
     */
    public function get displayId () :int {
        return (_id + 1);
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
    public function setHighlighted (value :Boolean, delay :Boolean = false) :void
    {
        _highlighted = value;
        if (delay) {
            // perform de-highliting after a short delay
            EventHandler.invokeLater(2, function () :void {
                for each (var litCard :Card in cards) {
                    litCard.highlighted = _highlighted;
                }
            });
        } else {
            for each (var unlitCard :Card in cards) {
                unlitCard.highlighted = _highlighted;
            }
        }
    }
    
    /** Is the law highlighted? */
    protected var _highlighted :Boolean = false;

    /** Index of this law in the list of laws */
    private var _id :int;

    /** Contains the compacted text version of the law */
    protected var lawText :Sprite;
    
    /** True if law is of the format [SUBJECT] [GIVES] [JOB] [OBJECT] */
    protected var _hasGivesTarget :Boolean;

    /** Background image for the entire board */
    [Embed(source="../../../rsrc/components.swf#law")]
    protected static const LAW_BACKGROUND :Class;
}
}