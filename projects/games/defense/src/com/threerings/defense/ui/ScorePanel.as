package com.threerings.defense.ui {

import flash.geom.Point;
        
import mx.containers.HBox;
import mx.containers.VBox;
import mx.containers.TitleWindow;
import mx.controls.Label;

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

        var row :HBox = new HBox();
        row.addChild(Messages.getLabel("health"));
        row.addChild(_health = new Label());
        addChild(row);
    }

    public function reset (player :int, name :String, health :int) :void
    {
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
        _health.text = String(value);
    }
    
    protected var _name :Label;
    protected var _health :Label;
    protected var _score :Label;
}
}
