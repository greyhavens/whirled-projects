//
// $Id$

package popcraft {

import com.threerings.util.Assert;
import com.whirled.WhirledGameControl;
import core.MainLoop;

import flash.display.Sprite;
import flash.utils.Dictionary;
import core.util.ObjectSet;

[SWF(width="700", height="500")]
public class PopCraft extends Sprite
{
    /**
     * Returns the singleton PopCraft instance
     */
    public static function get instance() :PopCraft
    {
        Assert.isTrue(null != g_instance);
        return g_instance;
    }

    public function PopCraft ()
    {
        /*var dict :Dictionary = new Dictionary();
        trace(dict[1]);
        dict[1] = null;
        trace(dict[1]);
        delete dict[1];
        trace(dict[1]);*/

        var asdf :* = undefined;
        var qwert :* = null;

        trace(asdf == qwert);
        trace(asdf === qwert);

        var os :ObjectSet = new ObjectSet();

        Assert.isTrue(null == g_instance);
        g_instance = this;

        _gameCtrl = new WhirledGameControl(this);

        var mainLoop :MainLoop = new MainLoop();
        mainLoop.pushMode(new GameMode());
        mainLoop.run();
    }

    public function get control () :WhirledGameControl
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
