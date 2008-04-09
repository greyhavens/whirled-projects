package spades.graphics {

import flash.display.Sprite;
import flash.display.Scene;
import flash.events.MouseEvent;
import spades.card.Card;
import spades.Debug;
import com.threerings.util.MultiLoader;
import flash.display.MovieClip;


/**
 * Represents a card graphic with a few appearance flags.
 */
public class CardSprite extends Sprite
{
    /** Width of a card sprite. */
    public static const WIDTH :int = 60;

    /** Height of a card sprite. */
    public static const HEIGHT :int = 80;

    /** Normal appearance */
    public static const NORMAL :CardState = 
        new CardState(0xffffff, 0.0, "normal");

    /** Disabled appearance */
    public static const DISABLED :CardState = 
        new CardState(0x808080, 0.2, "disabled");

    /** Highlighted appearance */
    public static const HIGHLIGHTED :CardState = 
        new CardState(0xff7f7f, 0.3, "highlighted");

    /** Emphasized appearance */
    public static const EMPHASIZED :CardState = 
        new CardState(0x7f7fff, 0.3, "emphasized");

    /** Create a new card sprite. */
    public function CardSprite (card :Card)
    {
        _card = card;
        _cover = new Sprite();
        _state = NORMAL;

        MultiLoader.getContents(DECK, gotDeck);

        function gotDeck (clip :MovieClip) :void
        {
            _deck = clip;
            if (card.faceDown) {
                _deck.gotoAndStop(BACK_FRAME);
            }
            else {
                _deck.gotoAndStop(card.string);
            }
            _deck.x = -WIDTH / 2;
            _deck.y = -HEIGHT / 2;
            _deck.scaleX = WIDTH / _deck.width;
            _deck.scaleY = HEIGHT / _deck.height;
            addChild(_deck);
            _deck.addChild(_cover);
        }
    }

    /** Access the underlying card object. */
    public function get card () :Card
    {
        return _card;
    }

    /** Access to the card's highlight state. */
    public function get state () :CardState
    {
        return _state;
    }

    /** Access to the card's highlight state. */
    public function set state (state :CardState) :void
    {
        if (_state != state) {
            _state = state;
            update();
        }
    }

    /** @inheritDoc */
    // From Object
    override public function toString () :String
    {
        var stateStr :String = _state.toString();
        var superStr :String = super.toString();
        var parentStr :String = parent == null ? "null" : parent.toString();
        var cardStr :String = _card == null ? "back" : _card.toString();
        return "CardSprite " + cardStr + " (" + stateStr + ") " + 
            superStr + " in " + parentStr;
    }
    
    protected function update () :void
    {
        _cover.alpha = _state.alpha;
        _cover.graphics.clear();
        _cover.graphics.beginFill(_state.color);
        _cover.graphics.drawRect(0, 0, WIDTH, HEIGHT);
        _cover.graphics.endFill();
    }

    protected var _card :Card;
    protected var _state :CardState;
    protected var _deck :MovieClip;
    protected var _cover :Sprite;

    [Embed(source="../../../rsrc/deck.swf", mimeType="application/octet-stream")]
    protected static const DECK :Class;

    protected static const BACK_FRAME :String = "CB";
}

}

