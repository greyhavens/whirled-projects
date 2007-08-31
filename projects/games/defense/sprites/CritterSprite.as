package sprites {

import flash.geom.Point;
import mx.core.BitmapAsset;
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
        _assets = AssetFactory.makeCritterAssets();
        // just load the first one
        updateAngle();
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
        var newIndex :int = _assetIndex;
        if (Math.abs(_critter.vel.y) > Math.abs(_critter.vel.x)) {
            newIndex = (_critter.vel.y >= 0) ? ASSET_UP : ASSET_DOWN;
        } else {
            newIndex = (_critter.vel.x >= 0) ? ASSET_RIGHT : ASSET_LEFT;
        }
        
        if (newIndex != _assetIndex) {
            _assetIndex = newIndex;
            this.source = _assets[_assetIndex] as BitmapAsset;
            this.scaleX = _screenWidth / source.width;
            this.scaleY = _screenHeight / source.height;
            _bitmapOffset = new Point(Board.SQUARE_WIDTH / 2 - _screenWidth / 2,
                                      Board.SQUARE_HEIGHT / 2 - _screenHeight);
        }
    }

    protected static const ASSET_RIGHT :int = 0;
    protected static const ASSET_UP :int = 1;
    protected static const ASSET_LEFT :int = 2;
    protected static const ASSET_DOWN :int = 3;

    protected var _screenHeight :Number = 30;
    protected var _screenWidth :Number = 20;
    
    protected var _assets :Array; // of BitmapAsset, arranged as: right, up, left, down
    protected var _assetIndex :int = -1;
    protected var _critter :Critter;
    protected var _bitmapOffset :Point = new Point(0, 0);
}
}
