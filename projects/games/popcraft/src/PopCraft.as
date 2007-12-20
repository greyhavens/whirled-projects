//
// $Id$

package {

import popcraft.*;
import popcraft.net.*;
import core.*;

import com.threerings.util.Assert;
import com.whirled.WhirledGameControl;
import core.MainLoop;

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

        _gameCtrl = new WhirledGameControl(this, true);
        _gameCtrl.addEventListener(StateChangedEvent.GAME_STARTED, handleGameStarted);

        var mainLoop :MainLoop = new MainLoop(this);
        mainLoop.run();
    }

    protected function handleGameStarted (event :StateChangedEvent) :void
    {
        MainLoop.instance.pushMode(new GameMode());
    }

    public function get gameControl () :WhirledGameControl
    {
        return _gameCtrl;
    }

    public function get config () :Object
    {
        return _gameCtrl.getConfig();
    }

    protected static var g_instance :PopCraft;

    protected var _gameCtrl :WhirledGameControl;
}

}

class Test
{
    public function toString () :String
    {
        return "asdfasdfasdf";
    }
}
