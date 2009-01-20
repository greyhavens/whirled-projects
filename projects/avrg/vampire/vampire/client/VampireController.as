package vampire.client
{
import com.threerings.util.ClassUtil;
import com.threerings.util.Controller;
import com.threerings.util.Log;
import com.whirled.contrib.simplegame.AppMode;
import com.whirled.contrib.simplegame.MainLoop;

import flash.display.Sprite;

import vampire.client.modes.NothingMode;


/**
 * GUI logic.  
 * 
 */
public class VampireController extends Controller
{
    public static const SWITCH_MODE :String = "SwitchMode";
    public static const CLOSE_MODE :String = "CloseMode";
//    public static const PLAYER_STATE_CHANGED :String = "PlayerStateChanged";
    public static const QUIT :String = "Quit";
    
    public function VampireController(panel :Sprite)
    {
        setControlledPanel( panel );
    }
        
    public function handleSwitchMode( loop :MainLoop, mode :String ) :void
    {
        var classSting :String = "vampire.client.modes." + mode + "Mode";
        var modeClass :Class = ClassUtil.getClassByName(classSting);
        if( modeClass == null) {
            log.error("no mode class found");
        }
        else {
            loop.changeMode( new modeClass() as AppMode );
        }
    }
    
    public function handleCloseMode( loop :MainLoop) :void
    {
        loop.unwindToMode( new NothingMode() );
    }
    
//    public function handlePlayerStateChanged( playerModel :Model, hud :HUD) :void
//    {
//        hud.updatePlayerState( playerModel );
//    }
    
    public function handleQuit() :void
    {
        ClientContext.quit()
    }
    
    protected static const log :Log = Log.getLog( VampireController );

}
}