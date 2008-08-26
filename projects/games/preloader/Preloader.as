//
// $Id$

package {

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.Graphics;
import flash.display.Sprite;

import flash.events.Event;
import flash.events.ProgressEvent;

import flash.utils.getDefinitionByName; // function import

import com.whirled.game.*;

/**
 * Demonstrates how to create a preloader for your game.
 * Important! Do not reference any of the classes in the main game here, or that will cause
 * them to load along with the preloader.
 */
public class Preloader extends Sprite
{
    public static const GAME_CLASS :String = "SomeGame";

    public function Preloader ()
    {
        _game = new GameControl(this);

        this.root.loaderInfo.addEventListener(ProgressEvent.PROGRESS, handleProgress);
        this.root.loaderInfo.addEventListener(Event.COMPLETE, handleComplete);

        showProgress(0, 100);
    }

    /**
     * Here you may create whatever animation and progress bar you desire for your
     * preloader.
     */
    protected function showProgress (soFar :Number, total :Number) :void
    {
        var g :Graphics = this.graphics;
        g.clear();
        g.beginFill(0x00FF99);
        g.drawRect(0, 0, 200 * soFar / total, 20);
        g.endFill();

        g.lineStyle(1, 0xFFFFFF);
        g.drawRect(0, 0, 200, 20);
    }

    protected function handleProgress (event :ProgressEvent) :void
    {
        showProgress(event.bytesLoaded, event.bytesTotal);
    }

    protected function handleComplete (event :Event) :void
    {
        addEventListener(Event.ENTER_FRAME, handleFrame);
    }

    protected function handleFrame (event :Event) :void
    {
        removeEventListener(Event.ENTER_FRAME, handleFrame);

        //var gameClass :Class = getDefinitionByName(GAME_CLASS) as Class;
        var gameClass :Class = this.root.loaderInfo.applicationDomain.getDefinition(GAME_CLASS) as Class;
        if (gameClass == null) {
            trace("Oh no! Could not find " + GAME_CLASS)
            return;
        }

        const rootCon :DisplayObjectContainer = DisplayObjectContainer(this.root);
        while (rootCon.numChildren > 0) {
            rootCon.removeChildAt(0);
        }

        var app :Object = new gameClass();
        app.init(_game);
        rootCon.addChild(DisplayObject(app));
        // and that's all we need to do..
    }

    protected var _game :GameControl;
}
}
