package ghostbusters.fight {
    
import com.whirled.contrib.core.MainLoop;

import flash.display.Sprite;

import ghostbusters.fight.common.MicrogameConstants;
import ghostbusters.fight.common.MicrogameMode;
import ghostbusters.fight.ouija.GhostWriterGame;
    
public class MicrogamePlayer extends Sprite
{
    public function MicrogamePlayer (playerData :Object)
    {
        _playerData = playerData;
        
        this.width = MicrogameConstants.GAME_WIDTH;
        this.height = MicrogameConstants.GAME_HEIGHT;
        
        if (null != MainLoop.instance) {
            MainLoop.instance.shutdown();
        }
        
        new MainLoop(this);
    }
    
    public function get weaponType () :WeaponType
    {
        return _weaponType;
    }
    
    public function set weaponType (type :WeaponType) :void
    {
        if (!_weaponType.equals(type))
            _weaponType = type;
            this.cancelCurrentGame();
        }
    }
    
    public function beginNextGame () :Microgame
    {
        if (null == _weaponType) {
            throw new Error("weaponType must be set before the games can begin!");
        }
        
        if (null != _currentGame) {
            _currentGame.gameEndTransition();
            _currentGame = null;
        }
        
        // generate a new game
        // @TODO: do something real here
        _currentGame = new GhostWriterGame();
        _currentGame.begin(); // games push themselves onto the mode stack
        
        return _currentGame;
    }
    
    public function get currentGame () :Microgame
    {
        return _currentGame;
    }
    
    protected function cancelCurrentGame () :void
    {
        MainLoop.instance.popAllModes();
        _currentGame = null;
    }
    
    protected var _playerData :Object;
    protected var _weaponType :WeaponType;
    protected var _running :Boolean;
    protected var _currentGame :MicrogameMode;
}

}
