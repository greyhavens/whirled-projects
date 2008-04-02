package spades.graphics {

import flash.display.Sprite;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;

import caurina.transitions.Tweener;

/**
 * Flash object for a player sitting at a trick-taking card game. This is a placeholder for 
 * something nicer, so only the interface is documented in detail.
 */
public class PlayerSprite extends Sprite
{
    /** Create a new player. */
    public function PlayerSprite (name :String)
    {
        _background = new Sprite();
        addChild(_background);

        _background.graphics.clear();
        _background.graphics.beginFill(0x00FF00);
        _background.graphics.drawRect(-WIDTH / 2, -HEIGHT / 2, WIDTH, HEIGHT);
        _background.graphics.endFill();

        _background.visible = false;

        var nameField :TextField = new TextField();
        addChild(nameField);

        nameField.autoSize = TextFieldAutoSize.CENTER;
        nameField.x = 0;
        nameField.y = -HEIGHT / 2;
        nameField.text = name;
        nameField.selectable = false;

        setTurn(false);
    }

    public function setHeadShot (sprite :Sprite, success :Boolean) :void
    {
        if (_headShot != null) {
            removeChild(_headShot);
            _headShot = null;
        }
        _headShot = sprite;
        _headShot.x = -_headShot.width / 2;
        _headShot.y = -_headShot.height / 2;
        addChild(_headShot);
    }

    /** Update to reflect the turn status.
     *  @param turn indicates whether it is this player's turn */
    public function setTurn (turn :Boolean) :void
    {
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

    protected var _background :Sprite;
    protected var _headShot :Sprite;

    protected static const WIDTH :int = 165;
    protected static const HEIGHT :int = 115;
}

}

