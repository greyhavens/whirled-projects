package com.threerings.defense.ui {

import mx.containers.ApplicationControlBar;
import mx.containers.HBox;
import mx.controls.Image;
import mx.controls.Label;
import mx.controls.Spacer;

import com.threerings.defense.Board;
import com.threerings.util.StringUtil;

public class StatusBar extends ApplicationControlBar
{
    public function StatusBar ()
    {
    }

    override protected function createChildren () :void
    {
        super.createChildren();

        var makeSpacer :Function = function (width :int, isPercent :Boolean) :Spacer {
            var s :Spacer = new Spacer();
            if (isPercent) {
                s.percentWidth = width;
            } else {
                s.width = width;
            }
            return s;
        }

        this.x = 0;
        this.y = 0;
        this.width = Board.BG_WIDTH;
        this.height = Board.BOARD_OFFSETY;

        addChild(makeSpacer(50, true));

        addChild(_name = new Label());
        addChild(makeSpacer(50, false));
        
        addChild(_money = new Label());
        addChild(_moneyIcon = new Image());
        addChild(makeSpacer(30, false));

        addChild(_health = new Label());
        addChild(_healthIcon = new Image());
        addChild(makeSpacer(30, false));

        addChild(_score = new Label());
        addChild(_scoreIcon = new Image());

        addChild(makeSpacer(50, true));
    }

    public function init (board :Board) :void
    {
        _healthIcon.source = board.level.loadHealthIcon();
        _moneyIcon.source = board.level.loadMoneyIcon();
    }
    
    public function reset (name :String) :void
    {
        this.playerName = name;
        this.health = 0;
        this.score = 0;
        this.money = 0;
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

    public function set money (value :Number) :void
    {
        _money.text = String(value);
    }
    
    protected var _name :Label;
    protected var _health :Label;
    protected var _score :Label;
    protected var _money :Label;
    protected var _healthIcon :Image;
    protected var _scoreIcon :Image;
    protected var _moneyIcon :Image;
}
}
