package ghostbusters.client.fight {

import com.threerings.flash.SimpleTextButton;
import com.whirled.contrib.simplegame.*;
import com.whirled.contrib.simplegame.resource.*;

import fl.controls.ComboBox;
import fl.data.DataProvider;
import fl.skins.DefaultComboBoxSkins;

import flash.display.MovieClip;
import flash.display.SimpleButton;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;

import ghostbusters.client.fight.common.*;

[SWF(width="305", height="330", frameRate="30")]
public class MicrogameTestApp extends Sprite
{
    public function MicrogameTestApp ()
    {
        if (null == MainLoop.instance) {
            new MainLoop(this);
        }

        MainLoop.instance.setup();

        ResourceManager.instance.queueResourceLoad("swf", "testGhost", { embeddedClass: SWF_LANTERNGHOST });
        ResourceManager.instance.loadQueuedResources(handleResourcesLoaded);
    }

    protected function handleResourcesLoaded () :void
    {
        // bg
        this.graphics.beginFill(0xFFFFFF);
        this.graphics.drawRect(0, 0, 305, 330);
        this.graphics.endFill();

        // instructions
        var label :TextField = new TextField();
        label.text = "Press GO! to start playing";
        label.textColor = 0;;
        label.autoSize = TextFieldAutoSize.LEFT;
        label.x = (MicrogameConstants.GAME_WIDTH / 2) - (label.width / 2);
        label.y = (MicrogameConstants.GAME_HEIGHT / 2) - (label.height / 2);
        this.addChild(label);

        // start/stop buttons
        var startButton :SimpleButton = new SimpleTextButton("Go!");
        startButton.x = 0;
        startButton.y = MicrogameConstants.GAME_HEIGHT + 70;
        startButton.addEventListener(MouseEvent.CLICK, start);
        this.addChild(startButton);

        var stopButton :SimpleButton = new SimpleTextButton("Stop!");
        stopButton.x = startButton.width + 2;
        stopButton.y = MicrogameConstants.GAME_HEIGHT + 70;
        stopButton.addEventListener(MouseEvent.CLICK, stop);
        this.addChild(stopButton);

        // create weapon buttons
        var loc :Point = new Point(0, MicrogameConstants.GAME_HEIGHT + 5);

        for (var i :uint = 0; i < WEAPON_TYPES.length; ++i) {
            var weaponTypeName :String = WEAPON_TYPES[i];

            var button :SimpleButton = new SimpleTextButton(weaponTypeName);
            button.x = loc.x;
            button.y = loc.y;
            button.addEventListener(MouseEvent.CLICK, this.createButtonHandler(weaponTypeName));

            this.addChild(button);

            loc.x += button.width + 2;
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

        // init player
        var context :MicrogameContext = new MicrogameContext();

        context.ghostMovie = SwfResource.getSwfDisplayRoot("testGhost") as MovieClip;
        _player = new MicrogamePlayer(context);
        this.addChild(_player);

        _curWeaponTypeName = WeaponType.NAME_LANTERN;
        _curWeaponDifficulty = 0;
        _player.weaponType = new WeaponType(_curWeaponTypeName, _curWeaponDifficulty);

        this.addEventListener(Event.ENTER_FRAME, onEnterFrame, false, 0, true);
    }

    protected function createButtonHandler (weaponTypeName :String) :Function
    {
        return function (e :Event) :void { changeWeaponTypeName(weaponTypeName); };
    }

    protected function stop (e :Event) :void
    {
        if (this.isPlaying) {
            _player.cancelCurrentGame();
        }
    }

    protected function start (e :Event) :void
    {
        if (!this.isPlaying) {
            _player.beginNextGame();
        }
    }

    protected function changeWeaponTypeName (weaponTypeName :String) :void
    {
        if (weaponTypeName != _curWeaponTypeName) {
            var wasPlaying :Boolean = this.isPlaying;

            _curWeaponTypeName = weaponTypeName;
            _player.weaponType = new WeaponType(_curWeaponTypeName, _curWeaponDifficulty);

            if (wasPlaying) {
                _player.beginNextGame();
            }
        }
    }

    protected function onDifficultyChanged (e :Event) :void
    {
        var difficultySelect :ComboBox = (e.target as ComboBox);

        var newDifficulty :int = difficultySelect.selectedIndex;

        if (newDifficulty != _curWeaponDifficulty) {
            var wasPlaying :Boolean = this.isPlaying;

            _curWeaponDifficulty = newDifficulty;
            _player.weaponType = new WeaponType(_curWeaponTypeName, _curWeaponDifficulty);

            if (wasPlaying) {
                _player.beginNextGame();
            }
        }

    }

    protected function onEnterFrame (e :Event) :void
    {
        if (this.isPlaying && _player.currentGame.isDone) {
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

    protected function get isPlaying () :Boolean
    {
        return (null != _player.currentGame);
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

    /* Lantern */
    [Embed(source="../../../rsrc/Ghosts/Ghost_Duchess.swf", mimeType="application/octet-stream")]
    protected static const SWF_LANTERNGHOST :Class;

}

}
