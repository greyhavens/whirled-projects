package popcraft.mp {

import com.threerings.flash.TextFieldUtil;
import com.threerings.util.ArrayUtil;
import com.threerings.util.Log;
import com.whirled.contrib.simplegame.*;
import com.whirled.contrib.simplegame.objects.SimpleTimer;
import com.whirled.contrib.simplegame.resource.SwfResource;
import com.whirled.game.GameContentEvent;
import com.whirled.game.OccupantChangedEvent;
import com.whirled.net.ElementChangedEvent;
import com.whirled.net.PropertyChangedEvent;

import flash.display.DisplayObject;
import flash.display.Graphics;
import flash.display.MovieClip;
import flash.display.SimpleButton;
import flash.display.Sprite;
import flash.display.StageQuality;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.text.TextField;

import popcraft.*;
import popcraft.data.GameVariantData;
import popcraft.sp.endless.MpEndlessLevelSelectMode;
import popcraft.ui.UIBits;

public class MultiplayerLobbyMode extends AppMode
{
    override protected function setup () :void
    {
        super.setup();

        _bg = SwfResource.getSwfDisplayRoot("multiplayer_lobby") as MovieClip;
        this.modeSprite.addChild(_bg);

        // create headshots
        for (var seat :int = 0; seat < SeatingManager.numExpectedPlayers; ++seat) {
            _headshots.push(new PlayerHeadshot(seat));
        }

        // handle clicks on the team boxes
        if (SeatingManager.numExpectedPlayers == 2) {
            createTeamBoxMouseListener(_bg, ENDLESS_TEAM_ID);
        } else {
            _endlessWarnText = UIBits.createText(
                "Team Survival is accessible in 2-player games only", 1.2, 0, 0x444444);
            _endlessWarnText.x = ENDLESS_MODE_WARN_LOC.x - (_endlessWarnText.width * 0.5);
            _endlessWarnText.y = ENDLESS_MODE_WARN_LOC.y - (_endlessWarnText.height * 0.5);
            _bg.addChild(_endlessWarnText);
        }

        for (var teamId :int = UNASSIGNED_TEAM_ID; teamId < NUM_TEAMS; ++teamId) {
            createTeamBoxMouseListener(_bg, teamId);
        }

        _statusText = _bg["instructions"];

        registerListener(AppContext.gameCtrl.net, PropertyChangedEvent.PROPERTY_CHANGED,
            onPropChanged);
        registerListener(AppContext.gameCtrl.net, ElementChangedEvent.ELEMENT_CHANGED,
            onElemChanged);
        registerListener(AppContext.gameCtrl.game, OccupantChangedEvent.OCCUPANT_LEFT,
            onOccupantLeft);

        if (SeatingManager.isLocalPlayerInControl) {
            // initialize everything if we're the first player
            MultiplayerConfig.init(NUM_TEAMS, SeatingManager.numExpectedPlayers);
        }

        if (MultiplayerConfig.inited) {
            initLocalPlayerData();
        }

        _handicapCheckbox = _bg["handicap"];
        registerListener(_handicapCheckbox, MouseEvent.CLICK, onHandicapBoxClicked);
        this.handicapOn = false;

        updateHandicapsDisplay();
        updateTeamsDisplay();
        updatePremiumContentDisplay();

        registerListener(AppContext.gameCtrl.player, GameContentEvent.PLAYER_CONTENT_ADDED,
            onPlayerPurchasedContent);
    }

    override protected function enter () :void
    {
        super.enter();
        StageQualityManager.pushStageQuality(StageQuality.HIGH);
    }

    override protected function exit () :void
    {
        super.exit();
        StageQualityManager.popStageQuality();
    }

    protected function onPlayerPurchasedContent (e :GameContentEvent) :void
    {
        if (e.contentType == GameContentEvent.LEVEL_PACK &&
            e.contentIdent == Constants.PREMIUM_SP_LEVEL_PACK_NAME) {
            MultiplayerConfig.setPlayerHasPremiumContent(SeatingManager.localPlayerSeat);
        }
    }

    protected function initLocalPlayerData () :void
    {
        if (Constants.DEBUG_GIVE_MORBID_INFECTION) {
            AppContext.globalPlayerStats.hasMorbidInfection = true;
        }

        if (AppContext.globalPlayerStats.hasMorbidInfection) {
            MultiplayerConfig.setPlayerHasMorbidInfection(SeatingManager.localPlayerSeat);
        }

        if (AppContext.isEndlessModeUnlocked) {
            MultiplayerConfig.setPlayerHasPremiumContent(SeatingManager.localPlayerSeat);
        }

        _initedLocalPlayerData = true;
    }

    protected function createTeamBoxMouseListener (_bg :MovieClip, teamId :int) :void
    {
        var boxName :String;
        switch (teamId) {
        case UNASSIGNED_TEAM_ID:
            boxName = UNASSIGNED_BOX_NAME;
            break;

        case ENDLESS_TEAM_ID:
            boxName = ENDLESS_BOX_NAME;
            break;

        default:
            boxName = TEAM_BOX_NAMES[teamId];
            break;
        }

        var teamBox :MovieClip = _bg[boxName];
        registerListener(teamBox, MouseEvent.CLICK,
            function (...ignored) :void {
                onTeamSelected(teamId);
        });
    }

    override public function update (dt :Number) :void
    {
        super.update(dt);

        // has anybody left?
        // (currently, seated Whirled games will never start if any of the players fail
        // to check in, so we can't, e.g., try to seat a 2-player game if the third player leaves)
        // @TODO - change this if Whirled changes
        if (!SeatingManager.allPlayersPresent) {
            AppContext.mainLoop.unwindToMode(new MultiplayerFailureMode());
        }

        var statusText :String = "";

        if (!this.allPlayersDecided) {
            statusText = "Divide into teams!";
        } else if (!this.teamsDividedProperly) {
            statusText = "At least two teams are required to start the game."
        } else if (!_gameStartTimer.isNull) {
            var timer :SimpleTimer = _gameStartTimer.object as SimpleTimer;
            statusText = "Starting in " + Math.ceil(timer.timeLeft) + "...";
        }

        _statusText.text = statusText;
    }

    protected function onPropChanged (e :PropertyChangedEvent) :void
    {
        if (e.name == MultiplayerConfig.PROP_INITED && Boolean(e.newValue)) {
            if (!_initedLocalPlayerData) {
                initLocalPlayerData();
            }

            updateTeamsDisplay();
            updateHandicapsDisplay();

        } else if (e.name == MultiplayerConfig.PROP_GAMESTARTING && Boolean(e.newValue)) {
            startGame();
        }
    }

    protected function onElemChanged (e :ElementChangedEvent) :void
    {
        if (e.name == MultiplayerConfig.PROP_TEAMS) {
            updateTeamsDisplay();
            stopOrResetTimer();
        } else if (e.name == MultiplayerConfig.PROP_HANDICAPS) {
            updateHandicapsDisplay();
            stopOrResetTimer();
        } else if (e.name == MultiplayerConfig.PROP_HASPREMIUMCONTENT) {
            updatePremiumContentDisplay();
        }
    }

    protected function startGame () :void
    {
        // @TODO - change this when we have real game variants
        var variants :Array = AppContext.gameVariants;
        var variant :GameVariantData = variants[0];
        GameContext.gameData = variant.gameDataOverride;

        // turn the inited flag off before the game starts
        // so that future game lobbies don't start immediately
        if (SeatingManager.isLocalPlayerInControl) {
            MultiplayerConfig.inited = false;
        }

        if (this.isEndlessModeSelected) {
            AppContext.mainLoop.pushMode(new MpEndlessLevelSelectMode());
        } else {
            GameContext.gameType = GameContext.GAME_TYPE_BATTLE_MP;
            AppContext.mainLoop.unwindToMode(new MultiplayerGameMode());
        }
    }

    protected function onOccupantLeft (...ignored) :void
    {
        stopOrResetTimer();
        updateTeamsDisplay();
    }

    protected function onHandicapBoxClicked (...ignored) :void
    {
        var playerHandicaps :Array = MultiplayerConfig.handicaps;
        if (null != playerHandicaps) {
            this.handicapOn = !this.handicapOn;
            if (this.handicapOn != playerHandicaps[SeatingManager.localPlayerSeat]) {
                MultiplayerConfig.setPlayerHandicap(SeatingManager.localPlayerSeat, this.handicapOn);
                updateHandicapsDisplay();
            }
        }
    }

    protected function set handicapOn (val :Boolean) :void
    {
        _handicapOn = val;
        _handicapCheckbox.gotoAndStop(_handicapOn ? "checked" : "unchecked");
    }

    protected function get handicapOn () :Boolean
    {
        return _handicapOn;
    }

    protected function onTeamSelected (teamId :int) :void
    {
        if (!MultiplayerConfig.inited) {
            return;
        }

        // don't allow selection of the endless team unless there are 2 players
        // and somebody has unlocked the premium content
        if (teamId == ENDLESS_TEAM_ID &&  (SeatingManager.numExpectedPlayers != 2 ||
            !MultiplayerConfig.someoneHasPremiumContent)) {
            return;
        }

        // don't allow team selection changes with < 2 seconds on the timer
        if (!_gameStartTimer.isNull) {
            var timer :SimpleTimer = _gameStartTimer.object as SimpleTimer;
            if (timer.timeLeft < 2) {
                return;
            }
        }

        // don't allow team selection on teams that are full
        var teamSizes :Array = computeTeamSizes();
        if (teamSizes[teamId] >= MAX_TEAM_SIZE) {
            return;
        }

        var teams :Array = MultiplayerConfig.teams;
        if (null != teams && teams[SeatingManager.localPlayerSeat] != teamId) {
            MultiplayerConfig.setPlayerTeam(SeatingManager.localPlayerSeat, teamId);
            updateTeamsDisplay();
            stopOrResetTimer();
        }
    }

    protected function updateHandicapsDisplay () :void
    {
        var handicaps :Array = MultiplayerConfig.handicaps;
        if (null != handicaps) {
            for (var playerSeat :int = 0; playerSeat < SeatingManager.numExpectedPlayers; ++playerSeat) {
                var headshot :PlayerHeadshot = _headshots[playerSeat];
                headshot.handicap = handicaps[playerSeat];
            }
        }
    }

    protected function updateTeamsDisplay () :void
    {
        // "inited" will be set to true when the multiplayer configuration has
        // been reset by the player in control.
        if (!MultiplayerConfig.inited || null == MultiplayerConfig.teams) {
            return;
        }

        var teams :Array = MultiplayerConfig.teams;
        var handicaps :Array = MultiplayerConfig.handicaps;

        for (var teamId :int = ENDLESS_TEAM_ID; teamId < NUM_TEAMS; ++teamId) {
            var boxLoc :Point;
            switch (teamId) {
            case UNASSIGNED_TEAM_ID:
                boxLoc = UNASSIGNED_BOX_LOC;
                break;

            case ENDLESS_TEAM_ID:
                boxLoc = ENDLESS_BOX_LOC;
                break;

            default:
                boxLoc = TEAM_BOX_LOCS[teamId];
                break;
            }

            var xLoc :Number = boxLoc.x;
            var yLoc :Number = boxLoc.y;

            for (var playerSeat :int = 0; playerSeat < SeatingManager.numExpectedPlayers; ++playerSeat) {
                if (teams[playerSeat] == teamId) {
                    var headshot :PlayerHeadshot = _headshots[playerSeat];
                    headshot.x = xLoc;
                    headshot.y = yLoc;

                    if (null == headshot.parent) {
                        this.modeSprite.addChild(headshot);
                    }

                    if (teamId == ENDLESS_TEAM_ID) {
                        xLoc += headshot.width;
                    } else {
                        yLoc += HEADSHOT_OFFSET;
                    }
                }
            }
        }
    }

    protected function updatePremiumContentDisplay () :void
    {
        var someoneHasPremiumContent :Boolean =
            (AppContext.isEndlessModeUnlocked || MultiplayerConfig.someoneHasPremiumContent);

        var unlockButton :SimpleButton = _bg["unlock_button"];

        if (!_showingPremiumContent && someoneHasPremiumContent) {
            unlockButton.visible = false;
            if (_endlessWarnText != null) {
                _endlessWarnText.visible = true;
            }
            _showingPremiumContent = true;

        } else if (!someoneHasPremiumContent) {
            unlockButton.visible = true;
            if (_endlessWarnText != null) {
                _endlessWarnText.visible = false;
            }
            registerListener(unlockButton, MouseEvent.CLICK,
                function (...ignored) :void {
                    AppContext.showGameShop();
                });
            _showingPremiumContent = false;
        }
    }

    protected function stopOrResetTimer () :void
    {
        destroyObject(_gameStartTimer);

        if (this.canStartCountdown) {
            _gameStartTimer = addObject(
                new SimpleTimer(
                    GAME_START_COUNTDOWN,
                    function () :void {
                        log.info("Seat " + SeatingManager.localPlayerSeat + " timer expired");
                        if (SeatingManager.isLocalPlayerInControl) {
                            log.info("Seat " + SeatingManager.localPlayerSeat + " starting game");
                            // let everyone know to start the game
                            MultiplayerConfig.gameStarting = true;
                        }
                    }));
        }
    }

    protected function get allPlayersDecided () :Boolean
    {
        var teams :Array = MultiplayerConfig.teams;

        if (null == teams) {
            return false;
        }

        for (var playerSeat :int = 0; playerSeat < teams.length; ++playerSeat) {
            if (SeatingManager.isPlayerPresent(playerSeat)) {
                var teamId :int = teams[playerSeat];
                if (teamId == UNASSIGNED_TEAM_ID) {
                    return false;
                }
            }
        }

        return true;
    }

    protected function get teamsDividedProperly () :Boolean
    {
        // if this is a two player game, and both players have chosen endless mode,
        // we can start the game
        if (this.isEndlessModeSelected) {
            return true;
        } else if (this.isSomeoneInEndlessMode) {
            // unless everyone has selected endless mode, nobody can select it
            return false;
        }

        // does one team have all the players?
        var teamSizes :Array = computeTeamSizes();
        for each (var teamSize :int in teamSizes) {
            if (teamSize == SeatingManager.numPlayers) {
                return false;
            }
        }

        return true;
    }

    protected function get isSomeoneInEndlessMode () :Boolean
    {
        var teams :Array = MultiplayerConfig.teams;
        for (var playerSeat :int = 0; playerSeat < SeatingManager.numExpectedPlayers; ++playerSeat) {
            if (SeatingManager.isPlayerPresent(playerSeat) && teams[playerSeat] == ENDLESS_TEAM_ID) {
                return true;
            }
        }

        return false;
    }

    protected function get isEndlessModeSelected () :Boolean
    {
        if (SeatingManager.numExpectedPlayers != 2) {
            return false;
        }

        var teams :Array = MultiplayerConfig.teams;
        for (var playerSeat :int = 0; playerSeat < SeatingManager.numExpectedPlayers; ++playerSeat) {
            if (!SeatingManager.isPlayerPresent(playerSeat) || teams[playerSeat] != ENDLESS_TEAM_ID) {
                return false;
            }
        }

        return true;
    }

    protected function get canStartCountdown () :Boolean
    {
        return this.allPlayersDecided && this.teamsDividedProperly;
    }

    protected function computeTeamSizes () :Array
    {
        var teams :Array = MultiplayerConfig.teams;
        var teamSizes :Array = ArrayUtil.create(NUM_TEAMS, 0);
        for (var playerSeat :int = 0; playerSeat < teams.length; ++playerSeat) {
            if (SeatingManager.isPlayerPresent(playerSeat)) {
                var teamId :int = teams[playerSeat];
                if (teamId >= 0) {
                    teamSizes[teamId] += 1;
                }
            }
        }

        return teamSizes;
    }

    protected var _bg :MovieClip;
    protected var _headshots :Array = [];
    protected var _statusText :TextField;
    protected var _handicapCheckbox :MovieClip;
    protected var _handicapOn :Boolean;
    protected var _initedLocalPlayerData :Boolean;
    protected var _gameStartTimer :SimObjectRef = new SimObjectRef();
    protected var _showingPremiumContent :Boolean;
    protected var _endlessWarnText :TextField;

    protected static var log :Log = Log.getLog(MultiplayerLobbyMode);

    protected static const TEAM_BOX_LOCS :Array = [
        new Point(240, 115),
        new Point(468, 115),
        new Point(240, 255),
        new Point(468, 255) ];

    protected static const UNASSIGNED_BOX_LOC :Point = new Point(30, 132);
    protected static const ENDLESS_BOX_LOC :Point = new Point(240, 435);

    protected static const ENDLESS_MODE_WARN_LOC :Point = new Point(455, 454);

    protected static const TEAM_BOX_NAMES :Array = [ "red_box", "blue_box", "green_box", "yellow_box" ];
    protected static const UNASSIGNED_BOX_NAME :String = "unassigned_box";
    protected static const ENDLESS_BOX_NAME :String = "survival_box";

    protected static const HEADSHOT_OFFSET :Number = 40;

    protected static const STATUS_TEXT_LOC :Point = new Point(350, 470);
    protected static const GAME_START_COUNTDOWN :Number = 5;
    protected static const NUM_TEAMS :int = 4;
    protected static const MAX_TEAM_SIZE :int = 3;

    protected static const UNASSIGNED_TEAM_ID :int = -1;
    protected static const ENDLESS_TEAM_ID :int = -2;
}

}

