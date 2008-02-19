//
// $Id$

package {

import com.threerings.util.Assert;
import com.whirled.contrib.core.*;
import com.whirled.contrib.core.resource.*;
import com.whirled.game.GameControl;

import flash.display.Sprite;

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

    public function PopCraft ()
    {
        Assert.isTrue(null == g_instance);
        g_instance = this;

        var mainLoop :MainLoop = new MainLoop(this);
        mainLoop.run();

        _gameCtrl = new GameControl(this, false);
        
        // LoadingMode will start the game when loading is complete
        mainLoop.pushMode(new LoadingMode(_gameCtrl));
    }

    public function get gameControl () :GameControl
    {
        return _gameCtrl;
    }

    protected static var g_instance :PopCraft;

    protected var _gameCtrl :GameControl;
    protected var _rsrcMgr :ResourceManager = new ResourceManager();
}

}
