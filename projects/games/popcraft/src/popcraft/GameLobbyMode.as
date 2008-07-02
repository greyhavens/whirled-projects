package popcraft {

import com.threerings.flash.TextFieldUtil;
import com.threerings.util.ArrayUtil;
import com.whirled.contrib.simplegame.*;
import com.whirled.contrib.simplegame.objects.SimpleTimer;
import com.whirled.contrib.simplegame.resource.SwfResource;
import com.whirled.game.ElementChangedEvent;
import com.whirled.game.OccupantChangedEvent;
import com.whirled.game.PropertyChangedEvent;

import flash.display.DisplayObject;
import flash.display.Graphics;
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.display.StageQuality;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;

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

        _statusText = new TextField();
        _statusText.selectable = false;
        _statusText.scaleX = 1.5;
        _statusText.scaleY = 1.5;
        _statusText.background = true;
        _statusText.backgroundColor = 0;
        _statusText.textColor = 0xFFFFFF;
        _statusText.autoSize = TextFieldAutoSize.LEFT;
        _statusText.x = STATUS_TEXT_LOC.x;
        _statusText.y = STATUS_TEXT_LOC.y;
        this.modeSprite.addChild(_statusText);

        _handicapCheckbox = bg["handicap"];
        _handicapCheckbox.addEventListener(MouseEvent.CLICK, onHandicapBoxClicked);
        _handicapOn = false;

        AppContext.gameCtrl.net.addEventListener(PropertyChangedEvent.PROPERTY_CHANGED, onPropChanged);
        AppContext.gameCtrl.net.addEventListener(ElementChangedEvent.ELEMENT_CHANGED, onElemChanged);
        AppContext.gameCtrl.game.addEventListener(OccupantChangedEvent.OCCUPANT_LEFT, onOccupantLeft);

        if (SeatingManager.isLocalPlayerInControl) {
            // initialize everything if we're the first player
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
        _statusText.x = (Constants.SCREEN_SIZE.x * 0.5) - (_statusText.width * 0.5);
    }

    protected function onPropChanged (e :PropertyChangedEvent) :void
    {
        if (e.name == MultiplayerConfig.PROP_INITED) {
            this.updateTeamsDisplay();
            this.updateHandicapsDisplay();
        }
    }

    protected function onElemChanged (e :ElementChangedEvent) :void
    {
        if (e.name == MultiplayerConfig.PROP_TEAMS) {
            this.updateTeamsDisplay();
        } else if (e.name == MultiplayerConfig.PROP_HANDICAPS) {
            this.updateHandicapsDisplay();
        }
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
        _handicapCheckbox.gotoAndStop(_handicapOn ? 0 : 1);
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
            _gameStartTimer = this.addObject(new SimpleTimer(GAME_START_COUNTDOWN, timerExpired));
        }
    }

    protected function timerExpired () :void
    {
        GameContext.gameType = GameContext.GAME_TYPE_MULTIPLAYER;

        // @TODO - remove this testing code
        var variants :Array = AppContext.gameVariants;
        var variant :GameVariantData = variants[0];
        GameContext.gameData = variant.gameDataOverride;

        // turn the inited flag off before the game starts
        // so that future
        if (SeatingManager.isLocalPlayerInControl) {
            MultiplayerConfig.inited = false;
        }

        AppContext.mainLoop.unwindToMode(new GameMode());
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
        var teams :Array = MultiplayerConfig.teams;

        // how large is each team?
        var teamSizes :Array = ArrayUtil.create(NUM_TEAMS, 0);
        for (var playerSeat :int = 0; playerSeat < teams.length; ++playerSeat) {
            if (SeatingManager.isPlayerPresent(playerSeat)) {
                var teamId :int = teams[playerSeat];
                if (teamId >= 0) {
                    teamSizes[teamId] += 1;
                }
            }
        }

        // does one team have all the players?
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

    protected var _headshots :Array = [];
    protected var _statusText :TextField;
    protected var _handicapCheckbox :MovieClip;
    protected var _handicapOn :Boolean;
    protected var _hasSetMorbidInfection :Boolean;
    protected var _gameStartTimer :SimObjectRef = new SimObjectRef();

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
    protected static const GAME_START_COUNTDOWN :Number = 3;
    protected static const NUM_TEAMS :int = 4;
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

import com.threerings.flash.TextFieldUtil;

import popcraft.*;
import popcraft.ui.UIBits;

class PlayerHeadshot extends Sprite
{
    public function PlayerHeadshot (playerSeat :int)
    {
        var headshot :DisplayObject = SeatingManager.getPlayerHeadshot(playerSeat);
        var scale :Number = Math.min(HEADSHOT_WIDTH / headshot.width, HEADSHOT_HEIGHT / headshot.height);
        headshot.scaleX = scale;
        headshot.scaleY = scale;
        this.addChild(headshot);

        var tfName :TextField = UIBits.createText(SeatingManager.getPlayerName(playerSeat), 1.5);
        TextFieldUtil.setMaximumTextWidth(tfName, NAME_MAX_WIDTH);
        tfName.x = NAME_OFFSET;
        tfName.y = (HEADSHOT_HEIGHT * 0.5) - (tfName.height * 0.5);
        this.addChild(tfName);

        _handicapObj = new Shape();
        var g :Graphics = _handicapObj.graphics;
        g.beginFill(0xFF0000);
        g.drawRect(0, 0, 15, 15);
        g.endFill();
    }

    public function set handicap (val :Boolean) :void
    {
        if (val == _handicapOn) {
            return;
        }

        _handicapOn = val;

        if (_handicapOn) {
            this.addChild(_handicapObj);
        } else {
            this.removeChild(_handicapObj);
        }
    }

    protected var _handicapOn :Boolean;
    protected var _handicapObj :Shape;

    protected static const HEADSHOT_WIDTH :Number = 60;
    protected static const HEADSHOT_HEIGHT :Number = 60;

    protected static const NAME_OFFSET :Number = HEADSHOT_WIDTH + 3;
    protected static const NAME_MAX_WIDTH :Number = 120;
}
