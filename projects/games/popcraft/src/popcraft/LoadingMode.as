package popcraft {
    
import com.threerings.ezgame.StateChangedEvent;

import com.whirled.WhirledGameControl;
import com.whirled.contrib.core.*;
import com.whirled.contrib.core.resource.*;

import flash.events.Event;

public class LoadingMode extends AppMode
{
    public function LoadingMode (gameCtrl :WhirledGameControl)
    {
        _gameCtrl = gameCtrl;
    }
    
    override protected function setup () :void
    {
        PopCraft.resourceManager.pendResourceLoad("image", "grunt",     { embeddedClass: Content.IMAGE_GRUNT });
        PopCraft.resourceManager.pendResourceLoad("image", "heavy",     { embeddedClass: Content.IMAGE_HEAVY });
        PopCraft.resourceManager.pendResourceLoad("image", "sapper",    { embeddedClass: Content.IMAGE_SAPPER });
        PopCraft.resourceManager.pendResourceLoad("image", "base",      { embeddedClass: Content.IMAGE_BASE });
        PopCraft.resourceManager.pendResourceLoad("image", "waypoint",  { embeddedClass: Content.IMAGE_WAYPOINT });
        PopCraft.resourceManager.pendResourceLoad("image", "battle_bg", { embeddedClass: Content.IMAGE_BATTLE_BG });
        PopCraft.resourceManager.pendResourceLoad("image", "battle_fg", { embeddedClass: Content.IMAGE_BATTLE_FG });
        PopCraft.resourceManager.pendResourceLoad("swf", "streetwalker", { embeddedClass: Content.SWF_STREETWALKER });
        
        PopCraft.resourceManager.load();
        
        _gameCtrl.game.addEventListener(StateChangedEvent.GAME_STARTED, handleGameStarted);
    }
    
    override public function update (dt :Number) :void
    {
        if (!PopCraft.resourceManager.isLoading) {
            // Once we're done loading resources, we're ready for the game to begin.
            // Wait for the WhirledGameControl to fire the event.
            _gameCtrl.game.playerReady();
        }
    }
    
    protected function handleGameStarted (e :Event) :void
    {
        MainLoop.instance.changeMode(new GameMode());
    }
    
    protected var _gameCtrl :WhirledGameControl;
    
}

}