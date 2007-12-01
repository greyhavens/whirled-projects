package def {

import flash.display.DisplayObject;

import com.threerings.util.EmbeddedSwfLoader;

import units.Tower;

    
public class PackDefinition
{
    public var guid :String;
    public var name :String;
    public var button :DisplayObject;

    public var boards :Array = new Array(); // of BoardDefinition
    public var towers :Array = new Array(); // of TowerDefinition
    public var enemies :Array = new Array(); // of EnemyDefinition
    
    public function PackDefinition (swf :EmbeddedSwfLoader, settings :XML)
    {
        this.name = settings.@packname;
        this.guid = this.name;  // for now...

        var bclass :Class = swf.getClass(settings.@button);
        this.button = new bclass() as DisplayObject;
    }

    /** Finds an instance of BoardDefinition by guid. Returns null in case of failure. */
    public function findBoard (guid :String) :BoardDefinition
    {
        var result :BoardDefinition = null; 
        boards.forEach(function (board :BoardDefinition, ... etc) :void {
                if (board.guid == guid) {
                    result = board;
                }});
        return result;
    }

    /** Finds an instance of TowerDefinition by type. Returns null in case of failure. */
    public function findTower (typeName :String) :TowerDefinition
    {
        var result :TowerDefinition = null; 
        towers.forEach(function (tower :TowerDefinition, ... etc) :void {
                if (tower.typeName == typeName) {
                    result = tower;
                }});
        return result;
    }

    public function toString () :String
    {
        return "[Pack name=" + name + ", boardCount=" + boards.length + "]";
    }
}
}
