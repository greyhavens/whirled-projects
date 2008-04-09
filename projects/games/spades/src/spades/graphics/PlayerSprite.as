package spades.graphics {

import flash.display.Sprite;
import flash.display.DisplayObject;
import flash.display.Bitmap;
import flash.filters.DropShadowFilter;

import com.threerings.util.MultiLoader;

import spades.Debug;
import spades.card.Team;

import caurina.transitions.Tweener;

/**
 * Flash object for a player sitting at a trick-taking card game. This is a placeholder for 
 * something nicer, so only the interface is documented in detail.
 */
public class PlayerSprite extends Sprite
{
    /** Create a new player. */
    public function PlayerSprite (name :String, team :Team)
    {
        _team = team;

        // TODO: fix drop shadow
        _headShadow = new DropShadowFilter(7, 45, 0x000000, 1, 4, 4, 102);

        MultiLoader.getContents(TEAM_IMAGES[team.index] as Class, gotBackground);

        var colors :Array = TEXT_COLORS[team.index] as Array;

        var nameField :Text = new Text(
            Text.BIG, colors[0] as uint, colors[1] as uint);
        addChild(nameField);

        nameField.centerY = -HEIGHT / 3;
        nameField.text = Text.truncName(name);

        setTurn(false);

        function gotBackground (background :Bitmap) :void
        {
            _background = background;
            addChildAt(_background, 0);

            _background.x = -_background.width / 2;
            _background.y = -_background.height / 2;

            _background.visible = _turn;
        }
    }

    /** Set the player head shot. */
    public function setHeadShot (headShot :DisplayObject) :void
    {
        if (_headShot != null) {
            removeChild(_headShot);
            _headShot = null;
        }
        _headShot = headShot;
        _headShot.filters = [_headShadow];
        _headShot.x = -_headShot.width / 2;
        _headShot.y = -_headShot.height / 2;
        addChild(_headShot);
    }

    /** Update to reflect the turn status.
     *  @param turn indicates whether it is this player's turn */
    public function setTurn (turn :Boolean) :void
    {
        // TODO: tween drop shadow
        _turn = turn;

        if (_background == null) {
            return;
        }

        Tweener.removeTweens(_background);

        if (turn) {
            _background.visible = true;
        }

        var tween :Object = {
            alpha: turn ? 1.0 : 0.0,
            time: 1.0
        };

        if (!turn) {
            tween.onComplete = makeInvisible;
        }

        Tweener.addTween(_background, tween);

        function makeInvisible () :void {
            _background.visible = false;
        }
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

    protected var _team :Team;
    protected var _background :Bitmap;
    protected var _headShot :DisplayObject;
    protected var _turn :Boolean;
    protected var _headShadow :DropShadowFilter;
    protected var _caption :Text;

    protected static const WIDTH :int = 165;
    protected static const HEIGHT :int = 115;

    [Embed(source="../../../rsrc/turn_blue.png", mimeType="application/octet-stream")]
    protected static const IMAGE_TEAM_0 :Class;

    [Embed(source="../../../rsrc/turn_orange.png", mimeType="application/octet-stream")]
    protected static const IMAGE_TEAM_1 :Class;

    protected static const TEAM_IMAGES :Array = [IMAGE_TEAM_0, IMAGE_TEAM_1];

    protected static const WARNING_COLOR :uint = 0xFF2525;
    protected static const CAPTION_COLOR :uint = 0xFFFFFF;
    protected static const CAPTION_OUTLINE_COLORS :Array = [0x4186Af, 0xA86C04];

    protected static const TEXT_COLORS :Array = [
        [0xB7E8Fb, 0x153741], 
        [0xFFD461, 0x382407]]
}

}

