package com.threerings.defense.ui {

import flash.display.Graphics;
import flash.geom.Point;

import mx.containers.TitleWindow;
import mx.controls.Image;

import com.threerings.defense.Board;
import com.threerings.defense.tuning.Messages;

import com.threerings.util.StringUtil;

public class ScorePanel extends TitleWindow
{
    public function ScorePanel()
    {
        this.visible = false;
        this.includeInLayout = false;
    }

    override protected function createChildren () :void
    {
        super.createChildren ();

        _health = new Image();
        _health.width = 100;
        _health.cacheAsBitmap = true;
        addChild(_health);
    }

    public function reset (player :int, name :String, health :int) :void
    {
        _maxhealth = health;
        
        this.title = StringUtil.truncate(name, 10, "...");
        this.health = health;
        this.visible = true;
        this.includeInLayout = true;

        var pos :Point = Board.SCOREPANEL_POS[player];
        this.x = pos.x;
        this.y = pos.y;
    }

    public function set health (value :Number) :void
    {
        var g :Graphics = _health.graphics;

        g.clear();

        g.beginFill(0x000000, 0.3);
        g.drawRoundRect(0, 0, 100, 6, 3, 3);
        g.endFill();

        if (value > 0) {
            g.beginFill(0x00ff00, 0.8);
            g.drawRect(1, 1, (value / _maxhealth) * 98, 4);
            g.endFill();
        }
        
        _health.toolTip = Messages.get("health") + value;
    }

    protected var _maxhealth :Number;
    protected var _health :Image;
}
}
