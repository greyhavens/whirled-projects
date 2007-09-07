package com.threerings.defense.sprites {

import flash.display.DisplayObject;
import flash.geom.Point;

import mx.controls.Image;

import com.threerings.defense.Board;
import com.threerings.defense.Level;
import com.threerings.defense.ui.Overlay;
import com.threerings.defense.units.Unit;

/**
 * Base class for sprites that display unit objects.
 */
public /* abstract */ class UnitSprite extends Image
{
    public static const STATE_INVALID :int = -1;
    public static const STATE_DEFAULT :int = 0; // deleteme!

    
    /** Offset in pixels from the image anchor hotspot, to the image upper-left coordinate. */
    public var assetOffset :Point = new Point(0, 0);

    public function UnitSprite (unit :Unit, level :Level)
    {
        _unit = unit;
        _level = level;

        loadAllAssets();
    }

    /** Called after the unit had moved, this function updates screen position and z-ordering
     *  of the sprite appropriately. */
    public function update () :void
    {
        var newstate :int = recomputeCurrentState();
        if (newstate != _currentState) {
            _currentState = newstate;
            _currentAsset = _allAssets[_currentState];
            this.source = _currentAsset;
        }
        this.x = _unit.centroidx;
        this.y = _unit.centroidy;
        adjustZOrder();
    }
    
    /** Returns the new state in which this sprite should be based on the unit.
     *  Subclasses should override this with a more meaningful algorithm. */
    public function recomputeCurrentState () :int
    {
        return STATE_DEFAULT;
    }

    override public function toString () :String
    {
        return "UnitSprite: " + _unit;
    }

    /** Loads all assets for this type of sprite. */
    protected function loadAllAssets () :void
    {
        _allAssets = _level.loadSpriteAssets(this);
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
    protected function getMyZOrder () :Number
    {
        return _unit.centroidy * Board.BOARD_WIDTH + _unit.centroidx;
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
    
    protected var _unit :Unit;
    protected var _level :Level;
    protected var _currentState :int = STATE_INVALID;
    protected var _currentAsset :DisplayObject;
    protected var _allAssets :Array; // of DisplayObject
}
}
