package ghostbusters.fight {
    
import com.threerings.flash.SimpleTextButton;

import flash.display.SimpleButton;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Point;

import fl.controls.ComboBox;

[SWF(width="305", height="350", frameRate="30")]
public class MicrogameTestApp extends Sprite
{
    public function MicrogameTestApp ()
    {
        _player = new MicrogamePlayer(new Object());
        this.addChild(_player);
        
        _curWeaponTypeName = WeaponType.NAME_OUIJA;
        _curWeaponDifficulty = 0;
        
        _player.weaponType = new WeaponType(_curWeaponTypeName, _curWeaponDifficulty);
        _player.beginNextGame();
        
        this.addEventListener(Event.ENTER_FRAME, onEnterFrame, false, 0, true);
        
        // create weapon buttons
        var loc :Point = new Point(0, 305);
        
        var weaponTypes :Array = [ WeaponType.NAME_OUIJA, WeaponType.NAME_PLASMA, WeaponType.NAME_POTIONS ];
        for (var i :uint = 0; i < weaponTypes.length; ++i) {
            var weaponTypeName :String = weaponTypes[i];
            
            var button :SimpleButton = new SimpleTextButton(weaponTypeName);
            button.x = loc.x;
            button.y = loc.y;
            button.addEventListener(MouseEvent.CLICK, this.createButtonHandler(weaponTypeName));
            
            this.addChild(button);
            
            loc.x += button.width;
        }
    }
    
    protected function createButtonHandler (weaponTypeName :String) :Function
    {
        return function (e :Event) :void { changeWeaponTypeName(weaponTypeName); };
    }
    
    protected function changeWeaponTypeName (weaponTypeName :String) :void
    {
        if (weaponTypeName != _curWeaponTypeName) {
            _curWeaponTypeName = weaponTypeName;
            _player.weaponType = new WeaponType(_curWeaponTypeName, _curWeaponDifficulty);
            _player.beginNextGame();
        }
    }
    
    protected function onEnterFrame (e :Event) :void
    {
        if (_player.currentGame.isDone) {
            _player.beginNextGame();
        }
    }
    
    protected var _player :MicrogamePlayer;
    protected var _curWeaponTypeName :String;
    protected var _curWeaponDifficulty :int;
    
}

}