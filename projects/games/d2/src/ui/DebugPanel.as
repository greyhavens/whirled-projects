package ui {

import flash.events.Event;
import flash.events.MouseEvent;
import flash.ui.Mouse;

import mx.containers.BoxDirection;
import mx.containers.TitleWindow;
import mx.controls.Button;
import mx.controls.ButtonBar;
import mx.controls.ToggleButtonBar;
import mx.events.ItemClickEvent;

import game.Board;
import game.Display;
import game.Game;

public class DebugPanel extends TitleWindow
{
    public function DebugPanel (display :Display)
    {
        _display = display;
        
        this.title = Messages.get("DEBUG");
        this.x = 400;
        this.y = 470;
    }

    override protected function createChildren () :void
    {
        super.createChildren();
        
        var defs :Array = [
            { label: Messages.get("off") },
            { label: Messages.get("path_1"), player: 0 },
            { label: Messages.get("path_2"), player: 1 },
        ];

        _bb = new ToggleButtonBar();
        _bb.direction = BoxDirection.HORIZONTAL;
        _bb.dataProvider = defs;
        _bb.addEventListener(ItemClickEvent.ITEM_CLICK, handleButtonBarClick);
        addChild(_bb);
    }

    public function handleUnload (event :Event) :void
    {
        _bb.removeEventListener(ItemClickEvent.ITEM_CLICK, handleButtonBarClick);
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

    protected var _bb :ToggleButtonBar;
    protected var _display :Display;
}
}
