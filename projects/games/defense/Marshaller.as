package {

/**
 * Helper class that handles class serialization for sending over the network.
 */
public class Marshaller
{
    public static function serializeTower (tower :Tower) :Object
    {
        return { def: serializeTowerDef(tower.def), player: tower.player, guid: tower.guid };
    }

    public static function unserializeTower (obj :Object) :Tower
    {
        return new Tower(unserializeTowerDef(obj.def), obj.player, obj.guid);
    }

    public static function serializeTowerDef (def :TowerDef) :Object
    {
        return { x: def.x, y: def.y, type: def.type };
    }

    public static function unserializeTowerDef (obj :Object) :TowerDef
    {
        return new TowerDef(obj.x, obj.y, obj.type);
    }

}
}
    
