//
// $Id$

package popcraft.game.puzzle {

import com.threerings.flashbang.objects.*;
import com.threerings.flashbang.resource.*;
import com.threerings.flashbang.tasks.*;

import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.display.Sprite;

import popcraft.*;
import popcraft.util.*;

public class Piece extends SceneObject
{
    public function Piece (resourceType :int, boardIndex :int)
    {
        this.resourceType = resourceType;

        _boardIndex = boardIndex;
    }

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

    public function get resourceType () :int
    {
        return _resourceType;
    }

    public function set resourceType (newType :int) :void
    {
        // load the piece classes if they aren't already loaded
        if (null == SWF_CLASSES) {
            SWF_CLASSES = [];
            var swf :SwfResource = (ClientCtx.rsrcs.getResource("puzzlePieces") as SwfResource);
            for each (var className :String in SWF_CLASS_NAMES) {
                SWF_CLASSES.push(swf.getClass(className));
            }
        }

        _resourceType = newType;

        var pieceMovie :MovieClip = SpriteUtil.newMC(SWF_CLASSES[newType]);

        pieceMovie.x = -(pieceMovie.width * 0.5);
        pieceMovie.y = -(pieceMovie.height * 0.5);

        pieceMovie.cacheAsBitmap = true;

        _sprite = SpriteUtil.createSprite();
        _sprite.addChild(pieceMovie);
    }

    override protected function cleanup () :void
    {
        SpriteUtil.releaseMC(_sprite.getChildAt(0) as MovieClip);
        super.cleanup();
    }

    protected var _boardIndex :int;

    protected var _resourceType :int;
    protected var _sprite :Sprite;

    protected static var SWF_CLASSES :Array;
    protected static const SWF_CLASS_NAMES :Array = [ "A", "B", "C", "D" ];
}

}
