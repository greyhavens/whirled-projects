package popcraft.sp.endless {

import com.whirled.contrib.simplegame.AppMode;

import flash.display.Graphics;
import flash.display.SimpleButton;
import flash.events.MouseEvent;

import popcraft.*;
import popcraft.data.EndlessLevelData;
import popcraft.data.EndlessMapData;
import popcraft.ui.UIBits;

public class EndlessLevelSelectMode extends AppMode
{
    override protected function setup () :void
    {
        super.setup();

        var g :Graphics = this.modeSprite.graphics;
        g.beginFill(0);
        g.drawRect(0, 0, Constants.SCREEN_SIZE.x, Constants.SCREEN_SIZE.y);
        g.endFill();

        // we need to load the endless level in order to create the UI
        if (this.isMultiplayer) {
            AppContext.endlessLevelMgr.playMpLevel(createUi);
        } else {
            AppContext.endlessLevelMgr.playSpLevel(createUi);
        }
    }

    protected function createUi (level :EndlessLevelData) :void
    {
        _level = level;

        var y :Number = 40;
        var x :Number = 40;

        var saves :Array = (this.isMultiplayer ? AppContext.endlessLevelMgr.savedMpGames :
            AppContext.endlessLevelMgr.savedSpGames);

        layoutButton(null);
        for each (var savedGame :SavedEndlessGame in saves) {
            layoutButton(savedGame);
        }

        function layoutButton (save :SavedEndlessGame) :void {
            var button :SimpleButton = createSavedGameButton(save);
            button.x = x;
            button.y = y;
            registerOneShotCallback(button, MouseEvent.CLICK,
                function (...ignored) :void {
                    startGame(save);
                });

            _modeSprite.addChild(button);

            y += button.height + 4;
        }
    }

    protected function createSavedGameButton (save :SavedEndlessGame) :SimpleButton
    {
        var mapData :EndlessMapData;
        var cycleNumber :int;

        if (save != null) {
            mapData = _level.getMapData(save.mapIndex);
            cycleNumber = _level.getMapCycleNumber(save.mapIndex);
        } else {
            mapData = _level.getMapData(0);
            cycleNumber = 0;
        }

        var buttonName :String = mapData.displayName + " (" + String(cycleNumber + 1) + ")";
        return UIBits.createButton(buttonName, 2);
    }

    protected function startGame (save :SavedEndlessGame) :void
    {
        GameContext.gameType = (this.isMultiplayer ? GameContext.GAME_TYPE_ENDLESS_MP :
            GameContext.GAME_TYPE_ENDLESS_SP);

        AppContext.mainLoop.unwindToMode(new EndlessGameMode(_level, save, true));
    }

    protected function get isMultiplayer () :Boolean
    {
        return SeatingManager.numExpectedPlayers > 1;
    }

    protected function get isSinglePlayer () :Boolean
    {
        return !isMultiplayer;
    }

    protected var _level :EndlessLevelData;
}

}
