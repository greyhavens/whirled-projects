package com.threerings.defense.sprites {

import flash.display.GradientType;
import flash.display.Graphics;
import flash.display.Shape;
import flash.geom.Matrix;
import flash.geom.Point;

import com.threerings.defense.Board;
import com.threerings.defense.Level;
import com.threerings.defense.units.Tower;

public class CursorSprite extends TowerSprite
{
    public function CursorSprite (tower :Tower, level :Level)
    {
        super(tower, level);
    }

    override protected function createChildren () :void
    {
        super.createChildren();

        _range = new Shape();
        addChild(_range);
    }

    override protected function childrenCreated () :void
    {
        super.childrenCreated();
        
        updateRangeDisplay();
    }

    public function updateTower (tower :Tower) :void
    {
        if (tower != null && ! tower.equals(_unit)) {
            trace("UPDATE TOWER!");
            _unit = tower;
            loadAllAssets();
        }
    }

    public function setValid (valid :Boolean) :void
    {
        this.alpha = valid ? 1.0 : 0.3;
    }

    override protected function loadAllAssets () :void
    {
        super.loadAllAssets();
        updateRangeDisplay();
    }
        
    protected function updateRangeDisplay () :void
    {
        if (_range == null) {
            return; // not initialized yet!
        }
        
        var g :Graphics = _range.graphics;
        var w :Number = Math.sqrt(tower.rangeMaxSq) * Board.SQUARE_WIDTH * 2;
        var h :Number = Math.sqrt(tower.rangeMaxSq) * Board.SQUARE_HEIGHT * 2;

        var m :Matrix = new Matrix();
        m.createGradientBox(w, h, 0, -w/2, -h/2);
        
        g.clear();
        g.beginGradientFill(GradientType.RADIAL, [0xffffff, 0xffffff], [0, 0.3], [0xa0, 0xff], m);
        g.drawEllipse(-w/2, -h/2, w, h);
        g.endFill();
    }

    protected var _range :Shape;
}
}
