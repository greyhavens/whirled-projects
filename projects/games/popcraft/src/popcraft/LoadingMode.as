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
        ResourceManager.instance.pendResourceLoad("image", "grunt",     { embeddedClass: Content.IMAGE_GRUNT });
        ResourceManager.instance.pendResourceLoad("image", "heavy",     { embeddedClass: Content.IMAGE_HEAVY });
        ResourceManager.instance.pendResourceLoad("image", "sapper",    { embeddedClass: Content.IMAGE_SAPPER });
        ResourceManager.instance.pendResourceLoad("image", "base",      { embeddedClass: Content.IMAGE_BASE });
        ResourceManager.instance.pendResourceLoad("image", "waypoint",  { embeddedClass: Content.IMAGE_WAYPOINT });
        ResourceManager.instance.pendResourceLoad("image", "battle_bg", { embeddedClass: Content.IMAGE_BATTLE_BG });
        ResourceManager.instance.pendResourceLoad("image", "battle_fg", { embeddedClass: Content.IMAGE_BATTLE_FG });
        
        ResourceManager.instance.load();
        
        _gameCtrl.game.addEventListener(StateChangedEvent.GAME_STARTED, handleGameStarted);
    }
    
    override public function update (dt :Number) :void
    {
        if (!ResourceManager.instance.isLoading) {
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