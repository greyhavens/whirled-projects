package spades.graphics {

import flash.display.Sprite;
import flash.display.DisplayObjectContainer;
import flash.events.MouseEvent;
import flash.display.SimpleButton;

import com.threerings.util.MultiLoader;

import spades.Debug;
import com.whirled.contrib.card.trick.Bids;
import com.whirled.contrib.card.trick.BidEvent;

/** Represents the interface for normal bidding (nil to 13). */
public class NormalBiddingSprite extends Sprite
{
    /** Create a new interface. The bids object is used to listen for requests for new bids and 
     *  show and hide the interface based as well as disable bids that are over the maximum. */
    public function NormalBiddingSprite (bids :Bids)
    {
        _bids = bids;

        MultiLoader.getContents(MOVIE, gotContent);

        var label :Text = new Text(Text.HUGE_HARD_ITALIC, 0xFFFFFF, 0x264C62);
        label.text = "Select your bid:";
        label.bottomY = LABEL_BOTTOM;
        addChild(label);

        _bids.addEventListener(BidEvent.REQUESTED, bidListener);
        _bids.addEventListener(BidEvent.SELECTED, bidListener);

        visible = false;

        function gotContent (movie :DisplayObjectContainer) :void {
            _movie = movie;

            Debug.debug("Normal movie is " + _movie.width + " x " + _movie.height);

            _movie.x = -_movie.width / 2 + MOVIE_FUDGE_OFFSET;
            _movie.y = -_movie.height / 2;

            addChild(_movie);

            setupButtons();
        }
    }

    protected function bidListener (event :BidEvent) :void
    {
        if (event.type == BidEvent.REQUESTED) {
            // values < 0 are reserved for special bid requests
            if (event.value >= 0) {
                visible = true;
                setMaxBid(event.value);
            }
        }
        else if (event.type == BidEvent.SELECTED) {
            // values < 0 are reserved for special bid requests
            if (event.value >= 0) {
                visible = false;
            }
        }
    }

    protected function setMaxBid (max :int) :void
    {
        _maxBid = max;
        if (_movie != null) {
            for (var i :int = 1; i < NUM_BUTTONS; ++i) {
                getButton(i).visible = (i <= _maxBid);
            }
        }
    }

    /** Add all the button listeners and take into account the maximum bid. */
    protected function setupButtons () :void
    {
        for (var i :int = 0; i < NUM_BUTTONS; ++i) {
            getButton(i).addEventListener(MouseEvent.CLICK, clickListener);
        }

        // redo previous call to setMaxBid if any
        setMaxBid(_maxBid);
    }

    /** Get the button for a given bid amount. */
    protected function getButton (num :int) :SimpleButton
    {
        return Structure.requireButton(_movie.getChildAt(0), buttonName(num));
    }

    /** Dispatch a click on a bid to the game model. */
    protected function clickListener (event :MouseEvent) :void
    {
        var butt :SimpleButton = SimpleButton(event.target);
        Debug.debug("Button pressed: " + butt.name);
        var num :int = buttonNumber(butt.name);
        if (num <= _maxBid) {
            _bids.select(num);
            visible = false;
        }
    }

    /** Retrieve the name of a button for a given bid value. */
    protected static function buttonName (number :int) :String
    {
        return BUTTON_NAME_PREFIX + number;
    }

    /** Retrieve the number of a button of a given name. */
    protected static function buttonNumber (name :String) :int
    {
        return parseInt(name.slice(BUTTON_NAME_PREFIX.length));
    }

    protected var _bids :Bids;
    protected var _movie :DisplayObjectContainer;
    protected var _maxBid :int;

    [Embed(source="../../../rsrc/bidding_normal.swf", mimeType="application/octet-stream")]
    protected static const MOVIE :Class;

    // for the love of grep, this is the name of the 1st button from which all names are calculated
    protected static const BUTTON_NAME_TEMPLATE :String = "button_0";

    protected static const BUTTON_NAME_PREFIX :String = 
        BUTTON_NAME_TEMPLATE.slice(
            0, BUTTON_NAME_TEMPLATE.indexOf("0"));

    protected static const LABEL_BOTTOM :int = -23;

    protected static const NUM_BUTTONS :int = 14;

    protected static const MOVIE_FUDGE_OFFSET :int = -3;
}

}
