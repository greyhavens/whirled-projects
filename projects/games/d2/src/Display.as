package {

import flash.display.DisplayObject;
import flash.display.Graphics;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.system.System;
import flash.ui.Mouse;
import flash.utils.getTimer; // function import

import mx.containers.Canvas;

import com.threerings.ezgame.util.GameMode;
import com.threerings.ezgame.util.GameModeStack;
import com.threerings.util.Assert;

import modes.Splash;
import modes.SelectBoard;


/**
 * Display class that contains everything visible to the player.
 */
public class Display extends Canvas
{
    public function Display ()
    {
    }

    // @Override from Canvas
    override protected function createChildren () :void
    {
        // note - this happens before Main.init()
        
        super.createChildren();
        
        // initialize graphics
        _modes = new GameModeStack(modeSwitcher);

        // base mode
        _modes.push(new Splash(_modes));
    }

    /** Takes care of switching visible modes. */
    protected function modeSwitcher (oldMode :GameMode, newMode :GameMode) :void
    {
        var oldChild :DisplayObject = oldMode as DisplayObject;
        var newChild :DisplayObject = newMode as DisplayObject;

        Assert.isNotNull(newChild); // we should never ever empty the mode stack

        if (oldChild != null && this.contains(oldChild)) {
            removeChild(oldChild);
        }

        if (newChild != null && ! this.contains(newChild)) {
            addChild(newChild);
        }
    }
      

    protected var _modes :GameModeStack;
}
}
