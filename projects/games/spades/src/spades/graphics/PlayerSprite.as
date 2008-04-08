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
        _headShadow = new DropShadowFilter(7, 45, 0x000000, 1, 4, 4, 102);

        MultiLoader.getContents(TEAM_IMAGES[team.index] as Class, gotBackground);

        var nameField :Text = new Text(Text.BIG);
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

    public function setHeadShot (headShot :DisplayObject, success :Boolean) :void
    {
        if (_headShot != null) {
            removeChild(_headShot);
            _headShot = null;
        }
        _headShot = headShot;
        _headShot.filters = [_headShadow];
        addChild(_headShot);
    }

    /** Update to reflect the turn status.
     *  @param turn indicates whether it is this player's turn */
    public function setTurn (turn :Boolean) :void
    {
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

    protected var _background :Bitmap;
    protected var _headShot :DisplayObject;
    protected var _turn :Boolean;
    protected var _headShadow :DropShadowFilter;

    protected static const WIDTH :int = 165;
    protected static const HEIGHT :int = 115;

    [Embed(source="../../../rsrc/turn_blue.png", mimeType="application/octet-stream")]
    protected static const IMAGE_TEAM_0 :Class;

    [Embed(source="../../../rsrc/turn_orange.png", mimeType="application/octet-stream")]
    protected static const IMAGE_TEAM_1 :Class;

    protected static const TEAM_IMAGES :Array = [IMAGE_TEAM_0, IMAGE_TEAM_1];
}

}

