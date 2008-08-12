package popcraft {

import com.threerings.flash.TextFieldUtil;
import com.threerings.util.ArrayUtil;
import com.threerings.util.Log;
import com.whirled.contrib.simplegame.*;
import com.whirled.contrib.simplegame.objects.SimpleTimer;
import com.whirled.contrib.simplegame.resource.SwfResource;
import com.whirled.net.ElementChangedEvent;
import com.whirled.game.OccupantChangedEvent;
import com.whirled.net.PropertyChangedEvent;

import flash.display.DisplayObject;
import flash.display.Graphics;
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.display.StageQuality;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.text.TextField;

import popcraft.data.GameVariantData;
import popcraft.ui.UIBits;

public class GameLobbyMode extends AppMode
{
    override protected function setup () :void
    {
        super.setup();

        var bg :MovieClip = SwfResource.getSwfDisplayRoot("multiplayer") as MovieClip;
        this.modeSprite.addChild(bg);

        // create headshots
        for (var seat :int = 0; seat < SeatingManager.numExpectedPlayers; ++seat) {
            _headshots.push(new PlayerHeadshot(seat));
        }

        // handle clicks on the team boxes
        for (var teamId :int = -1; teamId < NUM_TEAMS; ++teamId) {
            this.createTeamBoxMouseListener(bg, teamId);
        }

        _statusText = bg["instructions"];

        _handicapCheckbox = bg["handicap"];
        _handicapCheckbox.addEventListener(MouseEvent.CLICK, onHandicapBoxClicked);
        this.handicapOn = false;

        AppContext.gameCtrl.net.addEventListener(PropertyChangedEvent.PROPERTY_CHANGED, onPropChanged);
        AppContext.gameCtrl.net.addEventListener(ElementChangedEvent.ELEMENT_CHANGED, onElemChanged);
        AppContext.gameCtrl.game.addEventListener(OccupantChangedEvent.OCCUPANT_LEFT, onOccupantLeft);

        if (SeatingManager.isLocalPlayerInControl) {
            // initialize everything if we're the first player
            MultiplayerConfig.gameStarting = false;
            MultiplayerConfig.teams = ArrayUtil.create(NUM_TEAMS, -1);
            MultiplayerConfig.handicaps = ArrayUtil.create(SeatingManager.numExpectedPlayers, false);
            MultiplayerConfig.randSeed = uint(Math.random() * uint.MAX_VALUE);
            MultiplayerConfig.morbidInfections = ArrayUtil.create(SeatingManager.numExpectedPlayers, false);
            MultiplayerConfig.inited = true;
        }

        this.updateTeamsDisplay();
        this.updateHandicapsDisplay();
    }

    override protected function destroy () :void
    {
        super.destroy();

        AppContext.gameCtrl.net.removeEventListener(PropertyChangedEvent.PROPERTY_CHANGED, onPropChanged);
        AppContext.gameCtrl.net.removeEventListener(ElementChangedEvent.ELEMENT_CHANGED, onElemChanged);
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

    protected function createTeamBoxMouseListener (bg :MovieClip, teamId :int) :void
    {
        var boxName :String = (teamId >= 0 ? TEAM_BOX_NAMES[teamId] : UNASSIGNED_BOX_NAME);
        var teamBox :MovieClip = bg[boxName];
        teamBox.addEventListener(MouseEvent.CLICK,
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

        // other players need to know if we have the Morbid Infection trophy
        if (!_hasSetMorbidInfection && MultiplayerConfig.inited) {
            if (Constants.DEBUG_GIVE_MORBID_INFECTION) {
                AppContext.globalPlayerStats.hasMorbidInfection = true;
            }

            if (AppContext.globalPlayerStats.hasMorbidInfection) {
                MultiplayerConfig.setPlayerHasMorbidInfection(SeatingManager.localPlayerSeat);
            }

            _hasSetMorbidInfection = true;
        }

        var statusText :String = "";

        if (!this.allPlayersDecided) {
            statusText = "Divide into teams! Players on smaller teams will earn more resources.";
        } else if (!this.teamsDividedProperly) {
            statusText = "Two teams are required to start the game."
        } else if (!_gameStartTimer.isNull) {
            var timer :SimpleTimer = _gameStartTimer.object as SimpleTimer;
            statusText = "Starting in " + Math.ceil(timer.timeLeft) + "...";
        }

        _statusText.text = statusText;
    }

    protected function onPropChanged (e :PropertyChangedEvent) :void
    {
        if (e.name == MultiplayerConfig.PROP_INITED && Boolean(e.newValue)) {
            this.updateTeamsDisplay();
            this.updateHandicapsDisplay();
        } else if (e.name == MultiplayerConfig.PROP_GAMESTARTING && Boolean(e.newValue)) {
            this.startGame();
        }
    }

    protected function onElemChanged (e :ElementChangedEvent) :void
    {
        if (e.name == MultiplayerConfig.PROP_TEAMS) {
            this.updateTeamsDisplay();
            this.stopOrResetTimer();
        } else if (e.name == MultiplayerConfig.PROP_HANDICAPS) {
            this.updateHandicapsDisplay();
            this.stopOrResetTimer();
        }
    }

    protected function startGame () :void
    {
        GameContext.gameType = GameContext.GAME_TYPE_MULTIPLAYER;

        // @TODO - change this when we have real game variants
        var variants :Array = AppContext.gameVariants;
        var variant :GameVariantData = variants[0];
        GameContext.gameData = variant.gameDataOverride;

        // turn the inited flag off before the game starts
        // so that future game lobbies don't start immediately
        if (SeatingManager.isLocalPlayerInControl) {
            MultiplayerConfig.inited = false;
        }

        AppContext.mainLoop.unwindToMode(new GameMode());
    }

    protected function onOccupantLeft (...ignored) :void
    {
        this.stopOrResetTimer();
        this.updateTeamsDisplay();
    }

    protected function onHandicapBoxClicked (...ignored) :void
    {
        var playerHandicaps :Array = MultiplayerConfig.handicaps;
        if (null != playerHandicaps) {
            this.handicapOn = !this.handicapOn;
            if (this.handicapOn != playerHandicaps[SeatingManager.localPlayerSeat]) {
                MultiplayerConfig.setPlayerHandicap(SeatingManager.localPlayerSeat, this.handicapOn);
                this.updateHandicapsDisplay();
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

        // don't allow team selection changes with < 2 seconds on the timer
        if (!_gameStartTimer.isNull) {
            var timer :SimpleTimer = _gameStartTimer.object as SimpleTimer;
            if (timer.timeLeft < 2) {
                return;
            }
        }

        // don't allow team selection on teams that are full
        var teamSizes :Array = this.computeTeamSizes();
        if (teamSizes[teamId] >= MAX_TEAM_SIZE) {
            return;
        }

        var teams :Array = MultiplayerConfig.teams;
        if (null != teams && teams[SeatingManager.localPlayerSeat] != teamId) {
            MultiplayerConfig.setPlayerTeam(SeatingManager.localPlayerSeat, teamId);
            this.updateTeamsDisplay();
            this.stopOrResetTimer();
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

        for (var teamId :int = -1; teamId < NUM_TEAMS; ++teamId) {
            var boxLoc :Point = (teamId == -1 ? UNASSIGNED_BOX_LOC : TEAM_BOX_LOCS[teamId]);
            var yLoc :Number = boxLoc.y;

            for (var playerSeat :int = 0; playerSeat < SeatingManager.numExpectedPlayers; ++playerSeat) {
                if (teams[playerSeat] == teamId) {
                    var headshot :PlayerHeadshot = _headshots[playerSeat];
                    headshot.x = boxLoc.x;
                    headshot.y = yLoc;

                    if (null == headshot.parent) {
                        this.modeSprite.addChild(headshot);
                    }

                    yLoc += HEADSHOT_OFFSET;
                }
            }
        }
    }

    protected function stopOrResetTimer () :void
    {
        this.destroyObject(_gameStartTimer);

        if (this.canStartCountdown) {
            _gameStartTimer = this.addObject(
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
                if (teamId < 0) {
                    return false;
                }
            }
        }

        return true;
    }

    protected function get teamsDividedProperly () :Boolean
    {
        // does one team have all the players?
        var teamSizes :Array = this.computeTeamSizes();
        for each (var teamSize :int in teamSizes) {
            if (teamSize == SeatingManager.numPlayers) {
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

    protected var _headshots :Array = [];
    protected var _statusText :TextField;
    protected var _handicapCheckbox :MovieClip;
    protected var _handicapOn :Boolean;
    protected var _hasSetMorbidInfection :Boolean;
    protected var _gameStartTimer :SimObjectRef = new SimObjectRef();

    protected static var log :Log = Log.getLog(GameLobbyMode);

    protected static const TEAM_BOX_LOCS :Array = [
        new Point(240, 78),
        new Point(468, 78),
        new Point(240, 291),
        new Point(468, 291) ];

    protected static const UNASSIGNED_BOX_LOC :Point = new Point(30, 78);

    protected static const TEAM_BOX_NAMES :Array = [ "red_box", "blue_box", "green_box", "yellow_box" ];
    protected static const UNASSIGNED_BOX_NAME :String = "unassigned_box";

    protected static const HEADSHOT_OFFSET :Number = 62;

    protected static const STATUS_TEXT_LOC :Point = new Point(350, 470);
    protected static const GAME_START_COUNTDOWN :Number = 5;
    protected static const NUM_TEAMS :int = 4;
    protected static const MAX_TEAM_SIZE :int = 3;
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

class PlayerHeadshot extends Sprite
{
    public function PlayerHeadshot (playerSeat :int)
    {
        var headshotParent :Sprite = new Sprite();
        this.addChild(headshotParent);

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
        this.addChild(tfName);

        _handicapObj = SwfResource.instantiateMovieClip("multiplayer", "handicapped");
        _handicapObj.scaleX = 1.5;
        _handicapObj.scaleY = 1.5;
        _handicapObj.x = (_handicapObj.width * 0.5) + 1;
        _handicapObj.y = (_handicapObj.height * 0.5) + 1;
        _handicapObj.visible = false;
        this.addChild(_handicapObj);
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

    protected static const HEADSHOT_SIZE :Point = new Point(60, 60);
    protected static const NAME_OFFSET :Number = HEADSHOT_SIZE.x + 3;
    protected static const NAME_MAX_WIDTH :Number = 120;
}
