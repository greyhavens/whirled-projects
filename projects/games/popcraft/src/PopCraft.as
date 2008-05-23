//
// $Id$

package {

import com.whirled.contrib.simplegame.*;
import com.whirled.contrib.simplegame.audio.AudioManager;
import com.whirled.contrib.simplegame.resource.*;
import com.whirled.contrib.simplegame.util.Rand;
import com.whirled.game.GameControl;

import flash.display.Sprite;
import flash.events.Event;

import popcraft.*;
import popcraft.data.*;
import popcraft.net.*;
import popcraft.sp.*;
import popcraft.util.*;

[SWF(width="700", height="500", frameRate="30")]
public class PopCraft extends Sprite
{
    public function PopCraft ()
    {
        // setup GameControl
        AppContext.gameCtrl = new GameControl(this, false);
        var isConnected :Boolean = AppContext.gameCtrl.isConnected();
        var multiplayer :Boolean = isConnected && (AppContext.gameCtrl.game.seating.getPlayerIds().length > 1);

        // setup main loop
        this.graphics.beginFill(0);
        this.graphics.drawRect(0, 0, 700, 500);
        this.graphics.endFill();

        this.addEventListener(Event.REMOVED_FROM_STAGE, handleUnload);

        AppContext.mainLoop = new MainLoop(this, (isConnected ? AppContext.gameCtrl.local : this.stage));
        AppContext.mainLoop.setup();

        // custom resource factories
        ResourceManager.instance.registerResourceType("level", LevelResourceLoader);
        ResourceManager.instance.registerResourceType("gameData", GameDataResourceLoader);

        // sound volume
        AudioManager.instance.masterControls.volume(Constants.SOUND_MASTER_VOLUME);

        // create a new random stream for the puzzle
        AppContext.randStreamPuzzle = Rand.addStream();

        AppContext.mainLoop.run();

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
