package def {

import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.geom.Point;

import com.threerings.util.EmbeddedSwfLoader;

/**
 * Board definition from an xml settings file, with extra info retrieval, and typesafe variables.
 */
public class BoardDefinition
{
    public var pack :String;
    public var swf :EmbeddedSwfLoader;
    
    public var name :String;
    public var background :DisplayObject;
    public var icon :BitmapData;
    
    public var squares :Point;
    public var pixelsize :Point;
    public var topleft :Point;
        
    public function BoardDefinition (swf :EmbeddedSwfLoader, pack :String, board :XML)
    {
        this.pack = pack;
        this.swf = swf;
        
        this.name = board.@name;

        var bgclass :Class = this.swf.getClass(board.@background);
        this.background = (new bgclass()) as DisplayObject;
        
        var iconclass :Class = this.swf.getClass(board.@icon);
        this.icon = BitmapData(new iconclass(0, 0));
        
        this.squares = new Point(int(board.squares.@cols), int(board.squares.@rows));
        this.pixelsize = new Point(int(board.pixelsize.@width), int(board.pixelsize.@height));
        this.topleft = new Point(int(board.topleft.@x), int(board.topleft.@y));
    }

    public function get guid () :String
    {
        return pack + "_" + name; 
    }
    
    public function toString () :String
    {
        return "[Board guid=" + guid + ", swf=" + swf + "]";
    }
}
}
