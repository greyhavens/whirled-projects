package com.threerings.defense.ui {

import flash.geom.Point;
        
import mx.containers.ApplicationControlBar;
import mx.containers.HBox;
import mx.containers.VBox;
import mx.controls.Label;

import com.threerings.defense.Board;
import com.threerings.defense.tuning.Messages;
import com.threerings.util.StringUtil;

public class ScorePanel extends ApplicationControlBar
{
    public function ScorePanel()
    {
        this.visible = false;
        this.includeInLayout = false;
    }

    override protected function createChildren () :void
    {
        super.createChildren ();

        var contents :VBox = new VBox();
        addChild(contents);

        contents.addChild(_name = new Label());

        var row :HBox = new HBox();
        row.addChild(Messages.getLabel("health"));
        row.addChild(_health = new Label());
        contents.addChild(row);
    }

    public function init (player :int, name :String, health :int) :void
    {
        _name.text = StringUtil.truncate(name, 10, "...");
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
