//
// $Id$

package popcraft.battle.view {

import com.threerings.flashbang.GameObject;
import com.threerings.flashbang.tasks.*;

import flash.display.MovieClip;

import popcraft.*;

public class TeslaSoundPlayer extends GameObject
{
    public function TeslaSoundPlayer (teslaBg :MovieClip, playSoundCallback :Function)
    {
        _playSoundCallback = playSoundCallback;

        var zapParent :MovieClip = (teslaBg["zap3"])["zap2"];
        for each (var zapName :String in TESLA_ZAPS) {
            var zap :MovieClip = zapParent[zapName];
            addTask(new RepeatingTask(
                new WaitForFrameTask(14, zap),
                new FunctionTask(playZapSound)));
        }
    }

    protected function playZapSound () :void
    {
        _playSoundCallback("sfx_tesla2");
    }

    protected var _playSoundCallback :Function;

    protected static const TESLA_ZAPS :Array = [ "zapa", "zapb", "zapc", "zapd" ];
}

}
