package com.threerings.defense.sprites {

import flash.geom.Point;

import mx.core.BitmapAsset;
import mx.core.IFlexDisplayObject;
import mx.controls.Image;

import com.threerings.defense.AssetFactory;
import com.threerings.defense.Board;
import com.threerings.defense.units.Missile;

public class MissileSprite extends UnitSprite
{
    public function MissileSprite (missile :Missile)
    {
        super(missile);
        startReloadingAssets();
    }

    public function get missile () :Missile
    {
        return _unit as Missile;
    }

    public function get assets () :MissileAssets
    {
        return _assets as MissileAssets;
    }

    // from UnitSprite
    override protected function reloadAssets () :void
    {
        _assets = AssetFactory.makeMissileAssets(missile);
        this.source = assets.base;
        this.scaleX = assets.screenWidth / source.width;
        this.scaleY = assets.screenHeight / source.height;
    }

    // from UnitSprite
    override protected function assetsReloaded () :void
    {
        anchorOffset.x = - _assets.screenWidth / 2;
        anchorOffset.y = - _assets.screenHeight / 2;
        update();
    }

    // from UnitSprite
    override public function update () :void
    {
        super.update();

        // now update sprite rotation
        var theta :Number = Math.atan2(missile.vel.y, missile.vel.x);
        this.rotation = theta * 180 / Math.PI;
    }

    // from UnitSprite
    override protected function getMyZOrder () :Number
    {
        // missiles are on top of everything else -
        // but among themselves, they're ordered in the same way as other sprites

        return Board.BOARD_WIDTH * Board.BOARD_HEIGHT +  // offset to put them in front of all else
            _unit.centroidy * Board.BOARD_WIDTH + _unit.centroidx;
    }
}
}
