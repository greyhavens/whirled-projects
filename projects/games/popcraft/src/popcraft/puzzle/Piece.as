package popcraft.puzzle {

import com.whirled.contrib.simplegame.objects.*;
import com.whirled.contrib.simplegame.resource.SwfResourceLoader;
import com.whirled.contrib.simplegame.tasks.*;

import flash.display.DisplayObject;
import flash.display.Graphics;
import flash.display.MovieClip;
import flash.display.Shape;
import flash.display.Sprite;
import flash.filters.GlowFilter;

import popcraft.*;
import popcraft.util.*;

public class Piece extends SceneObject
{
    public function Piece (resourceType :uint, boardIndex :int)
    {
        this.resourceType = resourceType;

        _boardIndex = boardIndex;
    }
    
    /*override protected function addedToDB () :void
    {
        this.db.addObject(_pieceHiliteObj, _sprite);
    }*/

    // from SceneObject
    override public function get displayObject () :DisplayObject
    {
        return _sprite;
    }

    public function get boardIndex () :int
    {
        return _boardIndex;
    }

    public function set boardIndex (newIndex :int) :void
    {
        _boardIndex = newIndex;
    }

    public function get resourceType () :uint
    {
        return _resourceType;
    }

    public function set resourceType (newType :uint) :void
    {
        _resourceType = newType;
        
        var swf :SwfResourceLoader = (AppContext.resources.getResource("puzzlePieces") as SwfResourceLoader);
        var pieceClass :Class = swf.getClass(SWF_CLASS_NAMES[newType]);
        var pieceMovie :MovieClip = new pieceClass();
        
        var scaleX :Number = Constants.PUZZLE_TILE_SIZE / pieceMovie.width;
        var scaleY :Number = Constants.PUZZLE_TILE_SIZE / pieceMovie.height;
        
        pieceMovie.scaleX = scaleX;
        pieceMovie.scaleY = scaleY;
        
        pieceMovie.x = -(pieceMovie.width * 0.5);
        pieceMovie.y = -(pieceMovie.height * 0.5);
        
        /*var pieceHilite :Shape = new Shape();
        
        _pieceHiliteObj = new SimpleSceneObject(pieceHilite);
        _pieceHiliteObj.visible = false;
        
        var glowFilter :GlowFilter = new GlowFilter();
        glowFilter.color = Constants.getResource(_resourceType).color;
        glowFilter.alpha = 1;
        glowFilter.strength = 16;
        glowFilter.knockout = false;
        
        pieceHilite.filters = [ glowFilter ]; */
        
        _sprite = new Sprite();
        _sprite.mouseChildren = false;
        _sprite.mouseEnabled = false;
        
        _sprite.addChild(pieceMovie);
    }
    
    protected function drawPiece (g :Graphics, drawOutline :Boolean, radius :Number) :void
    {
        g.clear();
        g.beginFill(Constants.getResource(_resourceType).color);
        
        if (drawOutline) {
            g.lineStyle(1, 0);
        }
        
        g.drawCircle(0, 0, radius);
        
        g.endFill();
    }
    
    public function showHilite (show :Boolean) :void
    {
        /*if (show != _showHilite) {
            
            if (!show) {
                _pieceHiliteObj.removeAllTasks();
                _pieceHiliteObj.visible = false;
            } else {
                _pieceHiliteObj.visible = true;
                _pieceHiliteObj.alpha = 1;
                
                _pieceHiliteObj.addTask(new RepeatingTask(
                    new AlphaTask(0.5, 0.3),
                    new AlphaTask(1, 0.3)));
            }
            
            _showHilite = show;
        }*/
    }

    protected var _boardIndex :int;

    protected var _resourceType :uint;
    protected var _sprite :Sprite;
   // protected var _pieceHiliteObj :SimpleSceneObject;
    
    protected var _showHilite :Boolean;
    
    protected static const SWF_CLASS_NAMES :Array = [ "A", "B", "C", "D" ];
}

}
