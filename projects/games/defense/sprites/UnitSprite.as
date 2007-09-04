package sprites {

import flash.geom.Point;

import mx.controls.Image;

import units.Unit;

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
    }

    /** Called to refresh assets. */
    public function startReloadingAssets () :void
    {
        // todo: in the future this will be listener-based, if we load from external swfs
        reloadAssets();
        assetsReloaded();
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

    protected var _unit :Unit;
    protected var _assets :UnitAssets;
}
}
