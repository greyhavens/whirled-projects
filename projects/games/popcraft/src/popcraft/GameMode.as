package popcraft {

import com.threerings.flash.Vector2;
import com.threerings.util.ArrayUtil;
import com.threerings.util.Assert;
import com.threerings.util.ClassUtil;
import com.threerings.util.KeyboardCodes;
import com.threerings.util.Log;
import com.whirled.contrib.simplegame.*;
import com.whirled.contrib.simplegame.audio.*;
import com.whirled.contrib.simplegame.net.*;
import com.whirled.contrib.simplegame.resource.*;
import com.whirled.contrib.simplegame.util.*;
import com.whirled.game.OccupantChangedEvent;
import com.whirled.game.StateChangedEvent;

import flash.display.DisplayObjectContainer;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.geom.Point;

import popcraft.battle.*;
import popcraft.battle.geom.ForceParticleContainer;
import popcraft.battle.view.*;
import popcraft.data.*;
import popcraft.mp.*;
import popcraft.net.*;
import popcraft.puzzle.*;
import popcraft.sp.*;
import popcraft.sp.story.*;
import popcraft.ui.*;
import popcraft.util.*;

public class GameMode extends TransitionMode
{
    public function GameMode ()
    {
        if (ClassUtil.getClass(this) == GameMode) {
            throw new Error("GameMode is abstract");
        }
    }

    override protected function setup () :void
    {
        Profiler.reset();

        GameContext.gameMode = this;
        GameContext.playerStats = new PlayerStats();

        // init RNGs
        var randSeed :uint = createRandSeed();
        Rand.seedStream(AppContext.randStreamPuzzle, randSeed);
        Rand.seedStream(Rand.STREAM_GAME, randSeed);
        log.info("Starting game with seed: " + randSeed);

        // allow subclasses to do some post-RNG-seeding early setup
        rngSeeded();

        // cache some frequently-used values in GameContext
        GameContext.mapScaleXInv = 1 / GameContext.gameMode.mapSettings.mapScaleX;
        GameContext.mapScaleYInv = 1 / GameContext.gameMode.mapSettings.mapScaleY;
        GameContext.scaleSprites = GameContext.gameMode.mapSettings.scaleSprites;

        // create some layers
        GameContext.battleLayer = new Sprite();
        GameContext.dashboardLayer = new Sprite();
        GameContext.overlayLayer = new Sprite();
        _modeLayer.addChild(GameContext.battleLayer);
        _modeLayer.addChild(GameContext.dashboardLayer);
        _modeLayer.addChild(GameContext.overlayLayer);

        setupAudio();
        setupNetwork();
        setupPlayers();
        setupBattle();
        setupDashboard();

        if (Constants.DEBUG_DRAW_STATS) {
            _debugDataView = new DebugDataView();
            this.addObject(_debugDataView, GameContext.overlayLayer);
            _debugDataView.visible = true;
        }
    }

    override protected function destroy () :void
    {
        shutdownNetwork();
        shutdownPlayers();
        shutdownAudio();

        Profiler.displayStats();
    }

    override protected function enter () :void
    {
        // game audio isn't started until _updateCount hits 1,
        // to allow intro screens to be shown
        if (_updateCount > 0) {
            GameContext.sfxControls.pause(false);
            GameContext.musicControls.pause(false);
            GameContext.musicControls.volumeTo(1, 0.3);
        }
    }

    override protected function exit () :void
    {
        if (GameContext.sfxControls != null) {
            GameContext.sfxControls.pause(true);
        }

        if (GameContext.musicControls != null) {
            GameContext.musicControls.volumeTo(0.2, 0.3);
        }
    }

    protected function setupAudio () :void
    {
        GameContext.playAudio = this.playAudio;

        GameContext.sfxControls = new AudioControls(
            AudioManager.instance.getControlsForSoundType(SoundResource.TYPE_SFX));
        GameContext.musicControls = new AudioControls(
            AudioManager.instance.getControlsForSoundType(SoundResource.TYPE_MUSIC));

        GameContext.sfxControls.retain();
        GameContext.musicControls.retain();

        GameContext.sfxControls.pause(true);
        GameContext.musicControls.pause(true);
    }

    protected function shutdownAudio () :void
    {
        GameContext.sfxControls.stop(true);
        GameContext.musicControls.stop(true);

        GameContext.sfxControls.release();
        GameContext.musicControls.release();
    }

    protected function setupPlayers () :void
    {
        createPlayers();

        // setup players' target enemies
        for each (var playerInfo :PlayerInfo in GameContext.playerInfos) {
            playerInfo.targetedEnemyId =
                GameContext.findEnemyForPlayer(playerInfo.playerIndex).playerIndex;
        }

        // create players' unit spell sets (these are synchronized objects)
        GameContext.playerCreatureSpellSets = [];
        for (var playerIndex :int = 0; playerIndex < GameContext.numPlayers; ++playerIndex) {
            var spellSet :CreatureSpellSet = new CreatureSpellSet();
            GameContext.netObjects.addObject(spellSet);
            GameContext.playerCreatureSpellSets.push(spellSet);
        }

        // we want to know when a player leaves
        this.registerEventListener(AppContext.gameCtrl.game, OccupantChangedEvent.OCCUPANT_LEFT,
            handleOccupantLeft);
    }

    protected function shutdownPlayers () :void
    {
    }

    protected function handleOccupantLeft (e :OccupantChangedEvent) :void
    {
        if (e.player) {
            // did a player leave?
            var playerInfo :PlayerInfo = ArrayUtil.findIf(GameContext.playerInfos,
                function (data :PlayerInfo) :Boolean {
                    return data.whirledId == e.occupantId;
                });

            if (null != playerInfo) {
                playerInfo.leftGame = true;
            }
        }
    }

    protected function handleGameEndedPrematurely (...ignored) :void
    {
        // If the game ends prematurely for some reason, handle it gracefully
        AppContext.mainLoop.unwindToMode(new MultiplayerFailureMode());
    }

    protected function setupNetwork () :void
    {
        // create a special ObjectDB for all objects that are synchronized over the network.
        GameContext.netObjects = new NetObjectDB();

        // set up the message manager
        // TODO - change this to be more like zyraxxus messages
        _messageMgr = createMessageManager();
        _messageMgr.addMessageFactory(CreateUnitMessage.messageName,
            CreateUnitMessage.createFactory());
        _messageMgr.addMessageFactory(SelectTargetEnemyMessage.messageName,
            SelectTargetEnemyMessage.createFactory());
        _messageMgr.addMessageFactory(CastCreatureSpellMessage.messageName,
            CastCreatureSpellMessage.createFactory());

        if (AppContext.gameCtrl.isConnected()) {
            this.registerEventListener(AppContext.gameCtrl.game, StateChangedEvent.GAME_ENDED,
                handleGameEndedPrematurely);
        }

        _messageMgr.setup();
    }

    protected function shutdownNetwork () :void
    {
        _messageMgr.shutdown();
    }

    protected function setupDashboard () :void
    {
        var dashboard :DashboardView = new DashboardView();
        dashboard.x = DASHBOARD_LOC.x;
        dashboard.y = DASHBOARD_LOC.y;
        this.addObject(dashboard, GameContext.dashboardLayer);

        GameContext.dashboard = dashboard;

        var puzzleBoard :PuzzleBoard = new PuzzleBoard(PUZZLE_COLS, PUZZLE_ROWS, PUZZLE_TILE_SIZE);

        puzzleBoard.displayObject.x = PUZZLE_BOARD_LOC.x;
        puzzleBoard.displayObject.y = PUZZLE_BOARD_LOC.y;

        DisplayObjectContainer(dashboard.displayObject).addChildAt(puzzleBoard.displayObject, 0);
        this.addObject(puzzleBoard);

        GameContext.puzzleBoard = puzzleBoard;
    }

    protected function setupBattle () :void
    {
        GameContext.unitFactory = new UnitFactory();

        GameContext.forceParticleContainer = new ForceParticleContainer(
            GameContext.gameMode.battlefieldWidth,
            GameContext.gameMode.battlefieldHeight);

        // Board
        var battleBoardView :BattleBoardView = new BattleBoardView(BATTLE_WIDTH, BATTLE_HEIGHT);
        this.addObject(battleBoardView, GameContext.battleLayer);

        GameContext.battleBoardView = battleBoardView;

        // create player bases
        createWorkshops(GameContext.playerInfos);

        // Day/night cycle
        GameContext.diurnalCycle = new DiurnalCycle();
        GameContext.netObjects.addObject(GameContext.diurnalCycle);

        if (!DiurnalCycle.isDisabled) {
            var diurnalMeter :DiurnalCycleView = new DiurnalCycleView();
            diurnalMeter.x = DIURNAL_METER_LOC.x;
            diurnalMeter.y = DIURNAL_METER_LOC.y;
            this.addObject(diurnalMeter, GameContext.battleBoardView.diurnalMeterParent);
        }

        GameContext.netObjects.addObject(new SpellDropTimer());

        _trophyWatcher = new TrophyWatcher();
    }

    override public function onKeyDown (keyCode :uint) :void
    {
        if (_gameOver) {
            return;
        }

        switch (keyCode) {
        case KeyboardCodes.A:
            this.localPlayerPurchasedCreature(Constants.UNIT_TYPE_COLOSSUS);
            break;

        case KeyboardCodes.S:
            this.localPlayerPurchasedCreature(Constants.UNIT_TYPE_COURIER);
            break;

        case KeyboardCodes.D:
            this.localPlayerPurchasedCreature(Constants.UNIT_TYPE_SAPPER);
            break;

        case KeyboardCodes.F:
            this.localPlayerPurchasedCreature(Constants.UNIT_TYPE_HEAVY);
            break;

        case KeyboardCodes.G:
            this.localPlayerPurchasedCreature(Constants.UNIT_TYPE_GRUNT);
            break;

        case KeyboardCodes.ESCAPE:
            if (this.canPause) {
                AppContext.mainLoop.pushMode(new PauseMode());
            }
            break;

        case KeyboardCodes.NUMBER_5:
            if (null != _debugDataView) {
                _debugDataView.visible = !(_debugDataView.visible);
            }
            break;

        default:
            if (Constants.DEBUG_ALLOW_CHEATS) {
                this.applyCheatCode(keyCode);
            }
            break;
        }
    }

    protected function applyCheatCode (keyCode :uint) :void
    {
        switch (keyCode) {
        case KeyboardCodes.NUMBER_4:
            for (var i :int = 0; i < Constants.RESOURCE__LIMIT; ++i) {
                GameContext.localPlayerInfo.offsetResourceAmount(i, 500);
            }
            break;

        case KeyboardCodes.B:
            this.spellDeliveredToPlayer(GameContext.localPlayerIndex,
                Constants.SPELL_TYPE_BLOODLUST);
            break;

        case KeyboardCodes.R:
            this.spellDeliveredToPlayer(GameContext.localPlayerIndex,
                Constants.SPELL_TYPE_RIGORMORTIS);
            break;

        case KeyboardCodes.P:
            this.spellDeliveredToPlayer(GameContext.localPlayerIndex,
                Constants.SPELL_TYPE_PUZZLERESET);
            break;

        case KeyboardCodes.N:
            GameContext.diurnalCycle.resetPhase(Constants.PHASE_NIGHT);
            break;

        case KeyboardCodes.Y:
            GameContext.diurnalCycle.incrementDayCount();
            GameContext.diurnalCycle.resetPhase(
                GameContext.gameData.enableEclipse ? Constants.PHASE_ECLIPSE :
                Constants.PHASE_DAY);
            break;

        case KeyboardCodes.K:
            // destroy the targeted enemy's base
            var enemyPlayerInfo :PlayerInfo =
                GameContext.playerInfos[GameContext.localPlayerInfo.targetedEnemyId];
            var enemyBase :WorkshopUnit = enemyPlayerInfo.workshop;
            if (null != enemyBase) {
                enemyBase.health = 0;
            }
            break;

        case KeyboardCodes.W:
            // destroy all enemy bases
            for each (var playerInfo :PlayerInfo in GameContext.playerInfos) {
                if (playerInfo.teamId != GameContext.localPlayerInfo.teamId) {
                    enemyBase = playerInfo.workshop;
                    if (null != enemyBase) {
                        enemyBase.health = 0;
                    }
                }
            }
            break;
        }
    }

    // from AppMode
    override public function update (dt :Number) :void
    {
        if (!_gameIsRunning) {
            // don't start doing anything until the messageMgr is ready
            if (_messageMgr.isReady) {
                _gameIsRunning = true;
            } else if (!SeatingManager.allPlayersPresent) {
                // If a player leaves before the game starts, the messageMgr will never
                // be ready.
                AppContext.mainLoop.unwindToMode(new MultiplayerFailureMode());
                return;
            } else {
                return;
            }
        } else if (_gameOver) {
            // stop processing game logic when the game is over
            super.update(dt);
            return;
        }

        // start the game audio when _updateCount hits 1, allowing a full update to pass without
        // audio so that intro screens can be shown
        if (_updateCount == 1) {
            GameContext.musicControls.pause(false);
            GameContext.sfxControls.pause(false);
        }

        // update the network
        _messageMgr.update(dt);

        // if the network simulation is updated, we'll need to depth-sort
        // the battlefield display objects
        var sortDisplayChildren :Boolean = (_messageMgr.unprocessedTickCount > 0);

        while (_messageMgr.unprocessedTickCount > 0) {

            // process all messages from this tick
            var messageArray: Array = _messageMgr.getNextTick();
            for each (var msg :Message in messageArray) {
                handleMessage(msg);
            }

            // run the simulation the appropriate amount
            // (our network update time is unrelated to the application's update time.
            // network timeslices are always the same distance apart)
            GameContext.netObjects.update(TICK_INTERVAL_S);

            ++_gameTickCount;
            _gameTime += TICK_INTERVAL_S;
        }

        checkForGameOver();

        // update all non-net objects
        super.update(dt);

        if (sortDisplayChildren) {
            GameContext.battleBoardView.sortUnitDisplayChildren();
        }

        // update the game music, unless we're in "eclipse mode", where we loop
        // the night music forever
        var dayPhase :int = GameContext.diurnalCycle.phaseOfDay;
        if (!_startedMusic || (dayPhase != _lastDayPhase && !GameContext.gameData.enableEclipse)) {
            if (null != _musicChannel) {
                _musicChannel.audioControls.fadeOut(0.5).stopAfter(0.5);
            }

            _musicChannel = GameContext.playGameMusic(
                DiurnalCycle.isDay(dayPhase) ? "mus_day" : "mus_night");

            _lastDayPhase = dayPhase;
            _startedMusic = true;
        }

        ++_updateCount;
    }

    protected function checkForGameOver () :void
    {
        // The game is over if there's only one team standing
        var liveTeamId :int = -1;
        _gameOver = true;
        for each (var playerInfo :PlayerInfo in GameContext.playerInfos) {
            // for the purposes of game-over detection, discount invincible players from the
            // live player count. this is kind of ugly - the last level is the only level
            // in which there's an invincible player (Professor Weardd).
            if (!playerInfo.leftGame && playerInfo.isAlive && !playerInfo.isInvincible) {
                var playerTeam :int = playerInfo.teamId;
                if (playerTeam != liveTeamId) {
                    if (liveTeamId == -1) {
                        liveTeamId = playerTeam;
                    } else {
                        // there's more than one live team
                        _gameOver = false;
                        break;
                    }
                }
            }
        }

        if (_gameOver) {
            GameContext.playerStats.totalGameTime = _gameTime;
            GameContext.winningTeamId = liveTeamId;

            handleGameOver();
        }
    }

    protected function handleGameOver () :void
    {
        throw new Error("abstract");
    }

    protected function handleMessage (msg :Message) :void
    {
        var playerIndex :int;

        switch (msg.name) {
        case CreateUnitMessage.messageName:
            var createUnitMsg :CreateUnitMessage = (msg as CreateUnitMessage);
            playerIndex = createUnitMsg.playerIndex;
            if (PlayerInfo(GameContext.playerInfos[playerIndex]).isAlive) {
                GameContext.unitFactory.createCreature(createUnitMsg.unitType, playerIndex);
                var baseView :WorkshopView = WorkshopView.getForPlayer(playerIndex);
                if (null != baseView) {
                    baseView.unitCreated();
                }
            }
            break;

        case SelectTargetEnemyMessage.messageName:
            var selectTargetEnemyMsg :SelectTargetEnemyMessage = msg as SelectTargetEnemyMessage;
            playerIndex = selectTargetEnemyMsg.playerIndex;
            if (PlayerInfo(GameContext.playerInfos[playerIndex]).isAlive) {
                this.setTargetEnemy(playerIndex, selectTargetEnemyMsg.targetPlayerIndex);
            }
            break;

        case CastCreatureSpellMessage.messageName:
            var castSpellMsg :CastCreatureSpellMessage = msg as CastCreatureSpellMessage;
            playerIndex = castSpellMsg.playerIndex;
            if (PlayerInfo(GameContext.playerInfos[playerIndex]).isAlive) {
                var spellSet :CreatureSpellSet = GameContext.playerCreatureSpellSets[playerIndex];
                var spell :CreatureSpellData = GameContext.gameData.spells[castSpellMsg.spellType];
                spellSet.addSpell(spell.clone() as CreatureSpellData);
                GameContext.playGameSound("sfx_" + spell.name);
            }
            break;
        }

    }

    protected function setTargetEnemy (playerIndex :int, targetEnemyId :int) :void
    {
        var playerInfo :PlayerInfo = GameContext.playerInfos[playerIndex];
        playerInfo.targetedEnemyId = targetEnemyId;

        if (playerIndex == GameContext.localPlayerIndex) {
            this.updateTargetEnemyBadgeLocation(targetEnemyId);
        }
    }

    protected function updateTargetEnemyBadgeLocation (targetEnemyId :int) :void
    {
        // move the "target enemy" badge to the correct base
        var baseViews :Array = WorkshopView.getAll();
        for each (var baseView :WorkshopView in baseViews) {
            baseView.targetEnemyBadgeVisible =
                (baseView.workshop.owningPlayerIndex == targetEnemyId);
        }
    }

    protected function createWorkshops (playerInfos :Array) :void
    {
        var localPlayerInfo :PlayerInfo = GameContext.localPlayerInfo;
        for each (var playerInfo :PlayerInfo in playerInfos) {
            var view :WorkshopView = GameContext.unitFactory.createWorkshop(playerInfo);
            var workshop :WorkshopUnit = view.workshop;

            var loc :Vector2 = playerInfo.baseLoc.loc;
            workshop.x = loc.x;
            workshop.y = loc.y;

            var isEnemy :Boolean = (workshop.owningPlayerInfo.teamId != localPlayerInfo.teamId);

            // add click listeners to enemy workshops
            if (isEnemy && !workshop.isInvincible) {
                this.registerEventListener(
                    view.clickableObject,
                    MouseEvent.MOUSE_DOWN,
                    this.createBaseViewClickListener(view));
            }

            playerInfo.workshop = workshop;
        }

        this.updateTargetEnemyBadgeLocation(localPlayerInfo.targetedEnemyId);
    }

    protected function createBaseViewClickListener (baseView :WorkshopView) :Function
    {
        return function (...ignored) :void {
            enemyBaseViewClicked(baseView);
        }
    }

    protected function enemyBaseViewClicked (enemyBaseView :WorkshopView) :void
    {
        // when the player clicks on an enemy base, that enemy becomes the player's target
        var localPlayerInfo :PlayerInfo = GameContext.localPlayerInfo;
        var newTargetEnemyId :int = enemyBaseView.workshop.owningPlayerIndex;

        Assert.isTrue(newTargetEnemyId != GameContext.localPlayerIndex);

        if (newTargetEnemyId != localPlayerInfo.targetedEnemyId) {
            // update the "target enemy badge" location immediately, even though
            // the change won't be reflected in the game logic until the message round-trips
            this.updateTargetEnemyBadgeLocation(newTargetEnemyId);

            // send a message to everyone
            this.selectTargetEnemy(GameContext.localPlayerIndex, newTargetEnemyId);
        }
    }

    public function creatureKilled (creature :CreatureUnit, killingPlayerIndex :int) :void
    {
        if (killingPlayerIndex == GameContext.localPlayerIndex) {
            GameContext.playerStats.creaturesKilled[creature.unitType] += 1;

            if (!TrophyManager.hasTrophy(TrophyManager.TROPHY_WHATAMESS) &&
                (AppContext.globalPlayerStats.totalCreaturesKilled + GameContext.playerStats.totalCreaturesKilled) >= TrophyManager.WHATAMESS_NUMCREATURES) {
                // awarded for killing 2500 creatures total
                TrophyManager.awardTrophy(TrophyManager.TROPHY_WHATAMESS);
            }
        }
    }

    public function spellDeliveredToPlayer (playerIndex :int, spellType :int) :void
    {
        // called when a courier delivers a spell back to its workshop
        if (spellType < Constants.CASTABLE_SPELL_TYPE__LIMIT) {
            PlayerInfo(GameContext.playerInfos[playerIndex]).addSpell(spellType);
        }
    }

    public function selectTargetEnemy (playerIndex :int, enemyId :int) :void
    {
        _messageMgr.sendMessage(new SelectTargetEnemyMessage(playerIndex, enemyId));
    }

    public function localPlayerPurchasedCreature (unitType :int) :void
    {
        if (!this.isAvailableUnit(unitType) ||
            !GameContext.localPlayerInfo.canAffordCreature(unitType)) {
            return;
        }

        this.buildCreature(GameContext.localPlayerIndex, unitType);

        // when the sun is eclipsed, it's buy-one-get-one-free time!
        if (GameContext.diurnalCycle.isEclipse) {
            this.buildCreature(GameContext.localPlayerIndex, unitType, true);
        }
    }

    public function buildCreature (playerIndex :int, unitType :int, noCost :Boolean = false) :void
    {
        var playerInfo :PlayerInfo = GameContext.playerInfos[playerIndex];

        if (!playerInfo.isAlive || GameContext.diurnalCycle.isDay ||
            (!noCost && !playerInfo.canAffordCreature(unitType))) {
            return;
        }

        if (!noCost) {
            playerInfo.deductCreatureCost(unitType);
        }

        _messageMgr.sendMessage(new CreateUnitMessage(playerIndex, unitType));

        if (playerIndex == GameContext.localPlayerIndex) {
            GameContext.playerStats.creaturesCreated[unitType] += 1;
        }
    }

    public function castSpell (playerIndex :int, spellType :int) :void
    {
        var playerInfo :PlayerInfo = GameContext.playerInfos[playerIndex];
        var isCreatureSpell :Boolean = (spellType < Constants.CREATURE_SPELL_TYPE__LIMIT);

        if (!playerInfo.isAlive || (isCreatureSpell && GameContext.diurnalCycle.isDay) ||
            !playerInfo.canCastSpell(spellType)) {
            return;
        }

        playerInfo.spellCast(spellType);

        if (isCreatureSpell) {
            _messageMgr.sendMessage(new CastCreatureSpellMessage(playerIndex, spellType));
        } else if (spellType == Constants.SPELL_TYPE_PUZZLERESET) {
            // there's only one non-creature spell
            GameContext.dashboard.puzzleShuffle();
        }

        GameContext.playerStats.spellsCast[spellType] += 1;
    }

    public function playerEarnedResources (resourceType :int, offset :int, numClearPieces :int) :int
    {
        return GameContext.localPlayerInfo.earnedResources(resourceType, offset, numClearPieces);
    }

    public function get playAudio () :Boolean
    {
        return true;
    }

    public function get canPause () :Boolean
    {
        return false;
    }

    public function isAvailableUnit (unitType :int) :Boolean
    {
        return true;
    }

    public function get availableSpells () :Array
    {
        return Constants.CASTABLE_SPELLS;
    }

    public function get battlefieldWidth () :Number
    {
        return (BATTLE_WIDTH * mapSettings.mapScaleX);
    }

    public function get battlefieldHeight () :Number
    {
        return (BATTLE_HEIGHT * mapSettings.mapScaleY);
    }

    public function get mapSettings () :MapSettingsData
    {
        throw new Error("abstract");
    }

    protected function createRandSeed () :uint
    {
        throw new Error("abstract");
    }

    protected function rngSeeded () :void
    {
        // no-op - subclasses can override to do any early setup that requires the RNG to
        // be set up
    }

    protected function createPlayers () :void
    {
        throw new Error("abstract");
    }

    protected function createMessageManager () :TickedMessageManager
    {
        throw new Error("abstract");
    }

    protected var _gameIsRunning :Boolean;

    protected var _messageMgr :TickedMessageManager;
    protected var _debugDataView :DebugDataView;
    protected var _musicChannel :AudioChannel;
    protected var _lastDayPhase :int = -1;
    protected var _startedMusic :Boolean;
    protected var _gameOver :Boolean;

    protected var _gameTickCount :int;
    protected var _gameTime :Number;
    protected var _updateCount :int;

    protected var _trophyWatcher :TrophyWatcher;

    protected static const TICK_INTERVAL_MS :int = 100; // 1/10 of a second
    protected static const TICK_INTERVAL_S :Number = (Number(TICK_INTERVAL_MS) / Number(1000));

    protected static const CHECKSUM_BUFFER_LENGTH :int = 10;

    protected static const FADE_OUT_TIME :Number = 3;

    protected static const DASHBOARD_LOC :Point = new Point(350, 430);
    protected static const PUZZLE_BOARD_LOC :Point = new Point(-131, -63);
    protected static const DIURNAL_METER_LOC :Point = new Point(0, 0);

    protected static const BATTLE_WIDTH :int = 700;
    protected static const BATTLE_HEIGHT :int = 372;

    protected static const PUZZLE_HEIGHT :int = 110;
    protected static const PUZZLE_COLS :int = 12;
    protected static const PUZZLE_ROWS :int = 5;
    protected static const PUZZLE_TILE_SIZE :int = int(PUZZLE_HEIGHT / PUZZLE_ROWS) + 1;

    protected static const log :Log = Log.getLog(GameMode);
}

}
