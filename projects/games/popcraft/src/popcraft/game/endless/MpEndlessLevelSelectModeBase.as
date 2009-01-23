package popcraft.game.endless {

import com.threerings.util.Log;
import com.whirled.net.ElementChangedEvent;
import com.whirled.net.PropertyChangedEvent;

import flash.display.Graphics;
import flash.display.Sprite;

import popcraft.*;
import popcraft.game.*;
import popcraft.data.EndlessLevelData;
import popcraft.data.UnitData;
import popcraft.lobby.MultiplayerFailureMode;
import popcraft.util.SpriteUtil;

public class MpEndlessLevelSelectModeBase extends EndlessLevelSelectModeBase
{
    public function MpEndlessLevelSelectModeBase (mode:int)
    {
        super(mode);
    }

    override public function update (dt :Number) :void
    {
        super.update(dt);

        if (!ClientContext.seatingMgr.allPlayersPresent) {
            ClientContext.mainLoop.unwindToMode(new MultiplayerFailureMode());
        }
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

        if (ClientContext.seatingMgr.isLocalPlayerInControl) {
            EndlessMultiplayerConfig.init(2);
        }

        if (EndlessMultiplayerConfig.inited) {
            // send our saved games to the server
            initLocalPlayerData();
        }

        registerListener(ClientContext.gameCtrl.net, PropertyChangedEvent.PROPERTY_CHANGED,
            onPropChanged);
        registerListener(ClientContext.gameCtrl.net, ElementChangedEvent.ELEMENT_CHANGED,
            onElemChanged);

        ClientContext.endlessLevelMgr.playMpLevel(onLevelLoaded);

        tryCreateUi();
    }

    override protected function selectMap (mapIndex :int, animationType :int) :void
    {
        super.selectMap(mapIndex, animationType);

        if (ClientContext.seatingMgr.isLocalPlayerInControl) {
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
            EndlessMultiplayerConfig.setPlayerSavedGames(ClientContext.seatingMgr.localPlayerSeat,
                ClientContext.endlessLevelMgr.savedMpGames);
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
                selectMap(newMapIndex, animationType);
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
        for each (var saveList :SavedEndlessGameList in EndlessMultiplayerConfig.savedGames) {
            // get the correct save for this player, or create a new one if it doesn't
            // already exist
            var save :SavedEndlessGame = saveList.getSave(mapIdx);
            if (save == null) {
                save = SavedEndlessGame.create(mapIdx, 0, 0, 1, _level.getWorkshopMaxHealth(0));
            }
            saves.push(save);
        }

        if (_helpView != null) {
            _helpView.visible = false;
        }

        animateToMode(new EndlessGameMode(true, _level, saves, true));
    }

    protected function onElemChanged (e :ElementChangedEvent) :void
    {
        tryCreateUi();
    }

    override protected function getLocalSavedGames () :SavedEndlessGameList
    {
        return ClientContext.endlessLevelMgr.savedMpGames;
    }

    override protected function getRemoteSavedGames () :SavedEndlessGameList
    {
        var saves :Array = EndlessMultiplayerConfig.savedGames;
        for (var ii :int = 0; ii < saves.length; ++ii) {
            if (ii != ClientContext.seatingMgr.localPlayerSeat) {
                return saves[ii];
            }
        }

        return null;
    }

    override protected function onPlayClicked (save :SavedEndlessGame) :void
    {
        if (ClientContext.seatingMgr.isLocalPlayerInControl) {
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
        return ClientContext.seatingMgr.isLocalPlayerInControl;
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
