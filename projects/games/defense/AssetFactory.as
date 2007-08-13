package {

import flash.display.DisplayObject;
import flash.events.Event;

public class AssetFactory
{
    public static const TOWER_DEFAULT :int = 1;
    
    /** Returns a new shape for the specified tower. */
    public static function makeTower (type :int) : DisplayObject
    {
        switch (type) {
        case TOWER_DEFAULT: return new _defaultTower ();
        default:
            throw new Error("Unknown tower type: " + type);
        }
    }

    [Embed(source="rsrc/tower.png")]
    private static const _defaultTower : Class;
}
}
