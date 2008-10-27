package popcraft.sp.endless {

import com.threerings.util.Log;
import com.whirled.net.ElementChangedEvent;
import com.whirled.net.PropertyChangedEvent;

import flash.display.Graphics;
import flash.display.Sprite;

import popcraft.*;
import popcraft.data.EndlessLevelData;
import popcraft.data.UnitData;
import popcraft.util.SpriteUtil;

public class MpEndlessLevelSelectModeBase extends EndlessLevelSelectModeBase
{
    public function MpEndlessLevelSelectModeBase (mode:int)
    {
        super(mode);
    }

    override public function update(dt:Number):void
    {
        super.update(dt);
    }

    override protected function setup () :void
    {
        super.setup();

        // create a "Waiting for players..." overlay
        _waitScreen = SpriteUtil.createSprite(false, true);
        var g :Graphics = _waitScreen.graphics;
        g.beginFill(0, 0);
        g.drawRect(0, 0, Constants.SCREEN_SIZE.x, Constants.SCREEN_SIZE.y);
        g.endFill();
        /*var waitText :TextField = UIBits.createText("Waiting for players...", 2, 0, 0xFFFFFF);
        waitText.x = (Constants.SCREEN_SIZE.x - waitText.width) * 0.5;
        waitText.y = (Constants.SCREEN_SIZE.y - waitText.height) * 0.5;
        _waitScreen.addChild(waitText);*/
        _modeSprite.addChild(_waitScreen);

        if (SeatingManager.isLocalPlayerInControl) {
            EndlessMultiplayerConfig.init(2);
        }

        if (EndlessMultiplayerConfig.inited) {
            // send our saved games to the server
            initLocalPlayerData();
        }

        registerListener(AppContext.gameCtrl.net, PropertyChangedEvent.PROPERTY_CHANGED,
            onPropChanged);
        registerListener(AppContext.gameCtrl.net, ElementChangedEvent.ELEMENT_CHANGED,
            onElemChanged);

        AppContext.endlessLevelMgr.playMpLevel(onLevelLoaded);

        tryCreateUi();
    }

    override protected function selectMap (mapIndex :int, animationType :int,
        removeModeUnderneath :Boolean) :void
    {
        super.selectMap(mapIndex, animationType, removeModeUnderneath);

        if (SeatingManager.isLocalPlayerInControl) {
            EndlessMultiplayerConfig.selectedMapIdx = mapIndex;
        }
    }

    override protected function onLevelLoaded (level :EndlessLevelData) :void
    {
        _level = level;
        tryCreateUi();
    }

    protected function tryCreateUi () :void
    {
        if (isDataReady && !_createdUi) {
            _waitScreen.visible = false;
            createUi(_level);
            _createdUi = true;
        }
    }

    protected function get isDataReady () :Boolean
    {
        return (_level != null &&
            EndlessMultiplayerConfig.inited &&
            EndlessMultiplayerConfig.areSavedGamesValid);
    }

    protected function initLocalPlayerData () :void
    {
        if (!_initedLocalPlayerData) {
            EndlessMultiplayerConfig.setPlayerSavedGames(SeatingManager.localPlayerSeat,
                AppContext.endlessLevelMgr.savedMpGames);
            _initedLocalPlayerData = true;
        }
    }

    protected function onPropChanged (e :PropertyChangedEvent) :void
    {
        if (e.name == EndlessMultiplayerConfig.PROP_INITED && Boolean(e.newValue)) {
            initLocalPlayerData();
        } else if (_createdUi && e.name == EndlessMultiplayerConfig.PROP_SELECTEDMAPIDX) {
            var newMapIndex :int = EndlessMultiplayerConfig.selectedMapIdx;
            if (newMapIndex != _mapIndex) {
                var animationType :int;
                if (newMapIndex > _mapIndex || (newMapIndex == 0 && _mapIndex == _highestMapIndex)) {
                    animationType = ANIMATE_NEXT;
                } else {
                    animationType = ANIMATE_PREV;
                }
                selectMap(newMapIndex, animationType, false);
            }

        } else if (e.name == EndlessMultiplayerConfig.PROP_GAMESTARTING && Boolean(e.newValue)) {
            onGameStarting();
        }

        tryCreateUi();
    }

    protected function onGameStarting () :void
    {
        // get the proper saved games
        var saves :Array = [];
        var mapIdx :int = EndlessMultiplayerConfig.selectedMapIdx;
        var workshopData :UnitData = _level.gameDataOverride.units[Constants.UNIT_TYPE_WORKSHOP];
        for each (var saveList :SavedEndlessGameList in EndlessMultiplayerConfig.savedGames) {
            // get the correct save for this player, or create a new one if it doesn't
            // already exist
            var save :SavedEndlessGame = saveList.getSave(mapIdx);
            if (save == null) {
                save = SavedEndlessGame.create(mapIdx, 0, 1, workshopData.maxHealth);
            }
            saves.push(save);
        }

        animateToMode(new EndlessGameMode(_level, saves, true));
    }

    protected function onElemChanged (e :ElementChangedEvent) :void
    {
        tryCreateUi();
    }

    override protected function getLocalSavedGames () :SavedEndlessGameList
    {
        return AppContext.endlessLevelMgr.savedMpGames;
    }

    override protected function getRemoteSavedGames () :SavedEndlessGameList
    {
        var saves :Array = EndlessMultiplayerConfig.savedGames;
        for (var ii :int = 0; ii < saves.length; ++ii) {
            if (ii != SeatingManager.localPlayerSeat) {
                return saves[ii];
            }
        }

        return null;
    }

    override protected function onPlayClicked (save :SavedEndlessGame) :void
    {
        if (SeatingManager.isLocalPlayerInControl) {
            // let everyone know the game is starting
            EndlessMultiplayerConfig.gameStarting = true;
            // set inited to false for the next time this screen is visited
            EndlessMultiplayerConfig.inited = false;
        }
    }

    override protected function onQuitClicked (...ignored) :void
    {
        // TODO
    }

    override protected function get enableNextPrevPlayButtons () :Boolean
    {
        // only the player in control gets to change levels or start the game
        return SeatingManager.isLocalPlayerInControl;
    }

    override protected function get enableQuitButton () :Boolean
    {
        return false;
    }

    protected var _showingWaitScreen :Boolean;
    protected var _waitScreen :Sprite;
    protected var _createdUi :Boolean;

    protected static const log :Log = Log.getLog(MpEndlessLevelSelectModeBase);
}

}
