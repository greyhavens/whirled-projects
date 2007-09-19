package com.threerings.defense.ui {

import flash.events.Event;
import flash.events.MouseEvent;
import flash.ui.Mouse;

import mx.containers.BoxDirection;
import mx.containers.Tile;
import mx.containers.TitleWindow;
import mx.controls.Button;
import mx.controls.ButtonBar;
import mx.controls.ToggleButtonBar;
import mx.events.ItemClickEvent;

import com.threerings.defense.Board;
import com.threerings.defense.Display;
import com.threerings.defense.Game;
import com.threerings.defense.tuning.Messages;
import com.threerings.defense.tuning.UnitDefinitions;

public class TowerPanel extends TitleWindow
{
    public function TowerPanel (display :Display)
    {
        _display = display;
        
        this.title = Messages.get("menu_title");
        this.showCloseButton = false;
        this.x = 800;
        this.y = 10;
    }
        
    override protected function createChildren () :void
    {
        super.createChildren();
        
        _towers = new ToggleButtonBar();
        _towers.direction = BoxDirection.VERTICAL;
        _towers.addEventListener(ItemClickEvent.ITEM_CLICK, handleTowerBarClick);
        addChild(_towers);

        _buttons = new Tile();
        _buttons.width = 120;
        addChild(_buttons);
        
        addEventListener(MouseEvent.MOUSE_OVER, handleMouseOver);
        addEventListener(MouseEvent.MOUSE_OUT, handleMouseOut);
    }

    /** Called after the level was loaded, will reset tower icons on the UI. */
    public function init (board :Board, game :Game) :void
    {
        _board = board;
        _game = game;
        
        // todo: nice button bar, requires a custom button class
        // var towerIcons :Array = board.level.loadTowerIcons();

        var defs :Array = new Array();
        UnitDefinitions.TOWER_DEFINITIONS.forEach(function(def :Object, i :*, a :*) :void {
                defs.push({ label: def.value.name, type: def.key });
            });

        _towers.dataProvider = defs;
        _towers.selectedIndex = 0;

        UnitDefinitions.TOWER_DEFINITIONS.forEach(function(def :Object, i :*, a :*) :void {
                var b :Button = new Button();
                b.styleName = def.value.styleName;
                b.id = def.key;
                b.addEventListener(MouseEvent.CLICK, handleTowerClick);
                _buttons.addChild(b);
            });

    }

    public function handleUnload (event :Event) :void
    {
        _towers.removeEventListener(ItemClickEvent.ITEM_CLICK, handleTowerBarClick);
        
        removeEventListener(MouseEvent.MOUSE_OVER, handleMouseOver);
        removeEventListener(MouseEvent.MOUSE_OUT, handleMouseOut);
    }

    public function locateAround (panel :ScorePanel) :void
    {
        this.x = panel.x;
        if (panel.y < this.height) {
            this.y = panel.y + panel.height + 20;
        } else {
            this.y = panel.y - this.height - 100;
        }
    }
    
    protected function handleMouseOver (event :MouseEvent) :void
    {
        Mouse.show();
    }

    protected function handleMouseOut (event :MouseEvent) :void
    {
    }
    
    protected function handleTowerBarClick (itemClick :ItemClickEvent) :void
    {
        _game.setCursorType(itemClick.item.type);
    }

    protected function handleTowerClick (event :MouseEvent) :void
    {
        _game.setCursorType(event.target.id);
        trace("CLICK! " + event.target.id + " -> " + event);
    }
    
    protected var _board :Board;
    protected var _game :Game;
    protected var _display :Display;
    protected var _buttons :Tile;
    
    protected var _bb :ToggleButtonBar;
    protected var _towers :ToggleButtonBar;
}
}

    

    
