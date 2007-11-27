package def {

import flash.display.DisplayObject;
import flash.display.LoaderInfo;
import flash.geom.Point;

import com.threerings.util.EmbeddedSwfLoader;
import com.whirled.DataPack;

/**
 * Board definition from an xml settings file, with extra info retrieval, and typesafe variables.
 */
public class BoardDefinition
{
    public var swf :EmbeddedSwfLoader;
    
    public var name :String;
    public var icon :String;
    public var background :String;

    public var squares :Point;
    public var pixelsize :Point;
    public var topleft :Point;
        
    public function BoardDefinition (swf :EmbeddedSwfLoader, board :XML)
    {
        this.swf = swf;
        
        trace("Board name: " + board.@name);
        this.name = board.@name;
        this.icon = board.@icon;
        this.background = board.@background;
        
        this.squares = new Point(int(board.squares.@cols), int(board.squares.@rows));
        this.pixelsize = new Point(int(board.pixelsize.@width), int(board.pixelsize.@height));
        this.topleft = new Point(int(board.topleft.@x), int(board.topleft.@y));

        // info.applicationDomain.getDefinition(symbolName)
    }

            

    public function toString () :String
    {
        return "[Board name=" + name + ", swf=" + swf + "]";
    }
}
}
