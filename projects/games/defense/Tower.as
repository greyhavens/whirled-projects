package {

import flash.geom.Rectangle;
    
/**
 * Definition of a single tower, including all state information, and a pointer to display object.
 */
public class Tower
{
    public static const TYPE_SIMPLE :int = 0;

    public var type :int;

    public function Tower (type :int, game :Game)
    {
        this.type = type;
        _game = game;
        _location = new Rectangle(0, 0, 2, 2); // todo: this will change based on type
    }

    public function getBoardLocation () :Rectangle
    {
        return _location;
    }

    public function setBoardLocation (x :int, y :int, isCursor :Boolean = false) :void
    {
        _location.x = x;
        _location.y = y;
        if (_sprite == null) {
            return;
        }

        if (isOnBoard()) {
            _sprite.updateLocation();
        }
        if (isCursor) {
            _sprite.updateAlpha();
        }
    }

    /** Is the tower inside board bounds? */
    public function isOnBoard () :Boolean
    {
        return (_location.left >= 0 && _location.top >= 0 &&
                _location.right <= _game.def.width &&
                _location.bottom <= _game.def.height);
    }

    /** Are all cells under the tower empty? Note: the tower could be out of bounds. */
    public function isOnFreeSpace () :Boolean
    {
        return _game.checkLocation(getBoardLocation());
    }        
    
    public function addToDisplay (display :Display) :void
    {
        if (_sprite != null) {
            throw new Error("TowerSprite already initialized!");
        }
        _sprite = new TowerSprite(this, display);
        _sprite.display.addTowerSprite(_sprite);
        _sprite.updateLocation();
    }

    public function removeFromDisplay () :void
    {
        _sprite.display.removeTowerSprite(_sprite);
        _sprite = null;
    }

    protected var _game :Game;
    protected var _sprite :TowerSprite;
    protected var _location :Rectangle;
}
}
