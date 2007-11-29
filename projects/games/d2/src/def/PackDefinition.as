package def {

import flash.display.BitmapData;

import com.threerings.util.EmbeddedSwfLoader;

    
public class PackDefinition
{
    public var guid :String;
    public var name :String;
    public var icon :BitmapData;

    public var boards :Array = new Array(); // of BoardDefinition
    
    public function PackDefinition (swf :EmbeddedSwfLoader, settings :XML)
    {
        this.name = settings.@packname;
        this.guid = this.name;  // for now...

        var iconclass :Class = swf.getClass(settings.@packicon);
        this.icon = BitmapData(new iconclass(0, 0));
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

    public function toString () :String
    {
        return "[Pack name=" + name + ", boardCount=" + boards.length + "]";
    }
}
}
