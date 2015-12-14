package {

import flash.display.Loader;
import flash.display.SimpleButton;
import flash.display.Sprite;

import flash.events.ContextMenuEvent;
import flash.events.Event;
import flash.events.MouseEvent;

import flash.net.URLRequest;

import flash.system.ApplicationDomain;
import flash.system.LoaderContext;
import flash.system.SecurityDomain;

import flash.text.TextField;


import flash.ui.ContextMenu;
import flash.ui.ContextMenuItem;

/**
 * Demonstrates a bug in the flash player.
 *
 * @author Ray Greenwell <ray@threerings.net>
 */
[SWF(width="600", height="400")]
public class MenuTest extends Sprite
{
    /* Not everything makes it break, but google videos sure do. */
    protected static const EMBED :String =
        "http://video.google.com/googleplayer.swf?docId=-7964147869780306512&hl=en";

    public function MenuTest ()
    {
        // set up our custom context menu
        var menu :ContextMenu = new ContextMenu();
        menu.hideBuiltInItems();
        this.contextMenu = menu;
        menu.addEventListener(ContextMenuEvent.MENU_SELECT, handleMenu, false, int.MIN_VALUE);


        var text :TextField = new TextField();
        text.wordWrap = true;
        text.multiline = true;
        text.text = "Right click and see the custom menu. When ready, press the green button " +
            "to load an embedded video. Then try right-clicking again: the custom menu is gone. " +
            "Nothing will bring it back. The top-level swf should have control over this.";
        text.background = true;
        text.width = 350;
        text.height = 100;
        addChild(text);

        var up :Sprite = new Sprite();
        up.graphics.beginFill(0x00FF00);
        up.graphics.drawCircle(25, 25, 25);
        up.graphics.endFill();

        var down :Sprite = new Sprite();
        down.graphics.beginFill(0x009900);
        down.graphics.drawCircle(25, 25, 25);
        down.graphics.endFill();

        var button :SimpleButton = new SimpleButton(up, up, down, down);
        button.addEventListener(MouseEvent.CLICK, handleClick);
        button.x = 350;
        addChild(button);
    }

    protected function handleClick (event :MouseEvent) :void
    {
        SimpleButton(event.target).removeEventListener(MouseEvent.CLICK, handleClick);

        var loader :Loader = new Loader();
        loader.scaleX = loader.scaleY = .5;
        loader.y = 100;
        addChild(loader);

        loader.load(new URLRequest(EMBED),
            new LoaderContext(false, new ApplicationDomain(null))); //, SecurityDomain.currentDomain));
    }

    protected function handleMenu (event :ContextMenuEvent) :void
    {
        trace("Customizing menu...");
        var menu :ContextMenu = ContextMenu(event.target);
        var custom :Array = menu.customItems;
        custom.length = 0;

        custom.push(new ContextMenuItem("Now you see me! " + Math.random().toFixed(4)));
    }
}
}
