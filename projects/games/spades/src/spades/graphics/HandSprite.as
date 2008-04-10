package spades.graphics {

import flash.events.MouseEvent;
import flash.geom.Point;
import flash.display.DisplayObject;
import com.threerings.flash.Vector2;
import spades.card.CardArray;
import spades.card.CardArrayEvent;
import spades.card.CardException;
import spades.card.Hand;
import spades.card.HandEvent;
import spades.Debug;


import caurina.transitions.Tweener;

/** Display for a hand of cards */
public class HandSprite extends CardArraySprite
{
    /** Create a new hand sprite. 
     *  @param target the card array this sprite represents */
    public function HandSprite (hand :Hand)
    {
        super(hand.cards);

        _hand = hand;

        addEventListener(MouseEvent.MOUSE_OVER, mouseOverListener);
        addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveListener);
        addEventListener(MouseEvent.MOUSE_OUT, mouseOutListener);
        addEventListener(MouseEvent.CLICK, clickListener);

        _hand.addEventListener(HandEvent.BEGAN_TURN, handListener);
        _hand.addEventListener(HandEvent.ENDED_TURN, handListener);
    }

    /** Grab the card sprites that were recently removed from the hand. After each card is removed, 
     *  its sprite is animated towards a central location and added to an array. It is expected that 
     *  the TrickSprite or some other card game view object will call this function to take control 
     *  of the removed cards. Card sprites accessed from this function will be free of positional 
     *  tweens and removed from the parent container (this).
     *  @return an Array of CardSprite objects. */
    public function finalizeRemovals () :Array
    {
        for (var i :int = 0; i < _removedCards.length; ++i) {
            var c :CardSprite = _removedCards[i];
            Tweener.removeTweens(c, ["x", "y"]);
            removeChild(c);
        }
        var removed :Array = _removedCards;
        _removedCards = new Array();
        return removed;
    }

    protected function handListener (event :HandEvent) :void
    {
        if (event.type == HandEvent.BEGAN_TURN) {
            enable(event.cards);
            _selectCount = event.count;
        }
        else if (event.type == HandEvent.ENDED_TURN) {
            disable();
        }
    }

    /** Disable clicking on all cards. */
    protected function disable () :void
    {
        _cards.forEach(disableSprite);

        unfloatCard();

        function disableSprite (c :CardSprite, index :int, array :Array) :void
        {
            c.state = CardSprite.DISABLED;
        }
    }
    
    /** Enable clicking on specific cards. 
     *  @param subset the cards to enable, or all if null (default)
     *  @throws CardException is the resulting set of enabled cards is empty since otherwise
     *  the game will be waiting forever. */
    protected function enable (subset :CardArray=null) :void
    {
        var count :int = 0;

        // todo: make linear time N + M instead of quadratic N * M
        _cards.forEach(enableSprite);

        unfloatCard();

        if (count == 0) {
            throw new CardException("Enabling zero cards");
        }

        function enableSprite (c :CardSprite, index :int, array :Array) :void
        {
            var enable :Boolean = subset == null || subset.has(c.card);
            if (enable) {
                ++count;
                c.state = CardSprite.NORMAL;
            }
        }
    }

    protected function verticalTween (card :CardSprite, offset :int) :void
    {
        var index :int = _cards.indexOf(card);
        if (index >= 0) {
            var pos :Vector2 = new Vector2();
            getStaticCardPosition(index, pos);
            
            var tween :Object = {
                y: pos.y + offset, 
                time: FLOAT_DURATION};

            Tweener.removeTweens(card, "y");
            Tweener.addTween(card, tween);
        }
        else {
            Tweener.removeTweens(card, "y");
        }
    }

    /** Slide a card vertically to indicate that clicking it will play it. 
     *  @param y the mouse position in the card's coordinates. */
    protected function floatCard (card :CardSprite, y :int) :void
    {
        var offset :Number;

        // prevent hysteresis by popping the card up if the mouse is in the top half of the hand
        // and down if in the bottom half
        if (y + card.y > CardSprite.HEIGHT / 2) {
            offset = FLOAT_HEIGHT;
        }
        else {
            offset = -FLOAT_HEIGHT;
        }

        if (_floater != card) {
            unfloatCard();
        }

        if (_floater != card || _floatPos != offset) {

            verticalTween(card, offset);

            _floater = card;
            _floatPos = offset;
            _floater.state = CardSprite.HIGHLIGHTED;
        }
    }

    /** Slide the currently floating card back into its usual location. */
    protected function unfloatCard () :void
    {
        if (_floater != null) {
            verticalTween(_floater, 0);

            if (_floater.state == CardSprite.HIGHLIGHTED) {
                _floater.state = CardSprite.NORMAL;
            }
        }
        _floater = null;
        _floatPos = -1;
    }

    // TODO: animations when cards are added and removed
    override protected function cardArrayListener (event :CardArrayEvent) :void
    {
        super.cardArrayListener(event);

        if (event.type == CardArrayEvent.RESET) {
            // game logic will do this soon, but call now to make sure there is no flashing
            disable();
        }
    }

    override protected function animateRemoval (card :CardSprite) :void
    {
        // stop mouse animation
        unfloatCard();
        
        // tween to "home row", just above the hand
        card.state = CardSprite.NORMAL;
        var tween :Object = {
            x : _removedCards.length * CardSprite.WIDTH / 2,
            y : -CardSprite.HEIGHT,
            time: REMOVAL_DURATION
        };
        Tweener.addTween(card, tween);

        // Squeeze the leftover cards together
        var pos :Vector2 = new Vector2();
        _cards.forEach(squeeze);

        // Make the removed card available for finalizeRemovals
        _removedCards.push(card);

        function squeeze (c :CardSprite, i :int, a :Array) :void {
            // Since _cards has already been updated, just animate to the static position
            Tweener.removeTweens(c, ["x", "y"]);
            getStaticCardPosition(i, pos);
            var tween :Object = {
                x : pos.x,
                y : pos.y,
                time: SQUEEZE_DURATION
            };
            Tweener.addTween(c, tween);
        }
    }

    protected function isSelected (card :CardSprite) :Boolean
    {
        return _selected.indexOf(card) >= 0;
    }

    protected function findCardByX (xpos :int) :CardSprite
    {
        for (var i :int = _cards.length - 1; i >= 0; --i) {
            var card :CardSprite = CardSprite(_cards[i]);
            if (xpos >= card.x && xpos < card.x + CardSprite.WIDTH) {
                return card;
            }
        }
        return null;
    }

    protected function findCard (event :MouseEvent) :CardSprite
    {
        return exposeCard(event.target);

        Debug.debug("Mouse moved over " + event.target + ", x=" + event.localX);
        if (event.target == this) {
            return findCardByX(event.localX);
        }
        else {
            var pos :Point = new Point(event.localX, event.localY);
            pos = DisplayObject(event.target).localToGlobal(pos);
            pos = globalToLocal(pos);
            return findCardByX(pos.x);
        }
    }

    protected function mouseOverListener (event :MouseEvent) :void
    {
        // pop up the card if it is enabled
        var card :CardSprite = findCard(event);
        if (card != null && card.state != CardSprite.DISABLED && 
            !isSelected(card)) {
            floatCard(card, event.localY);
        }
    }

    protected function mouseMoveListener (event :MouseEvent) :void
    {
        // pop up the card if it is enabled
        var card :CardSprite = findCard(event);
        if (card != null && card == _floater) {
            floatCard(card, event.localY);
        }
    }

    protected function mouseOutListener (event :MouseEvent) :void
    {
        // pop down the card if it is popped up
        var card :CardSprite = findCard(event);
        if (card != null && card == _floater) {
            unfloatCard();
        }
    }

    protected function clickListener (event :MouseEvent) :void
    {
        var card :CardSprite = findCard(event);
        if (card != null && card.state != CardSprite.DISABLED) {
            unfloatCard();

            _selected.push(card);

            verticalTween(card, -SELECT_HEIGHT);

            if (_selected.length == _selectCount) {
                var selected :CardArray = new CardArray();
                for (var i :int = 0; i < _selected.length; ++i) {
                    selected.push(_selected[i].card);
                }
                _hand.selectCards(selected);
                _selected.splice(0, _selected.length);
            }
        }
    }

    protected var _floatPos :Number;
    protected var _floater :CardSprite;
    protected var _selected :Array = new Array();
    protected var _removedCards :Array = new Array();
    protected var _hand :Hand;
    protected var _selectCount :int;
    protected var _remover :Function;

    protected static const SELECT_HEIGHT :Number = 40;
    protected static const FLOAT_HEIGHT :Number = 20;
    protected static const FLOAT_DURATION :Number = .2;
    protected static const REMOVAL_DURATION :Number = .75;
    protected static const SQUEEZE_DURATION :Number = .75;
}

}
