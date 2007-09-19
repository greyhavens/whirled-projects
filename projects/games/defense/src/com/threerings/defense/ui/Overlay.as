package com.threerings.defense.ui {

import flash.display.BitmapData;

import mx.controls.Image;
import mx.core.BitmapAsset;

import com.threerings.defense.Board;
import com.threerings.defense.maps.Map;
import com.threerings.defense.maps.MapFactory;

/** Graphical representation of a Map object's data, with a low res bitmap where each pixel
 *  corresponds to a single board cell. */
public class Overlay extends Image
{
    public function init (map :Map, player :int) :void
    {
        _map = map;
        _player = player;
    }

    public function ready () :Boolean
    {
        return (_map != null);
    }

    override protected function createChildren () :void
    {
        super.createChildren();
        
        _bitmap = MapFactory.makeBlankOverlay();
        this.source = _bitmap;
        this.scaleX = Board.BOARD_WIDTH / _bitmap.width;
        this.scaleY = Board.BOARD_HEIGHT / _bitmap.height;

        this.visible = false;
        this.cacheAsBitmap = true;
    }

    public function update () :void
    {
        refreshFromMap(); // try to refresh on every iteration
    }

    public function refreshFromMap () :Boolean
    {
        if (ready() && visible) {
            return _map.maybeRefreshOverlay(_bitmap.bitmapData, _player);
        }
        return false;
    }

    protected var _map :Map;
    protected var _player :int;
    protected var _bitmap :BitmapAsset;
}
}
    
