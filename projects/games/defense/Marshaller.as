package {

import units.Tower;

/**
 * Helper class that handles class serialization for sending over the network.
 */
public class Marshaller
{
    public static function serializeTower (tower :Tower) :Object
    {
        return { x: tower.x, y: tower.y, type: tower.type,
                player: tower.player, guid: tower.guid };
    }

    public static function unserializeTower (obj :Object) :Tower
    {
        return new Tower(obj.x, obj.y, obj.type, obj.player, obj.guid);
    }
}
}
    
