package {

import flash.geom.Point;
import mx.core.BitmapAsset;
import mx.controls.Image;

public class CritterSprite extends Image
{
    public var xoffset :Number = 0;
    public var yoffset :Number = 0;
    
    public function CritterSprite (critter :Critter)
    {
        _critter = critter;
        reloadAssets();
        
        //xoffset = Math.random() * Board.SQUARE_WIDTH;
        //yoffset = Math.random() * Board.SQUARE_HEIGHT;
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
        var pos :Point = Board.logicalToScreenPosition(_critter.x, _critter.y);
        this.x = pos.x + xoffset;
        this.y = pos.y + yoffset;
        trace("SETTING CRITTER TO POSITION " + x + ", " + y);

        updateAngle();
    }
    
    /** Adjusts animation frames to fit movement in the specified direction. */
    public function updateAngle () :void
    {
        var newIndex :int = _assetIndex;
        if (Math.abs(_critter.dy) > Math.abs(_critter.dx)) {
            newIndex = (_critter.dy >= 0) ? ASSET_UP : ASSET_DOWN;
        } else {
            newIndex = (_critter.dx >= 0) ? ASSET_RIGHT : ASSET_LEFT;
        }
        
        if (newIndex != _assetIndex) {
            trace("LOADING BITMAP #" + newIndex);
            _assetIndex = newIndex;
            this.source = _assets[_assetIndex] as BitmapAsset;
        }
    }

    protected static const ASSET_RIGHT :int = 0;
    protected static const ASSET_UP :int = 1;
    protected static const ASSET_LEFT :int = 2;
    protected static const ASSET_DOWN :int = 3;
    
    protected var _assets :Array; // of BitmapAsset, arranged as: right, up, left, down
    protected var _assetIndex :int = -1;
    protected var _critter :Critter;
}
}
