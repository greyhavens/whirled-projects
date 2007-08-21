package {

import flash.geom.Point;
import mx.containers.Canvas;

public class Cursor
{
    public function Cursor (game :Game, display :Display) 
    {
        _game = game;
        _display = display;
    }

    public function setCursorType (type :int) :void
    {
        if (_tower != null) {
            _tower.removeFromDisplay();
            _tower = null;
        }
        _tower = new Tower(type, _game);
        _tower.addToDisplay(_display);
    }

    public function setBoardLocation (x :int, y :int) :void
    {
        _tower.setBoardLocation(x, y);
    }

    public function getTower () :Tower
    {
        return _tower;
    }

    protected var _game :Game;
    protected var _display :Display;
    protected var _tower :Tower;
}
}
