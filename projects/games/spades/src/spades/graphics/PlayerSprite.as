package spades.graphics {

import flash.display.Sprite;
import flash.display.DisplayObject;
import flash.display.Bitmap;
import flash.filters.DropShadowFilter;
import flash.geom.Point;

import com.threerings.util.MultiLoader;
import com.threerings.util.Assert;

import spades.Debug;
import spades.card.Team;
import spades.card.TurnTimer;
import spades.card.TurnTimerEvent;
import spades.card.Table;

import caurina.transitions.Tweener;


/**
 * Flash object for a player sitting at a trick-taking card game. This is a placeholder for 
 * something nicer, so only the interface is documented in detail.
 */
public class PlayerSprite extends Sprite
{
    /** Create a new player. */
    public function PlayerSprite (
        table :Table,
        id :int, 
        timer :TurnTimer)
    {
        _team = table.getTeamFromId(id);
        _id = id;

        // TODO: fix drop shadow
        _headShot = new HeadShotContainer();
        addChild(_headShot);

        _timer = new TimerMovie(TEAM_TIMERS[_team.index] as Class);
        _timer.x = TIMER_POS.x;
        _timer.y = TIMER_POS.y;
        _timer.alpha = 0.0;
        addChild(_timer);

        MultiLoader.getContents(TEAM_IMAGES[_team.index] as Class, gotBackground);

        var colors :Array = TEXT_COLORS[_team.index] as Array;

        var nameField :Text = new Text(
            Text.BIG, colors[0] as uint, colors[1] as uint);
        addChild(nameField);

        nameField.centerY = -HEIGHT / 3;
        nameField.text = Text.truncName(table.getNameFromId(id));

        setTurn(false);

        timer.addEventListener(TurnTimerEvent.STARTED, turnTimerListener);

        function gotBackground (background :Bitmap) :void
        {
            _background = background;
            addChildAt(_background, 0);

            _background.x = -_background.width / 2;
            _background.y = -_background.height / 2;

            _background.alpha = _turn ? 1.0 : 0.0;
        }
    }

    /** Set the player head shot. */
    public function setHeadShot (headShot :DisplayObject) :void
    {
        var alpha :Number = _turn ? 0.0 : DROP_SHADOW_MAX_ALPHA;
        _headShot.setImage(headShot, new DropShadowFilter(
            6, 45, 0x000000, alpha, 10, 10, 2));
    }

    /** Update to reflect the turn status.
     *  @param turn indicates whether it is this player's turn */
    public function setTurn (turn :Boolean) :void
    {
        _turn = turn;

        if (_background == null) {
            return;
        }

        _timer.stop();
        if (turn) {
            _timer.reset();
        }

        Tweener.removeTweens(_background);
        Tweener.removeTweens(_timer);
        Tweener.removeTweens(_headShot);

        var tween :Object = {alpha : turn ? 1.0 : 0.0, time : 1.0};

        Tweener.addTween(_background, tween);
        Tweener.addTween(_timer, tween);
        Tweener.addTween(_headShot, {
            dropShadowAlpha : turn ? 0.0 : DROP_SHADOW_MAX_ALPHA,
            time : 1.0
        });
    }

    /** Display a warning for this player. 
     *  TODO: make protected and listen for warning events in subclasses. */
    public function showCaption (str :String, warning :Boolean=false) :void
    {
        if (_caption != null) {
            removeChild(_caption);
            _caption = null;
        }

        if (str.length > 0) {
            var fcolor :uint = warning ? WARNING_COLOR : CAPTION_COLOR;
            var bcolor :uint = uint(CAPTION_OUTLINE_COLORS[_team.index]);
            _caption = new Text(Text.BIG, fcolor, bcolor);
            _caption.centerY = HEIGHT / 3;
            _caption.text = str;
            addChild(_caption);
        }
    }

    protected function turnTimerListener (event :TurnTimerEvent) :void
    {
        if (event.type == TurnTimerEvent.STARTED) {
            if (event.player == _id) {
                _timer.start(event.time);
            }
        }
    }

    protected var _team :Team;
    protected var _id :int;
    protected var _background :Bitmap;
    protected var _headShot :HeadShotContainer;
    protected var _turn :Boolean;
    protected var _caption :Text;
    protected var _timer :TimerMovie;

    protected static const WIDTH :int = 165;
    protected static const HEIGHT :int = 115;

    [Embed(source="../../../rsrc/turn_blue.png", mimeType="application/octet-stream")]
    protected static const IMAGE_TEAM_0 :Class;

    [Embed(source="../../../rsrc/turn_orange.png", mimeType="application/octet-stream")]
    protected static const IMAGE_TEAM_1 :Class;

    [Embed(source="../../../rsrc/clock_blue.swf", mimeType="application/octet-stream")]
    protected static const TIMER_TEAM_0 :Class;

    [Embed(source="../../../rsrc/clock_orange.swf", mimeType="application/octet-stream")]
    protected static const TIMER_TEAM_1 :Class;

    protected static const TEAM_IMAGES :Array = [IMAGE_TEAM_0, IMAGE_TEAM_1];
    protected static const TEAM_TIMERS :Array = [TIMER_TEAM_0, TIMER_TEAM_1];

    protected static const WARNING_COLOR :uint = 0xFF2525;
    protected static const CAPTION_COLOR :uint = 0xFFFFFF;
    protected static const CAPTION_OUTLINE_COLORS :Array = [0x4186Af, 0xA86C04];

    protected static const TEXT_COLORS :Array = [
        [0xB7E8Fb, 0x153741], 
        [0xFFD461, 0x382407]];

    protected static const TIMER_POS :Point = new Point(62, 36);

    protected static const DROP_SHADOW_MAX_ALPHA :Number = 0.5;
}

}


import flash.display.Sprite;
import flash.display.DisplayObject;
import flash.filters.DropShadowFilter;

/** Contains a player's head shot and manages the alpha of the drop shadow filter as a property
 *  (this is otherwise quite annoying and ugly to do with Tweener). */
class HeadShotContainer extends Sprite
{
    /** Creates a new empty head shot container. */
    public function HeadShotContainer ()
    {
    }

    /** Set the head shot to use inside the container.
     *  @param headShot the image to use
     *  @param filter the drop shadow filter to be assigned to the head shot */
    public function setImage (
        headShot :DisplayObject, 
        filter :DropShadowFilter) :void
    {
        if (_image != null) {
            removeChild(_image);
            _image = null;
        }

        _image = headShot;

        if (_image != null) {
            _image.x = -_image.width / 2;
            _image.y = -_image.height / 2;
            _image.filters = [filter]
            addChild(_image);
        }
    }

    /** Access the alpha property of the drop shadow filter. Automatically takes care of
     *  reinitializing the head shot's filter array. */
    public function set dropShadowAlpha (alpha :Number) :void
    {
        if (_image == null) {
            return;
        }

        // the filter cannot be modified directly, only on a temporary array
        // (see adobe docs for DisplayObject.filters)
        var f :Array = _image.filters;
        f[0].alpha = alpha;
        _image.filters = f;
    }

    /** Access the alpha property of the drop shadow filter (required for tweening). */
    public function get dropShadowAlpha () :Number
    {
        if (_image == null) {
            return 0;
        }
        return _image.filters[0].alpha;
    }

    protected var _image :DisplayObject;
}

