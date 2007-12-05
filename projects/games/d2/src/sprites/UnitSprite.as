package sprites {
    
import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.geom.Point;

import mx.controls.Image;
import mx.containers.Canvas;

import game.Board;
import ui.Overlay;
import units.Unit;

import com.threerings.util.Assert;

/**
 * Base class for sprites that display unit objects. Do not instantiate directly.
 */
public /* abstract */ class UnitSprite extends Canvas
{
    public static const STATE_INVALID :int = -1;
    
    /** Offset in pixels from the image anchor hotspot, to the image upper-left coordinate. */
    public var assetOffset :Point = new Point(0, 0);

    public function UnitSprite (unit :Unit, board :Board)
    {
        _unit = unit;
        _board = board;

        _sprite = new Image();

        loadAllAssets();
    }

    /** Called after the unit had moved, this function updates screen position and z-ordering
     *  of the sprite appropriately. */
    public function update () :void
    {
        var newstate :int = recomputeCurrentState();
        if (newstate != _currentState) {
            // set new state asset
            _currentState = newstate;
            _currentAsset = _allAssets[_currentState];
            _sprite.source = _currentAsset;
            // if the new asset is a movie, rewind it and play from the first frame
            if (_currentAsset is MovieClip) {
                (_currentAsset as MovieClip).gotoAndPlay(0);
            }
        }
        this.x = _unit.centroidx + _tileOffset.x;
        this.y = _unit.centroidy + _tileOffset.y; 
        adjustZOrder();
    }
    
    /** Returns the new state in which this sprite should be based on the unit.
     *  Subclasses should override this with a more meaningful algorithm. */
    public function recomputeCurrentState () :int
    {
        return STATE_INVALID;
    }
    
    override public function toString () :String
    {
        return "UnitSprite: " + _unit;
    }

    override protected function createChildren () :void
    {
        super.createChildren();
        
        addChild(_sprite);
    }
    
    /**
     * Abstract function, loads assets specific to this type of sprite.
     * Default implementation loads nothing; children should override it.
     */
    protected /* abstract */ function loadStateAssets () :Array // of DisplayObject
    {
        return [ ]; // ignore
    }

    /** Loads all assets for this type of sprite. */
    protected function loadAllAssets () :void
    {
        _allAssets = loadStateAssets();
        Assert.isTrue(_allAssets != null && _allAssets.length > 0);
        
        update();
    }
   
    /**
     * Called after a position update, adjusts this sprite's z order with regard to other
     * sprites. Most of the time, the order will only need to be shifted up or down by a bit,
     * so bubble sort works just fine.
     */
    protected function adjustZOrder () :void
    {
        if (this.parent == null) {
            return; // we haven't been added to the display list yet. 
        }
        
        // what's our current location?
        var oldindex :int = this.parent.getChildIndex(this);
        var newindex :int = oldindex;

        var myz :Number = getMyZOrder();

        // see if we need to get pushed back
        while (newindex > 0) {  
            if (getZOfChildAt(newindex - 1) < myz) {
                break;
            }
            newindex--;
        }

        // see if we need to get pushed forward
        if (newindex == oldindex) {
            var lastindex :int = this.parent.numChildren - 1;
            while (newindex < lastindex) {
                if (getZOfChildAt(newindex + 1) > myz) {
                    break;
                }
                newindex++;
            }
        }

        if (newindex != oldindex) {
            this.parent.setChildIndex(this, newindex);
        }
    }

    /**
     * Collapses board position into a single positional number, which increases in a row-major
     * way, left to right, top to bottom, based on the unit's anchor position.
     * The resulting total ordering can be used for z-order adjustment.
     */
    protected function getMyZOrder (isFlying :Boolean = false) :Number
    {
        var ordering :Number = _unit.centroidy * _board.boardWidth + _unit.centroidx;
        if (isFlying) {
            ordering += _board.boardWidth * _board.boardHeight; // offset to push in front
        }

        return ordering;
    }

    /** Helper function that wraps getMyZOrder in a retrieval operation. */
    protected function getZOfChildAt (index :int) :Number
    {
        var obj :DisplayObject = this.parent.getChildAt(index);
        if (obj is UnitSprite) {
            return (obj as UnitSprite).getMyZOrder();
        } else {
            return (obj is Overlay) ? 1 : NaN;
        }
    }

    protected var _board :Board;
    protected var _unit :Unit;

    protected var _sprite :Image;
    
    protected var _tileOffset :Point = new Point(0, 0);
    protected var _currentState :int = STATE_INVALID;
    protected var _currentAsset :DisplayObject;
    protected var _allAssets :Array; // of DisplayObject
}
}
    
