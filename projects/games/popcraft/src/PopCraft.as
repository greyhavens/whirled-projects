//
// $Id$

package {

import com.threerings.util.Assert;
import com.whirled.contrib.simplegame.*;
import com.whirled.contrib.simplegame.resource.*;
import com.whirled.game.GameControl;

import flash.display.MovieClip;
import flash.display.Sprite;
import flash.events.Event;

import popcraft.*;
import popcraft.net.*;
import popcraft.util.*;

[SWF(width="700", height="500", frameRate="30")]
public class PopCraft extends Sprite
{
    /**
     * Returns the singleton PopCraft instance
     */
    public static function get instance () :PopCraft
    {
        Assert.isTrue(null != g_instance);
        return g_instance;
    }

    public static function get resourceManager () :ResourceManager
    {
        return g_instance._rsrcMgr;
    }

    public static function instantiateMovieClip (resourceName :String, className :String) :MovieClip
    {
        var swf :SwfResourceLoader = resourceManager.getResource(resourceName) as SwfResourceLoader;
        if (null != swf) {
            var movieClass :Class = swf.getClass(className);
            if (null != movieClass) {
                return new movieClass();
            }
        }

        return null;
    }

    public function PopCraft ()
    {
        Assert.isTrue(null == g_instance);
        g_instance = this;

        this.graphics.beginFill(0);
        this.graphics.drawRect(0, 0, 700, 500);
        this.graphics.endFill();

        this.addEventListener(Event.REMOVED_FROM_STAGE, handleUnload);

        var mainLoop :MainLoop = new MainLoop(this);
        mainLoop.run();

        _gameCtrl = new GameControl(this, false);

        // if we're running in standalone mode, output some statistics
        if (!_gameCtrl.isConnected()) {
            trace(Constants.generateUnitReport());
            return;
        }

        // LoadingMode will start the game when loading is complete
        mainLoop.pushMode(new LoadingMode());
    }

    public function get gameControl () :GameControl
    {
        return _gameCtrl;
    }

    protected function handleUnload (...ignored) :void
    {
        MainLoop.instance.shutdown();
    }

    protected static var g_instance :PopCraft;

    protected var _gameCtrl :GameControl;
    protected var _rsrcMgr :ResourceManager = new ResourceManager();
}

}
