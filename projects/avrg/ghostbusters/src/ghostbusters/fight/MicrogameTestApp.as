package ghostbusters.fight {
    
import com.threerings.flash.SimpleTextButton;

import fl.controls.ComboBox;
import fl.data.DataProvider;
import fl.skins.DefaultComboBoxSkins;

import flash.display.SimpleButton;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Point;

import ghostbusters.fight.common.*;

[SWF(width="305", height="300", frameRate="30")]
public class MicrogameTestApp extends Sprite
{
    public function MicrogameTestApp ()
    {
        _player = new MicrogamePlayer(new Object());
        this.addChild(_player);
        
        _curWeaponTypeName = WeaponType.NAME_LANTERN;
        _curWeaponDifficulty = 0;
        
        _player.weaponType = new WeaponType(_curWeaponTypeName, _curWeaponDifficulty);
        _player.beginNextGame();
        
        this.addEventListener(Event.ENTER_FRAME, onEnterFrame, false, 0, true);
        
        // create weapon buttons
        var loc :Point = new Point(0, MicrogameConstants.GAME_HEIGHT + 5);
        
        for (var i :uint = 0; i < WEAPON_TYPES.length; ++i) {
            var weaponTypeName :String = WEAPON_TYPES[i];
            
            var button :SimpleButton = new SimpleTextButton(weaponTypeName);
            button.x = loc.x;
            button.y = loc.y;
            button.addEventListener(MouseEvent.CLICK, this.createButtonHandler(weaponTypeName));
            
            this.addChild(button);
            
            loc.x += button.width;
        }
        
        // difficulty combo box
        var difficultySelect :ComboBox = new ComboBox();
        difficultySelect.prompt = "Difficulty:";
        difficultySelect.editable = false;
        difficultySelect.x = 0;
        difficultySelect.y = MicrogameConstants.GAME_HEIGHT + 40;
        difficultySelect.setSize(100, 22);
        difficultySelect.dataProvider = new DataProvider(["1", "2", "3", "4", "5"]);
        
        difficultySelect.selectedIndex = 0;
        
        difficultySelect.addEventListener(Event.CHANGE, onDifficultyChanged, false, 0, true);
        
        this.addChild(difficultySelect);
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
    
    protected function onDifficultyChanged (e :Event) :void
    {
        var difficultySelect :ComboBox = (e.target as ComboBox);
        
        var newDifficulty :int = difficultySelect.selectedIndex;
        
        if (newDifficulty != _curWeaponDifficulty) {
            _curWeaponDifficulty = newDifficulty;
            _player.weaponType = new WeaponType(_curWeaponTypeName, _curWeaponDifficulty);
            _player.beginNextGame();
        }
        
    }
    
    protected function onEnterFrame (e :Event) :void
    {
        if (_player.currentGame.isDone) {
            var result :MicrogameResult = _player.currentGame.gameResult;
            // @TODO - do something with result
            
            _player.beginNextGame();
        }
    }
    
    private static function referenceSkins () :void
    {
        // @TSC - apparently this is required to get the skins for the combobox
        // to get compiled in
        DefaultComboBoxSkins;
    }
    
    protected var _player :MicrogamePlayer;
    protected var _curWeaponTypeName :String;
    protected var _curWeaponDifficulty :int;
    
    protected static const WEAPON_TYPES :Array = [ 
        WeaponType.NAME_LANTERN, 
        WeaponType.NAME_OUIJA, 
        WeaponType.NAME_PLASMA, 
        WeaponType.NAME_POTIONS,
    ];
    
}

}