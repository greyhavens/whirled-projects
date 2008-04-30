package spades.graphics {

import flash.display.Sprite;
import flash.display.DisplayObjectContainer;
import flash.events.MouseEvent;
import flash.display.SimpleButton;

import com.threerings.util.MultiLoader;

import spades.Debug;
import com.whirled.contrib.card.trick.Bids;
import spades.card.SpadesBids;
import com.whirled.contrib.card.trick.BidEvent;

/** Represents the interface for bidding blind nil (yes/no). */
public class BlindNilBiddingSprite extends Sprite
{
    /** Create a new interface. The bids object is used to listen for requests for new bids and 
     *  show and hide the interface. */
    public function BlindNilBiddingSprite (bids :Bids)
    {
        _bids = bids;

        MultiLoader.getContents(MOVIE, gotContent);

        var label :Text = new Text(Text.HUGE_HARD_ITALIC, 0xFFFFFF, 0x264C62);
        label.text = "Bid Blind Nil?";
        label.bottomY = LABEL_BOTTOM;
        addChild(label);

        _bids.addEventListener(BidEvent.REQUESTED, bidListener);
        _bids.addEventListener(BidEvent.SELECTED, bidListener);

        visible = false;

        function gotContent (movie :DisplayObjectContainer) :void {
            _movie = movie;

            Debug.debug("Blind nil movie is " + _movie.width + " x " + _movie.height);

            _movie.x = -_movie.width / 2 + MOVIE_FUDGE_OFFSET;
            _movie.y = -_movie.height / 2;

            addChild(_movie);

            setupButtons();
        }
    }

    protected function bidListener (event :BidEvent) :void
    {
        if (event.type == BidEvent.REQUESTED) {
            if (event.value == SpadesBids.REQUESTED_BLIND_NIL) {
                visible = true;
            }
        }
        else if (event.type == BidEvent.SELECTED) {
            if (event.value == SpadesBids.SELECTED_BLIND_NIL || 
                event.value == SpadesBids.SELECTED_SHOW_CARDS) {
                visible = false;
            }
        }
    }

    /** Add all the button listeners. */
    protected function setupButtons () :void
    {
        getButton(BLIND_NIL).addEventListener(MouseEvent.CLICK, clickListener);
        getButton(SHOW_CARDS).addEventListener(MouseEvent.CLICK, clickListener);
    }

    /** Get the button by name. */
    protected function getButton (name :String) :SimpleButton
    {
        return Structure.requireButton(_movie.getChildAt(0), name);
    }

    /** Dispatch a click on a bid to the game model. */
    protected function clickListener (event :MouseEvent) :void
    {
        var butt :SimpleButton = SimpleButton(event.target);
        Debug.debug("Button pressed: " + butt.name);

        if (butt.name == BLIND_NIL) {
            _bids.select(SpadesBids.SELECTED_BLIND_NIL);
            visible = false;
        }
        else if (butt.name == SHOW_CARDS) {
            _bids.select(SpadesBids.SELECTED_SHOW_CARDS);
            visible = false;
        }
    }

    protected var _bids :Bids;
    protected var _movie :DisplayObjectContainer;

    [Embed(source="../../../rsrc/bidding_bnil.swf", mimeType="application/octet-stream")]
    protected static const MOVIE :Class;

    protected static const LABEL_BOTTOM :int = -23;

    protected static const BLIND_NIL :String = "button_blind";
    protected static const SHOW_CARDS :String = "button_show";

    // TODO: the movie has seemingly random width and native x offset
    protected static const MOVIE_FUDGE_OFFSET :int = -57;
}

}
