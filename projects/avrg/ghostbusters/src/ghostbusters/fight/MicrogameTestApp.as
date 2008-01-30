package ghostbusters.fight {
    
import flash.display.Sprite;
import flash.events.Event;

[SWF(width="500", height="500", frameRate="30")]
public class MicrogameTestApp extends Sprite
{
    public function MicrogameTestApp ()
    {
        _player = new MicrogamePlayer(new Object());
        _player.weaponType = new WeaponType(WeaponType.NAME_OUIJA, 1);
        
        this.addChild(_player);
        
        _player.beginNextGame();
        
        this.addEventListener(Event.ENTER_FRAME, onEnterFrame, false, 0, true);
    }
    
    protected function onEnterFrame (e :Event) :void
    {
        if (_player.currentGame.timeRemainingMS == 0) {
            _player.beginNextGame();
        }
    }
    
    protected var _player :MicrogamePlayer;
    
}

}