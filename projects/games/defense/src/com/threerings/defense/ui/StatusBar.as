package com.threerings.defense.ui {

import mx.containers.ApplicationControlBar;
import mx.containers.HBox;
import mx.controls.Label;
import mx.controls.Spacer;

import com.threerings.defense.Board;
import com.threerings.defense.Display;
import com.threerings.defense.tuning.Messages;
import com.threerings.util.StringUtil;

public class StatusBar extends ApplicationControlBar
{
    public function StatusBar ()
    {
    }

    override protected function createChildren () :void
    {
        super.createChildren();

        this.x = Board.BOARD_OFFSETX;
        this.y = 0;
        this.width = Board.BOARD_WIDTH;
        this.height = Board.BOARD_OFFSETY;

        var spacer :Spacer = new Spacer();
        spacer.percentWidth = 50;
        addChild(spacer);

        addChild(_name = new Label());

        var row :HBox = new HBox();
        row.addChild(Messages.getLabel("health"));
        row.addChild(_health = new Label());
        addChild(row);

        row = new HBox();
        row.addChild(Messages.getLabel("score"));
        row.addChild(_score = new Label());
        addChild(row);

        spacer = new Spacer();
        spacer.percentWidth = 50;
        addChild(spacer);
    }

    public function init (name :String) :void
    {
        this.playerName = name;
        this.health = 0;
        this.score = 0;
    }
    
    public function set playerName (name :String) :void
    {
        _name.text = StringUtil.truncate(name, 10, "...");
    }

    public function set health (value :Number) :void
    {
        _health.text = String(value);
    }
    
    public function set score (value :Number) :void
    {
        _score.text = String(value);
    }
    
    protected var _name :Label;
    protected var _health :Label;
    protected var _score :Label;

}
}
