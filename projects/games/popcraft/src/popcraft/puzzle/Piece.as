package popcraft.puzzle {

import com.whirled.contrib.simplegame.objects.*;
import com.whirled.contrib.simplegame.resource.*;
import com.whirled.contrib.simplegame.tasks.*;

import flash.display.DisplayObject;
import flash.display.Graphics;
import flash.display.MovieClip;
import flash.display.Sprite;

import popcraft.*;
import popcraft.data.ResourceData;
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
        // load the piece classes if they aren't already loaded
        if (null == SWF_CLASSES) {
            SWF_CLASSES = [];
            var swf :SwfResourceLoader = (ResourceManager.instance.getResource("puzzlePieces") as SwfResourceLoader);
            for each (var className :String in SWF_CLASS_NAMES) {
                SWF_CLASSES.push(swf.getClass(className));
            }
        }

        _resourceType = newType;

        var pieceClass :Class = SWF_CLASSES[newType];
        var pieceMovie :MovieClip = new pieceClass();

        var scaleX :Number = Constants.PUZZLE_TILE_SIZE / pieceMovie.width;
        var scaleY :Number = Constants.PUZZLE_TILE_SIZE / pieceMovie.height;

        pieceMovie.scaleX = scaleX;
        pieceMovie.scaleY = scaleY;

        pieceMovie.x = -(pieceMovie.width * 0.5);
        pieceMovie.y = -(pieceMovie.height * 0.5);

		pieceMovie.cacheAsBitmap = true;

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
        var resourceData :ResourceData = GameContext.gameData.resources[_resourceType];

        g.clear();
        g.beginFill(resourceData.color);

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

    protected static var SWF_CLASSES :Array;
    protected static const SWF_CLASS_NAMES :Array = [ "A", "B", "C", "D" ];
}

}
