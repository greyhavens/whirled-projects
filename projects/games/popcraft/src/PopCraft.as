//
// $Id$

package {

import com.threerings.util.Assert;
import com.whirled.WhirledGameControl;
import core.MainLoop;

import flash.display.Sprite;
import flash.utils.Dictionary;
import core.util.ObjectSet;

import popcraft.GameMode;

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

        //_gameCtrl = new WhirledGameControl(this);

        var mainLoop :MainLoop = new MainLoop(this);
        mainLoop.pushMode(new GameMode());
        mainLoop.run();
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
