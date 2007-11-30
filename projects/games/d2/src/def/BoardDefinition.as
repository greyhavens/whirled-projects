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
    public var pack :PackDefinition;
    public var swf :EmbeddedSwfLoader;
    
    public var name :String;
    public var background :DisplayObject;
    public var button :DisplayObject;
    
    public var squares :Point;
    public var pixelsize :Point;
    public var topleft :Point;

    public var startingHealth :int;
    public var startingMoney :int;

    public var towers :Array; // of TowerDef
    
    public function BoardDefinition (swf :EmbeddedSwfLoader, pack :PackDefinition, board :XML)
    {
        this.pack = pack;
        this.swf = swf;
        
        this.name = board.@name;

        var bgclass :Class = this.swf.getClass(board.@background);
        this.background = (new bgclass()) as DisplayObject;

        var bclass :Class = this.swf.getClass(board.@button);
        this.button = (new bclass()) as DisplayObject;
        
        this.squares = new Point(int(board.squares.@cols), int(board.squares.@rows));
        this.pixelsize = new Point(int(board.pixelsize.@width), int(board.pixelsize.@height));
        this.topleft = new Point(int(board.topleft.@x), int(board.topleft.@y));

        this.startingHealth = board.@startingHealth;
        this.startingMoney = board.@startingMoney;
    }

    public function get guid () :String
    {
        return pack.name + ": " + name; 
    }
    
    public function toString () :String
    {
        return "[Board guid=" + guid + ", swf=" + swf + "]";
    }
}
}
