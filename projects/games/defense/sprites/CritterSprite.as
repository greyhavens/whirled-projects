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
        startReloadingAssets();
    }

    public function get critter () :Critter
    {
        return _unit as Critter;
    }

    public function get assets () :CritterAssets
    {
        return _assets as CritterAssets;
    }
    
    override public function update () :void
    {
        super.update();
        updateAngle();
    }
    
    override protected function reloadAssets () :void
    {
        _assets = AssetFactory.makeCritterAssets(critter);
        updateAngle(); // since we aren't moving yet, just loads the first one
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

        var walkAsset :IFlexDisplayObject = assets.getWalkAsset(walkDir);
        if (walkAsset != this.source) {
            this.source = walkAsset;
            this.scaleX = assets.screenWidth / source.width;
            this.scaleY = assets.screenHeight / source.height;
        }
    }
}
}
