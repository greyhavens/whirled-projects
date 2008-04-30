package spades.graphics {

import flash.events.MouseEvent;
import flash.geom.Point;
import flash.display.DisplayObject;
import flash.display.Sprite;
import com.threerings.flash.Vector2;
import com.whirled.contrib.card.CardArray;
import com.whirled.contrib.card.CardArrayEvent;
import com.whirled.contrib.card.CardException;
import com.whirled.contrib.card.Hand;
import com.whirled.contrib.card.HandEvent;
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

        var maxWidth :int = CardSprite.WIDTH / 2 * (MAX_HAND_SIZE + 1);
        graphics.beginFill(0x000000, 0.0);
        graphics.drawRect(-maxWidth / 2, -CardSprite.HEIGHT / 2, 
            maxWidth, CardSprite.HEIGHT);
        graphics.endFill();

        addEventListener(MouseEvent.MOUSE_OVER, updateFloater);
        addEventListener(MouseEvent.MOUSE_MOVE, updateFloater);
        addEventListener(MouseEvent.MOUSE_OUT, updateFloater);
        addEventListener(MouseEvent.CLICK, clickListener);

        _hand.addEventListener(HandEvent.ALLOWED_PLAY, handListener);
        _hand.addEventListener(HandEvent.ALLOWED_SELECTION, handListener);
        _hand.addEventListener(HandEvent.DISALLOWED_SELECTION, handListener);
        _hand.addEventListener(HandEvent.CARDS_PLAYED, handListener);
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
        Debug.debug("HandSprite received event " + event);

        if (event.type == HandEvent.ALLOWED_PLAY) {
            enable(event.cards);
            _selectCount = event.count;
            if (_userPreselect) {
                dispatchSelection();
            }
        }
        else if (event.type == HandEvent.DISALLOWED_SELECTION) {
            disable();
        }
        else if (event.type == HandEvent.CARDS_PLAYED) {
            _selectCount = 0;
        }
        else if (event.type == HandEvent.ALLOWED_SELECTION) {
            enable(event.cards);
            _selectCount = -event.count;
        }
    }

    /** Disable clicking on all cards. */
    protected function disable () :void
    {
        _cards.forEach(function (c :CardSprite, ...x) :void {
            c.state = CardSprite.DISABLED;
        });

        for (var i :int = 0; i < _selected.length; ++i) {
            verticalTween(CardSprite(_selected[i]), 0);
        }

        _selected.splice(0, _selected.length);
        _selectCount = 0;

        unfloatCard();
    }
    
    /** Enable clicking on specific cards. 
     *  @param subset the cards to enable, or all if null (default)
     *  @throws CardException is the resulting set of enabled cards is empty since otherwise
     *  the game will be waiting forever. */
    protected function enable (subset :CardArray=null) :void
    {
        var count :int = 0;
        var aCard :CardSprite = null

        _cards.forEach(function (c :CardSprite, ...x) :void {
            if (subset == null || subset.has(c.card)) {
                ++count;
                c.state = CardSprite.NORMAL;
                aCard = c;
            }
            else {
                c.state = CardSprite.DISABLED;
                if (isSelected(c)) {
                    deselect(c);
                }
            }
        });

        unfloatCard();

        if (count == 0) {
            throw new CardException("Enabling zero cards");
        }

        if (_cards.length == 1 || (subset != null && subset.length == 1)) {
            select(aCard, false);
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
    protected function floatCard (card :CardSprite) :void
    {
        if (_floater != card) {
            unfloatCard();

            verticalTween(card, -FLOAT_HEIGHT);
            _floater = card;
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
    }

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
        
        Tweener.removeTweens(card, ["x", "y"]);

        // tween to "home row", just above the hand
        card.state = CardSprite.NORMAL;
        Tweener.addTween(card, {
            x : _removedCards.length * CardSprite.WIDTH / 2,
            y : -CardSprite.HEIGHT,
            time: REMOVAL_DURATION
        });

        // Squeeze the leftover cards together
        var pos :Vector2 = new Vector2();
        _cards.forEach(function (c :CardSprite, i :int, a :Array) :void {
            // Since _cards has already been updated, just animate to the static position
            getStaticCardPosition(i, pos);
            Tweener.removeTweens(c, ["x", "y"]);
            Tweener.addTween(c, {
                x : pos.x,
                y : pos.y,
                time: SQUEEZE_DURATION
            });
        });

        // Make the removed card available for finalizeRemovals
        _removedCards.push(card);
    }

    override protected function animateAddition (card :CardSprite) :void
    {
        card.state = CardSprite.DISABLED;
        _added.push(card);

        var pos :Vector2 = new Vector2();
        _cards.forEach(function (c :CardSprite, i :int, a :Array) :void {
            getStaticCardPosition(i, pos);
            var tween :Object = {
                x : pos.x,
                y : pos.y,
                time: SQUEEZE_DURATION
            };
            if (_added.indexOf(c) >= 0) {
                c.x = pos.x;
                c.y = pos.y - SELECT_HEIGHT;
                tween.time *= 2;
                tween.delay = SQUEEZE_DURATION;
            }
            if (c == card) {
                tween.onComplete = function () :* {
                    _added.splice(0, -1);
                }
            }
            Tweener.addTween(c, tween);
        });
    }

    protected function select (card :CardSprite, userAction :Boolean) :void
    {
        if (!isSelected(card)) {
            _selected.push(card);
            verticalTween(card, -SELECT_HEIGHT);
            _userPreselect = userAction;
        }
    }

    protected function deselect (card :CardSprite) :void
    {
        if (isSelected(card)) {
            verticalTween(card, 0);
            _selected.splice(_selected.indexOf(card), 1);
        }
    }

    protected function isSelected (card :CardSprite) :Boolean
    {
        return _selected.indexOf(card) >= 0;
    }

    protected function findCardByX (xpos :int) :CardSprite
    {
        if (_cards.length == 0) {
            return null;
        }

        xpos -= _cards[0].x - HALF_CARD_WIDTH;
        var idx :int = xpos / HALF_CARD_WIDTH;
        if (idx == _cards.length) {
            idx = _cards.length - 1;
        }
        return _cards[idx] as CardSprite;
    }

    protected function findCardByLocalXY(x :int, y :int) :CardSprite
    {
        if (y < -CardSprite.HEIGHT / 2 - SELECT_HEIGHT || 
            y >= CardSprite.HEIGHT / 2) {
            return null;
        }
        return findCardByX(x);
    }

    protected function findCard (event :MouseEvent) :CardSprite
    {
        if (event.target == this) {
            return findCardByLocalXY(event.localX, event.localY);
        }
        else {
            var pos :Point = new Point(event.localX, event.localY);
            pos = DisplayObject(event.target).localToGlobal(pos);
            pos = globalToLocal(pos);
            return findCardByLocalXY(pos.x, pos.y);
        }
    }

    protected function updateFloater (event :MouseEvent) :void
    {
        var card :CardSprite = findCard(event);
        if (card != null && card.state != CardSprite.DISABLED && 
            !isSelected(card)) {
            floatCard(card);
        }
        else {
            unfloatCard();
        }
    }

    protected function clickListener (event :MouseEvent) :void
    {
        var card :CardSprite = findCard(event);
        if (card != null && card.state != CardSprite.DISABLED) {
            unfloatCard();

            if (isSelected(card) && (_selectCount < 0 || _selectCount > 1)) {
                deselect(card);
            }
            else if (_selectCount == 0) {
            }
            else if (_selectCount < 0) {
                select(card, true);
                if (_selected.length > -_selectCount) {
                    deselect(_selected[0] as CardSprite);
                }
            }
            else {
                select(card, true);
                dispatchSelection();
            }
        }
    }

    protected function dispatchSelection () :void
    {
        if (_selected.length == _selectCount) {
            var selected :CardArray = new CardArray();
            for (var i :int = 0; i < _selected.length; ++i) {
                selected.push(CardSprite(_selected[i]).card);
            }
            _selected.splice(0, _selected.length);
            _userPreselect = false;
            _hand.playCards(selected);
        }
    }

    protected var _floater :CardSprite;
    protected var _selected :Array = new Array();
    protected var _removedCards :Array = new Array();
    protected var _hand :Hand;
    protected var _selectCount :int;
    protected var _added :Array = new Array();
    protected var _userPreselect :Boolean;

    protected static const MAX_HAND_SIZE :int = 15;
    protected static const SELECT_HEIGHT :Number = 20;
    protected static const FLOAT_HEIGHT :Number = 10;
    protected static const FLOAT_DURATION :Number = .2;
    protected static const REMOVAL_DURATION :Number = .75;
    protected static const SQUEEZE_DURATION :Number = .75;
    protected static const HALF_CARD_WIDTH :int = CardSprite.WIDTH / 2;
}

}
