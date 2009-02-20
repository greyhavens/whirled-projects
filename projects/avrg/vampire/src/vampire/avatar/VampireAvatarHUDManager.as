package vampire.avatar
{
import com.whirled.avrg.AVRGameControl;
import com.whirled.contrib.avrg.AvatarHUD;
import com.whirled.contrib.avrg.AvatarHUDManager;

/**
 * Updates the location of avatar information
 * 
 */
public class VampireAvatarHUDManager extends AvatarHUDManager
{
    public function VampireAvatarHUDManager(ctrl:AVRGameControl)
    {
        super(ctrl);
        
        var p1 :VampireAvatarHUD = new VampireAvatarHUD( 23340 );
        p1.setLocation( [0.6, 0, 0.4] );
        p1.setHotspot( [300, 390] );
        p1.isPlayer = true;
        
        avatarMap.put( p1.playerId, p1 );
        
        var p2 :VampireAvatarHUD = new VampireAvatarHUD( 10393 );
        p2.setLocation( [0.2, 0, 0.3] );
        p2.setHotspot( [300, 390] );
        p2.isPlayer = true;
        avatarMap.put( p2.playerId, p2 );
        
    }
    
    override protected function createPlayerAvatar( userId :int ) :AvatarHUD
    {
        return new VampireAvatarHUD( userId );
    }
    
    public function getVampireAvatar( playerId :int ) :VampireAvatarHUD
    {
        return getAvatar( playerId ) as VampireAvatarHUD;
    }
    
}
}