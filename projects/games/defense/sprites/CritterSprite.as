package sprites {

import flash.geom.Point;

import mx.core.BitmapAsset;
import mx.core.IFlexDisplayObject;
import mx.controls.Image;

import units.Critter;

public class CritterSprite extends UnitSprite
{
    public function CritterSprite (critter :Critter)
    {
        super(critter);
        reloadAssets();
    }

    public function get critter () :Critter
    {
        return _unit as Critter;
    }
    
    public function reloadAssets () :void
    {
        _assets = AssetFactory.makeCritterAssets(critter);
        updateAngle(); // since we aren't moving yet, just loads the first one
    }

    /** Called after the critted had moved, updates the sprite's location and state accordingly. */
    public function update () :void
    {
        this.x = _unit.centroidx + _bitmapOffset.x;
        this.y = _unit.centroidy + _bitmapOffset.y;

        trace("CRITTER POS: " + this.x + ", " + this.y);
        updateAngle();
    }
    
    /** Adjusts animation frames to fit movement in the specified direction. */
    public function updateAngle () :void
    {
        var walkDir :int = -1;
        if (Math.abs(critter.vel.y) > Math.abs(critter.vel.x)) {
            walkDir = (critter.vel.y >= 0) ? CritterAssets.WALK_DOWN : CritterAssets.WALK_UP;
        } else {
            walkDir = (critter.vel.x >= 0) ? CritterAssets.WALK_RIGHT : CritterAssets.WALK_LEFT;
        }

        var walkAsset :IFlexDisplayObject = _assets.getWalkAsset(walkDir);
        if (walkAsset != this.source) {
            this.source = walkAsset;
            this.scaleX = _assets.screenWidth / source.width;
            this.scaleY = _assets.screenHeight / source.height;
            _bitmapOffset = new Point(- _assets.screenWidth / 2, - _assets.screenHeight);
        }
    }

    protected var _assets :CritterAssets;
    protected var _bitmapOffset :Point = new Point(0, 0);
}
}
