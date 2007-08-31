package ui {

import flash.display.DisplayObject;

import mx.containers.TitleWindow;
import mx.controls.Button;
import mx.controls.ButtonBar;
import mx.events.ItemClickEvent;

public class UIWindow extends TitleWindow
{
    public function UIWindow ()
    {
        this.title = Msgs.get("menu_title");
        this.showCloseButton = false;
        this.x = 800;
        this.y = 10;
    }
        
    override protected function createChildren () :void
    {
        super.createChildren();
        
        _bb = new ButtonBar();
        addChild(_bb);

        // buttonBar.addEventListener(ItemClickEvent.ITEM_CLICK, handleButtonBarClick);
    }

    /*
    protected function handleButtonBarClick (itemClick :ItemClickEvent) :void
    {

    }
    */
    
    protected static var _instance :UIWindow;
    protected var _bb :ButtonBar;
}
}

    

    
