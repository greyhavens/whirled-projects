//
// $Id$

package dictattack {

import flash.display.Sprite;

import com.whirled.game.GameControl;

/**
 * Contains references to the various bits used in the game.
 */
public class Context
{
    public function get top () :DictionaryAttack
    {
        return _top;
    }

    public function get control () :GameControl
    {
        return _control;
    }

    public function get model () :Model
    {
        return _model;
    }

    public function get content () :Content
    {
        return _content;
    }

    public function get view () :GameView
    {
        return _view;
    }

    public function Context (top :DictionaryAttack, control :GameControl, content :Content)
    {
        _top = top;
        _control = control;
        _content = content;
    }

    public function init (model :Model, view :GameView) :void
    {
        _model = model;
        _view = view;
    }

    protected var _top :DictionaryAttack;
    protected var _control :GameControl;
    protected var _content :Content;

    protected var _model :Model;
    protected var _view :GameView;
}
}