import flash.display.Sprite;
import flash.display.Graphics;
import flash.display.Shape;
import flash.display.SimpleButton;
import flash.events.MouseEvent;
import flash.events.Event;
import flash.display.DisplayObject;
import flash.text.TextField;
import flash.geom.Point;

import com.threerings.flash.TextFieldUtil;
import com.threerings.flash.DisplayUtil;

import com.whirled.contrib.simplegame.resource.SwfResource;

import popcraft.*;
import popcraft.ui.UIBits;
import popcraft.util.SpriteUtil;

class PlayerHeadshot extends Sprite
{
    public function PlayerHeadshot (playerSeat :int)
    {
        var headshotParent :Sprite = SpriteUtil.createSprite();
        addChild(headshotParent);

        // add the headshot image
        var headshot :DisplayObject = SeatingManager.getPlayerHeadshot(playerSeat);
        headshot.scaleX = 1;
        headshot.scaleY = 1;
        headshot.x = (HEADSHOT_SIZE.x - headshot.width) * 0.5;
        headshot.y = (HEADSHOT_SIZE.y - headshot.height) * 0.5;
        headshotParent.addChild(headshot);

        // mask the headshot
        var headshotMask :Shape = new Shape();
        var g :Graphics = headshotMask.graphics;
        g.beginFill(0);
        g.drawRect(0, 0, HEADSHOT_SIZE.x, HEADSHOT_SIZE.y);
        g.endFill();
        headshotParent.addChild(headshotMask);
        headshotParent.mask = headshotMask;

        // player name
        var tfName :TextField = UIBits.createText(SeatingManager.getPlayerName(playerSeat), 1.2);
        TextFieldUtil.setMaximumTextWidth(tfName, NAME_MAX_WIDTH);
        tfName.x = NAME_OFFSET;
        tfName.y = (HEADSHOT_SIZE.y - tfName.height) * 0.5;
        addChild(tfName);

        _handicapObj = SwfResource.instantiateMovieClip("multiplayer_lobby", "handicapped");
        _handicapObj.scaleX = 1.5;
        _handicapObj.scaleY = 1.5;
        _handicapObj.x = (_handicapObj.width * 0.5) + 1;
        _handicapObj.y = (_handicapObj.height * 0.5) + 1;
        _handicapObj.visible = false;
        addChild(_handicapObj);
    }

    public function set handicap (val :Boolean) :void
    {
        if (val == _handicapOn) {
            return;
        }

        _handicapOn = val;
        _handicapObj.visible = _handicapOn;
    }

    protected var _handicapOn :Boolean;
    protected var _handicapObj :DisplayObject;

    protected static const HEADSHOT_SIZE :Point = new Point(38, 38);
    protected static const NAME_OFFSET :Number = HEADSHOT_SIZE.x + 3;
    protected static const NAME_MAX_WIDTH :Number = 120;
}
