package sprites {

import flash.geom.Point;
import flash.geom.Rectangle;
import mx.controls.Image;

import units.Tower;

public class TowerSprite extends Image
{
    public function TowerSprite (tower :Tower)
    {
        _tower = tower;
    }

    public function get tower () :Tower
    {
        return _tower
    }

    public function updateTower (value :Tower) :void
    {
        if (value != null && ! value.equals(_tower)) {
            _tower = value;
            if (_currentAssetType != _tower.type) { // let's not reload assets needlessly
                reloadAssets();
            }
        }
    }

    public function updateLocation () :void
    {
        var p :Point = Board.logicalToScreenPosition(_tower.x, _tower.y);
        this.x = p.x;
        this.y = p.y;
    }

    public function setValid (valid :Boolean) :void
    {
        this.alpha = valid ? 1.0 : 0.3;
    }

    public function reloadAssets () :void
    {
        this.source = AssetFactory.makeTower(_tower.type);
        this.scaleX = Board.SQUARE_WIDTH * _tower.width / source.width;
        this.scaleY = Board.SQUARE_HEIGHT * _tower.height / source.height;
        _currentAssetType = _tower.type;
    }
    
    override protected function createChildren () :void
    {
        super.createChildren();
        reloadAssets();
        updateLocation();
    }

    protected var _currentAssetType :int;
    protected var _tower :Tower;

}
}
