package popcraft {

import core.AppMode;
import core.MainLoop;
import core.ResourceManager;
import com.threerings.util.Assert;

import flash.display.DisplayObjectContainer;
import flash.display.SimpleButton;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.text.TextField;

public class GameMode extends AppMode
{
    public static function get instance () :GameMode
    {
        var instance :GameMode = (MainLoop.instance.topMode as GameMode);

        Assert.isNotNull(instance);

        return instance;
    }

    public function GameMode ()
    {
    }

    // from core.AppMode
    override public function setup () :void
    {
        _playerData = new PlayerData();

        // load resources
        ResourceManager.instance.loadImage("melee", "rsrc/melee.png");

        _waitingOnResources = true;
    }

    override public function update(dt :Number) :void
    {
        if (_waitingOnResources) {
            // don't get started until we have all our resources
            if (ResourceManager.instance.hasPendingResources) {
                return;
            }

            _waitingOnResources = false;

            // add the top-level game objects

            var resourceDisplay :ResourceDisplay = new ResourceDisplay();
            resourceDisplay.displayObject.x = GameConstants.RESOURCE_DISPLAY_LOC.x;
            resourceDisplay.displayObject.y = GameConstants.RESOURCE_DISPLAY_LOC.y;

            this.addObject(resourceDisplay, this);

            _puzzleBoard = new PuzzleBoard(
                GameConstants.PUZZLE_COLS,
                GameConstants.PUZZLE_ROWS,
                GameConstants.PUZZLE_TILE_SIZE);

            _puzzleBoard.displayObject.x = GameConstants.PUZZLE_LOC.x;
            _puzzleBoard.displayObject.y = GameConstants.PUZZLE_LOC.y;

            this.addObject(_puzzleBoard, this);

            _battleBoard = new BattleBoard(
                GameConstants.BATTLE_COLS,
                GameConstants.BATTLE_ROWS,
                GameConstants.BATTLE_TILE_SIZE);

            _battleBoard.displayObject.x = GameConstants.BATTLE_LOC.x;
            _battleBoard.displayObject.y = GameConstants.BATTLE_LOC.y;

            this.addObject(_battleBoard, this);

            // create some buttons
            var meleeButton :SimpleButton =
                GameMode.createUnitPurchaseButton(GameConstants.CREATURE_MELEE);

            meleeButton.x = GameConstants.MELEE_BUTTON_LOC.x;
            meleeButton.y = GameConstants.MELEE_BUTTON_LOC.y;
            this.addChild(meleeButton);

            // @TEMP
            var creature :Creature = new Creature();
            creature.displayObject.x = 50;
            creature.displayObject.y = 50;

            this.addObject(creature, _battleBoard.displayObjectContainer);
        }

        super.update(dt);
    }

    public function get playerData () :PlayerData
    {
        return _playerData;
    }

    protected static function createUnitPurchaseButton (creatureType :uint) :SimpleButton
    {
        var data :CreatureData = GameConstants.CREATURE_DATA[creatureType];
        var iconData :BitmapData = ResourceManager.instance.getImage(data.name);

        var button :SimpleButton = new SimpleButton();
        var foreground :int = uint(0xFF0000);
        var background :int = uint(0xCDC9C9);
        var highlight :int = uint(0x888888);
        button.upState = makeButtonFace(iconData, foreground, background);
        button.overState = makeButtonFace(iconData, highlight, background);
        button.downState = makeButtonFace(iconData, background, highlight);
        button.hitTestState = button.upState;

        // how much does it cost?
        /*var costString :String = new String();
        for (var resType :uint = 0; resType < GameConstants.RESOURCE__LIMIT; ++resType) {
            var resData :ResourceType = GameConstants.getResource(resType);
            var resCost
            costString += (resData.name + " (" + data.getResourceCost(resType) + ")");
            if(

        }
        var costText :TextField = new TextField();
        //costText.text*/

        return button;
    }

    protected static function makeButtonFace (iconData :BitmapData, foreground :uint, background :uint) :Sprite
    {
        var face :Sprite = new Sprite();

        var icon :Bitmap = new Bitmap(iconData);
        face.addChild(icon);

        var padding :int = 5;
        var w :Number = icon.width + 2 * padding;
        var h :Number = icon.height + 2 * padding;

        // draw our button background (and outline)
        face.graphics.beginFill(background);
        face.graphics.lineStyle(1, foreground);
        face.graphics.drawRect(0, 0, w, h);
        face.graphics.endFill();

        icon.x = padding;
        icon.y = padding;

        return face;
    }

    protected var _waitingOnResources :Boolean;
    protected var _puzzleBoard :PuzzleBoard;
    protected var _battleBoard :BattleBoard;
    protected var _playerData :PlayerData;
}

}
