package com.threerings.defense.ui {

import mx.containers.ApplicationControlBar;
import mx.containers.HBox;
import mx.controls.Image;
import mx.controls.Label;
import mx.controls.Spacer;

import com.threerings.defense.Board;
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

        addChild(makeSpacer(200, false));

        addChild(_name = new Label());
        addChild(_score = new Label());
        addChild(makeSpacer(50, false));
        
        addChild(_money = new Label());
        addChild(_moneyIcon = new Image());
        addChild(makeSpacer(30, false));

        addChild(_health = new Label());
        addChild(_healthIcon = new Image());

        addChild(makeSpacer(100, true));
    }

    public function init (board :Board) :void
    {
        _healthIcon.source = board.level.loadHealthIcon();
        _healthIcon.toolTip = Messages.get("health_desc");
        _moneyIcon.source = board.level.loadMoneyIcon();
        _moneyIcon.toolTip = Messages.get("money_desc");
    }
    
    public function reset (name :String, board :Board) :void
    {
        this.playerName = name;
        this.health = board.getInitialHealth();
        this.score = 0;
        this.money = board.getInitialMoney();
    }
    
    public function set playerName (name :String) :void
    {
        _name.text = StringUtil.truncate(name, 10, "...") + Messages.get("score");
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
    protected var _moneyIcon :Image;
}
}
