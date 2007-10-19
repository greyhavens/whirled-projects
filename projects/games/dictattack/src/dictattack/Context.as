//
// $Id$

package dictattack {

import com.whirled.WhirledGameControl;

/**
 * Contains references to the various bits used in the game.
 */
public class Context
{
    public function get control () :WhirledGameControl
    {
        return _control;
    }

    public function get model () :Model
    {
        return _model;
    }

//     public function get board () :Board
//     {
//         return _board;
//     }

    public function get content () :Content
    {
        return _content;
    }

    public function get view () :GameView
    {
        return _view;
    }

    public function Context (control :WhirledGameControl, content :Content)
    {
        _control = control;
        _content = content;
    }

    public function init (model :Model /*, board :Board */, view :GameView) :void
    {
        _model = model;
//         _board = board;
        _view = view;
    }

    protected var _control :WhirledGameControl;
    protected var _content :Content;

    protected var _model :Model;
//     protected var _board :Board;
    protected var _view :GameView;
}
}
