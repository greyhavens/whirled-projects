package ui {

import flash.display.Graphics;
import flash.events.MouseEvent;
import flash.geom.Point;

import mx.containers.TitleWindow;
import mx.controls.Button;
import mx.controls.Image;
import mx.managers.PopUpManager;

import com.threerings.util.StringUtil;

import game.Board;
import game.Controller;

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

    public function reset (player :int, name :String, board :Board, controller :Controller) :void
    {
        // needed to disambiguate 'this' later on in an anonymous function
        var panel :ScorePanel = this;
        
        _maxHealth = board.def.startingHealth;
        _myPanel = (player == board.main.myIndex);
        
        this.title = StringUtil.truncate(name, 10, "...");
        this.health = _maxHealth;
        this.visible = true;
        this.includeInLayout = true;

        var pos :Point = Globals.SCOREPANEL_POS[player];
        this.x = pos.x;
        this.y = pos.y;

        if (! board.main.isSinglePlayer && _myPanel && _enemy == null) {
            _enemy = new Button();
            _enemy.styleName = "enemyButton";
            _enemy.addEventListener(MouseEvent.CLICK, function (event :MouseEvent) :void {
                    var selector :SpawnSelector =
                        new SpawnSelector(board, controller.changeSpawnGroup);
                    PopUpManager.addPopUp(selector, panel.parent, false);
                    PopUpManager.centerPopUp(selector);
                });
            addChild(_enemy);
        }
    }
    
    public function set health (value :Number) :void
    {
        var g :Graphics = _health.graphics;
        
        g.clear();

        g.beginFill(0x000000, 0.3);
        g.drawRoundRect(0, 0, 100, 6, 3, 3);
        g.endFill();

        if (value > 0) {
            g.beginFill(_myPanel ? Globals.MY_COLOR : Globals.THEIR_COLOR, 0.8);
            g.drawRect(1, 1, (value / _maxHealth) * 98, 4);
            g.endFill();
        }
        
        _health.toolTip = Messages.get("health") + value;
    }

    protected var _myPanel :Boolean;
    protected var _maxHealth :Number;
    protected var _health :Image;
    protected var _enemy :Button;
}
}
