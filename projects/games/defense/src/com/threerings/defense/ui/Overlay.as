package com.threerings.defense.ui {

import flash.display.BitmapData;

import mx.controls.Image;
import mx.core.BitmapAsset;

import com.threerings.defense.Board;
import com.threerings.defense.maps.Map;
import com.threerings.defense.maps.MapFactory;

/**
 * Graphical representation of a Map object's data.
 */
public class Overlay extends Image
{
    public function Overlay ()
    {
    }

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
        this.scaleX = Board.BOARD_WIDTH / source.width;
        this.scaleY = Board.BOARD_HEIGHT / source.height;

        this.visible = false;
    }

    public function update () :void
    {
        if (ready() && visible) {
            _map.maybeRefreshOverlay(_bitmap.bitmapData, _player);
        }
    }

    protected var _map :Map;
    protected var _player :int;
    protected var _bitmap :BitmapAsset;
}
}
    
