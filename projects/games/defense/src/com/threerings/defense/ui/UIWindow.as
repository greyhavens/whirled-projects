package com.threerings.defense.ui {

import flash.display.DisplayObject;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.ui.Mouse;

import mx.containers.TitleWindow;
import mx.controls.Button;
import mx.controls.ButtonBar;
import mx.events.ItemClickEvent;
import mx.utils.ObjectUtil;

import com.threerings.defense.Board;
import com.threerings.defense.Display;
import com.threerings.defense.Msgs;

public class UIWindow extends TitleWindow
{
    public function UIWindow (display :Display)
    {
        _display = display;
        
        this.title = Msgs.get("menu_title");
        this.showCloseButton = false;
        this.x = 800;
        this.y = 10;
    }
        
    override protected function createChildren () :void
    {
        super.createChildren();

        var defs :Array = [
        { label: Msgs.get("path_1"), player: 0 },
        { label: Msgs.get("path_2"), player: 1 },
        ];

        _bb = new ButtonBar();
        _bb.dataProvider = defs;
        _bb.addEventListener(ItemClickEvent.ITEM_CLICK, handleButtonBarClick);
        addChild(_bb);

        addEventListener(MouseEvent.MOUSE_OVER, handleMouseOver);
        addEventListener(MouseEvent.MOUSE_OUT, handleMouseOut);
    }

    public function handleUnload (event :Event) :void
    {
        _bb.removeEventListener(ItemClickEvent.ITEM_CLICK, handleButtonBarClick);
        
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
            _display.togglePathOverlay(int(itemClick.item.player));
        }
    }
    
    protected var _bb :ButtonBar;
    protected var _display :Display;

}
}

    

    
