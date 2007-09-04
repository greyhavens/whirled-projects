package sprites {

import flash.geom.Point;

import mx.core.BitmapAsset;
import mx.core.IFlexDisplayObject;
import mx.controls.Image;

import units.Critter;

public class CritterSprite extends Image
{
    public function CritterSprite (critter :Critter)
    {
        _critter = critter;
        reloadAssets();
    }

    public function reloadAssets () :void
    {
        _assets = AssetFactory.makeCritterAssets(_critter);
        updateAngle(); // since we aren't moving yet, just loads the first one
    }

    /** Called after the critted had moved, updates the sprite's location and state accordingly. */
    public function update () :void
    {
        var pos :Point = Board.logicalToScreenPosition(_critter.pos.x, _critter.pos.y);
        this.x = pos.x + _bitmapOffset.x;
        this.y = pos.y + _bitmapOffset.y;

        updateAngle();
    }
    
    /** Adjusts animation frames to fit movement in the specified direction. */
    public function updateAngle () :void
    {
        var walkDir :int = -1;
        if (Math.abs(_critter.vel.y) > Math.abs(_critter.vel.x)) {
            walkDir = (_critter.vel.y >= 0) ? CritterAssets.WALK_DOWN : CritterAssets.WALK_UP;
        } else {
            walkDir = (_critter.vel.x >= 0) ? CritterAssets.WALK_RIGHT : CritterAssets.WALK_LEFT;
        }

        var walkAsset :IFlexDisplayObject = _assets.getWalkAsset(walkDir);
        if (walkAsset != this.source) {
            this.source = walkAsset;
            this.scaleX = _assets.screenWidth / source.width;
            this.scaleY = _assets.screenHeight / source.height;
            _bitmapOffset = new Point(Board.SQUARE_WIDTH / 2 - _assets.screenWidth / 2,
                                      Board.SQUARE_HEIGHT / 2 - _assets.screenHeight);
        }
    }

    protected var _assets :CritterAssets;
    protected var _critter :Critter;
    protected var _bitmapOffset :Point = new Point(0, 0);
}
}
