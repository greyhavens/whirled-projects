//
// $Id$

package {

import popcraft.*;
import popcraft.net.*;
import popcraft.util.*;

import com.whirled.contrib.core.*;

import com.threerings.util.Assert;
import com.whirled.WhirledGameControl;
import com.whirled.contrib.core.MainLoop;

import flash.display.Sprite;

import com.threerings.ezgame.StateChangedEvent;

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

    public function PopCraft ()
    {
        Assert.isTrue(null == g_instance);
        g_instance = this;

        var mainLoop :MainLoop = new MainLoop(this);
        mainLoop.run();

        _gameCtrl = new WhirledGameControl(this, false);
        _gameCtrl.game.addEventListener(StateChangedEvent.GAME_STARTED, handleGameStarted);
        _gameCtrl.game.playerReady();
    }

    protected function handleGameStarted (event :StateChangedEvent) :void
    {
        MainLoop.instance.changeMode(new GameMode());
    }

    public function get gameControl () :WhirledGameControl
    {
        return _gameCtrl;
    }

    protected static var g_instance :PopCraft;

    protected var _gameCtrl :WhirledGameControl;
}

}
