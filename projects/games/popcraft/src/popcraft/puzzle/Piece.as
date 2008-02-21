package popcraft.puzzle {

import com.whirled.contrib.core.objects.*;
import com.whirled.contrib.core.tasks.*;

import flash.display.DisplayObject;
import flash.display.Graphics;
import flash.display.Shape;
import flash.display.Sprite;

import popcraft.*;
import popcraft.util.*;

public class Piece extends SceneObject
{
    public function Piece (resourceType :uint, boardIndex :int)
    {
        _pieceSprite = new Sprite();
        _pieceHilite = new Shape();
        
        _pieceHiliteObj = new SimpleSceneObject(_pieceHilite);
        _pieceHiliteObj.visible = false;
        
        _pieceSprite.mouseEnabled = false;
        _pieceSprite.mouseChildren = false;
        
        this.resourceType = resourceType;

        _boardIndex = boardIndex;
    }
    
    override protected function addedToDB () :void
    {
        this.db.addObject(_pieceHiliteObj, _pieceSprite);
    }

    // from SceneObject
    override public function get displayObject () :DisplayObject
    {
        return _pieceSprite;
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
        
        var radius :Number = Constants.PUZZLE_TILE_SIZE * 0.5;

        // draw a circle centered on (0, 0)
        this.drawPiece(_pieceSprite.graphics, true, radius);
        
        // draw another hilited circle
        this.drawPiece(_pieceHilite.graphics, false, radius * 1.3);
        
        /*var glowFilter :GlowFilter = new GlowFilter();
        glowFilter.color = Constants.getResource(_resourceType).color;
        glowFilter.alpha = 1;
        glowFilter.strength = 16;
        glowFilter.knockout = false;
        
        _pieceHilite.filters = [ glowFilter ];*/
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
        if (show != _showHilite) {
            
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
        }
    }

    protected var _boardIndex :int;

    protected var _resourceType :uint;
    protected var _pieceSprite :Sprite;
    protected var _pieceHilite :Shape;
    protected var _pieceHiliteObj :SimpleSceneObject;
    
    protected var _showHilite :Boolean;
}

}
