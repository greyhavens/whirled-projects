package com.threerings.defense.sprites {

import flash.geom.Point;

import mx.controls.Image;

import com.threerings.defense.Board;
import com.threerings.defense.units.Unit;

/**
 * Base class for sprites that display unit objects.
 */
public class UnitSprite extends Image
{
    /** Offset in pixels from the image anchor hotspot, to the image upper-left coordinate. */
    public var anchorOffset :Point = new Point(0, 0);

    public function UnitSprite (unit :Unit)
    {
        _unit = unit;
    }

    /** Called after the unit had moved, this function updates screen position and z-ordering
     *  of the sprite appropriately. */
    public function update () :void
    {
        this.x = _unit.centroidx + anchorOffset.x;
        this.y = _unit.centroidy + anchorOffset.y;
        adjustZOrder();
    }

    /** Called to refresh assets. */
    public function startReloadingAssets () :void
    {
        // todo: in the future this will be listener-based, if we load from external swfs
        reloadAssets();
        assetsReloaded();
    }

    override public function toString () :String
    {
        return "UnitSprite: " + _unit;
    }
    
    /** Asset loading, to be overridden by subclasses. */
    protected function reloadAssets () :void
    {
        // no op
    }

    /** Called after asset loading, displays the loaded asset. */
    protected function assetsReloaded () :void
    {
        anchorOffset.x = - _assets.screenWidth / 2;
        anchorOffset.y = - _assets.screenHeight;
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
        while (newindex > 1) {  // make sure the background at 0 stays at 0
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
        var sprite :UnitSprite = this.parent.getChildAt(index) as UnitSprite;
        return (sprite != null) ? sprite.getMyZOrder() : NaN;
    }
    
    protected var _unit :Unit;
    protected var _assets :UnitAssets;
}
}
