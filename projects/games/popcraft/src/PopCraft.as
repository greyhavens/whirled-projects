//
// $Id$

package {

import com.whirled.contrib.simplegame.*;
import com.whirled.contrib.simplegame.resource.*;
import com.whirled.game.GameControl;

import flash.display.Sprite;
import flash.events.Event;

import popcraft.*;
import popcraft.net.*;
import popcraft.sp.LevelSelectMode;
import popcraft.util.*;

[SWF(width="700", height="500", frameRate="30")]
public class PopCraft extends Sprite
{
    public function PopCraft ()
    {
        this.graphics.beginFill(0);
        this.graphics.drawRect(0, 0, 700, 500);
        this.graphics.endFill();

        this.addEventListener(Event.REMOVED_FROM_STAGE, handleUnload);

        AppContext.mainLoop = new MainLoop(this);
        AppContext.mainLoop.run();

        AppContext.gameCtrl = new GameControl(this, false);
        var isConnected :Boolean = AppContext.gameCtrl.isConnected();

        // if we're running in standalone mode, output some statistics
        if (!isConnected) {
            trace(Constants.generateUnitReport());
        }

        var multiplayer :Boolean = isConnected && (AppContext.gameCtrl.game.seating.getPlayerIds().length > 1);

        if (multiplayer) {
            GameContext.gameType = GameContext.GAME_TYPE_MULTIPLAYER;
            AppContext.mainLoop.pushMode(new GameMode());
        } else {
            AppContext.mainLoop.pushMode(new LevelSelectMode());
        }

        // LoadingMode will pop itself from the stack when loading is complete
        AppContext.mainLoop.pushMode(new LoadingMode());
    }

    protected function handleUnload (...ignored) :void
    {
        AppContext.mainLoop.shutdown();
    }
}

}
