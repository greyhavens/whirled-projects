package com.threerings.defense.ui {

import flash.events.Event;
import flash.events.MouseEvent;
import flash.ui.Mouse;

import mx.containers.BoxDirection;
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

public class UIWindow extends TitleWindow
{
    public function UIWindow (display :Display)
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
        
        var defs :Array = [
            { label: Messages.get("off") },
            { label: Messages.get("path_1"), player: 0 },
            { label: Messages.get("path_2"), player: 1 },
        ];

        _scores = new ScorePanel();
        addChild(_scores);
        
        _towers = new ToggleButtonBar();
        _towers.direction = BoxDirection.VERTICAL;
        _towers.addEventListener(ItemClickEvent.ITEM_CLICK, handleTowerBarClick);
        addChild(_towers);
        
        _bb = new ToggleButtonBar();
        _bb.direction = BoxDirection.VERTICAL;
        _bb.dataProvider = defs;
        _bb.addEventListener(ItemClickEvent.ITEM_CLICK, handleButtonBarClick);
        addChild(_bb);

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
    }

    public function get scorePanel () :ScorePanel
    {
        return _scores;
    }
    
    public function handleUnload (event :Event) :void
    {
        _bb.removeEventListener(ItemClickEvent.ITEM_CLICK, handleButtonBarClick);
        _towers.removeEventListener(ItemClickEvent.ITEM_CLICK, handleTowerBarClick);
        
        removeEventListener(MouseEvent.MOUSE_OVER, handleMouseOver);
        removeEventListener(MouseEvent.MOUSE_OUT, handleMouseOut);
    }

    protected function handleMouseOver (event :MouseEvent) :void
    {
        Mouse.show();
    }

    protected function handleMouseOut (event :MouseEvent) :void
    {
    }
    
    protected function handleButtonBarClick (itemClick :ItemClickEvent) :void
    {
        if (itemClick.item.player != null) {
            // this is a toggle request for the specified player's pathing map
            _display.showPathOverlay(int(itemClick.item.player));
        } else {
            _display.hidePathOverlays();
        }        
    }

    protected function handleTowerBarClick (itemClick :ItemClickEvent) :void
    {
        _game.setCursorType(itemClick.item.type);
    }

    protected var _board :Board;
    protected var _game :Game;
    protected var _display :Display;
    
    protected var _bb :ToggleButtonBar;
    protected var _towers :ToggleButtonBar;
    protected var _scores :ScorePanel;
}
}

    

    
