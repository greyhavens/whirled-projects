package {

/**
 * Definition of a single tower, including all state information, and a pointer to display object.
 */
public class Tower
{
    public static const TYPE_SIMPLE :int = 0;
    
    public function Tower (type :int)
    {
        _type = type;
    }

    public function addToDisplay (display :Display) :void
    {
        if (_sprite != null) {
            throw new Error("TowerSprite already initialized!");
        }
        _sprite = new TowerSprite(_type, display);
        display.addTowerSprite(_sprite);
    }

    public function removeFromDisplay () :void
    {
        _sprite.display.removeTowerSprite(_sprite);
        _sprite = null;
    }

    protected var _sprite :TowerSprite;
    protected var _type :int;
}
}
