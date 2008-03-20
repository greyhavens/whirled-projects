package {

import flash.display.Sprite;
import flash.text.TextField;
import flash.events.MouseEvent;

import com.threerings.util.Log;

/**
 * The user interface for bidding. This is pretty much placeholder code, so is not documented in 
 * detail.
 * @TODO Rewrite with embedded flashy stuff.
 * @TODO Decide how to reuse with other trick-taking card games.
 * @TODO Design timer functionality (or maybe caller does it generically).
 */
public class BidSlider extends Sprite
{
    public static const BUTTON_SIZE :int = 30;

    /** Create a new slider.
     *  @param maxTricks the maximum on the slider (0 is assumed to be the minimum)
     *  @param callback function to call when the user selects their bid. Signature :
     *    function callback (bid :int) :void
     */
    public function BidSlider (maxTricks :int, callback :Function)
    {
        addEventListener(MouseEvent.CLICK, mouseClick)
        addEventListener(MouseEvent.MOUSE_MOVE, mouseMove)
        addEventListener(MouseEvent.MOUSE_OUT, mouseOut)

        for (var i :int = 0; i < maxTricks; ++i) {
            var t :TextField = new TextField();
            t.text = "" + i;
            t.width = BUTTON_SIZE;
            t.height = BUTTON_SIZE;
            t.background = true;
            t.selectable = false;
            t.x = i * BUTTON_SIZE;
            addChild(t);
            _buttons.push(t);
        }

        roll(-1);
        _maxBid = maxTricks;
        _callback = callback;
    }

    protected function mouseClick (event :MouseEvent) :void {
        var bid :int = roll(event.target);
        if (bid >= 0 && bid <= _maxBid) {
            Log.getLog(this).info("Bid selected: " + bid);
            if (_callback != null) {
                _callback(bid);
                _callback = null;
            }
            roll(null);
        }
    }

    protected function mouseMove (event :MouseEvent) :void {
        if (_callback != null) {
            roll(event.target);
        }
    }

    protected function mouseOut (event :MouseEvent) :void {
        roll(null);
    }

    protected function roll (target :Object) :int {
        var bid :int = -1;
        for (var i :int = 0; i < _buttons.length; ++i) {
            var t :TextField = _buttons[i] as TextField;
            if (t == target) {
                t.backgroundColor = ROLL_ON;
                bid = i;
            }
            else {
                t.backgroundColor = ROLL_OFF;
            }
        }
        
        return bid;
    }

    protected var _buttons :Array = new Array();
    protected var _maxBid :int;
    protected var _callback :Function;

    protected static const ROLL_OFF :uint = 0x808080;
    protected static const ROLL_ON :uint = 0xFF8080;
}

}

