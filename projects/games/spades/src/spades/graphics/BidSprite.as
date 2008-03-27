package spades.graphics {

import flash.display.Sprite;
import flash.text.TextField;
import flash.events.MouseEvent;

import spades.Debug;

/**
 * The user interface for bidding. This is pretty much placeholder code, so is not documented in 
 * detail.
 * TODO: Rewrite with embedded flashy stuff.
 * TODO: Decide how to reuse with other trick-taking card games.
 * TODO: Design timer functionality (or maybe caller does it generically).
 */
public class BidSprite extends Sprite
{
    public static const BUTTON_SIZE :int = 30;

    /** Create a new slider.
     *  @param maxTricks the maximum on the slider (0 is assumed to be the minimum)
     *  @param callback function to call when the user selects their bid. Signature :
     *    function callback (bid :int) :void
     */
    public function BidSprite (maxTricks :int, callback :Function)
    {
        var wid :int = (maxTricks + 1) * BUTTON_SIZE;
        for (var i :int = 0; i <= maxTricks; ++i) {
            var t :TextField = new TextField();
            t.text = "" + i;
            t.width = BUTTON_SIZE;
            t.height = BUTTON_SIZE;
            t.background = true;
            t.backgroundColor = ROLL_OFF;
            t.selectable = false;
            t.x = -wid / 2 + i * BUTTON_SIZE;
            t.y = -BUTTON_SIZE / 2;

            t.addEventListener(MouseEvent.MOUSE_OVER, mouseOverHandler);
            t.addEventListener(MouseEvent.MOUSE_OUT, mouseOutHandler);

            addChild(t);
            _buttons.push(t);
        }

        _maxBid = maxTricks;
        _callback = callback;

        addEventListener(MouseEvent.CLICK, clickListener);

        function mouseOverHandler (e :MouseEvent) :void
        {
            TextField(e.target).backgroundColor = ROLL_ON;
        }

        function mouseOutHandler (e :MouseEvent) :void
        {
            TextField(e.target).backgroundColor = ROLL_OFF;
        }
    }

    protected function clickListener (e :MouseEvent) :void
    {
        if (e.target is TextField) {
            var bid :int = _buttons.indexOf(e.target);
            if (bid >= 0 && bid <= _maxBid) {
                Debug.debug("Bid selected: " + bid);
                if (_callback != null) {
                    _callback(bid);
                    _callback = null;
                }
            }
        }
    }

    protected var _buttons :Array = new Array();
    protected var _maxBid :int;
    protected var _callback :Function;

    protected static const ROLL_OFF :uint = 0x808080;
    protected static const ROLL_ON :uint = 0xFF8080;
}

}

