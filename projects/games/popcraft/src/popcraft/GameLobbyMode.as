package popcraft {

import com.threerings.util.ArrayUtil;
import com.whirled.contrib.simplegame.*;
import com.whirled.contrib.simplegame.objects.SimpleTimer;
import com.whirled.game.ElementChangedEvent;
import com.whirled.game.OccupantChangedEvent;
import com.whirled.game.PropertyChangedEvent;

import flash.display.Graphics;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;

import popcraft.data.GameVariantData;

public class GameLobbyMode extends SplashScreenModeBase
{
    override protected function setup () :void
    {
        super.setup();

        this.createTeamBox(-1);
        _numTeams = SeatingManager.numExpectedPlayers;
        for (var teamId :int = 0; teamId < _numTeams; ++teamId) {
            this.createTeamBox(teamId);
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

        _handicapCheckbox = new HandicapCheckbox();
        _handicapCheckbox.x = HANDICAP_BOX_LOC.x;
        _handicapCheckbox.y = HANDICAP_BOX_LOC.y;
        this.modeSprite.addChild(_handicapCheckbox);
        _handicapCheckbox.addEventListener(HandicapCheckbox.STATE_CHANGED, handicapChanged);

        _handicapText = new TextField();
        _handicapText.selectable = false;
        _handicapText.background = true;
        _handicapText.backgroundColor = 0;
        _handicapText.textColor = 0xFFFFFF;
        _handicapText.autoSize = TextFieldAutoSize.LEFT;
        _handicapText.x = HANDICAP_TEXT_LOC.x;
        _handicapText.y = HANDICAP_TEXT_LOC.y;
        _handicapText.text = "Handicap OFF";
        this.modeSprite.addChild(_handicapText);

        AppContext.gameCtrl.net.addEventListener(PropertyChangedEvent.PROPERTY_CHANGED, onPropChanged);
        AppContext.gameCtrl.net.addEventListener(ElementChangedEvent.ELEMENT_CHANGED, onElemChanged);
        AppContext.gameCtrl.game.addEventListener(OccupantChangedEvent.OCCUPANT_LEFT, onOccupantLeft);

        if (SeatingManager.isLocalPlayerInControl) {
            // initialize everything if we're the first player
            MultiplayerConfig.teams = ArrayUtil.create(SeatingManager.numExpectedPlayers, -1);
            MultiplayerConfig.handicaps = ArrayUtil.create(SeatingManager.numExpectedPlayers, false);
            MultiplayerConfig.randSeed = uint(Math.random() * uint.MAX_VALUE);
            MultiplayerConfig.morbidInfections = ArrayUtil.create(SeatingManager.numExpectedPlayers, false);
            MultiplayerConfig.inited = true;
        } else {
            this.updateDisplay();
        }
    }

    override protected function destroy () :void
    {
        super.destroy();

        AppContext.gameCtrl.net.removeEventListener(PropertyChangedEvent.PROPERTY_CHANGED, onPropChanged);
        AppContext.gameCtrl.net.removeEventListener(ElementChangedEvent.ELEMENT_CHANGED, onElemChanged);
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
        this.updateDisplay();
    }

    protected function onElemChanged (e :ElementChangedEvent) :void
    {
        this.stopOrResetTimer();
        this.updateDisplay();
    }

    protected function onOccupantLeft (...ignored) :void
    {
        this.stopOrResetTimer();
        this.updateDisplay();
    }

    protected function createTeamBox (teamId :int) :void
    {
        var loc :Point = (teamId >= 0 ? TEAM_BOX_LOCS[teamId] : UNASSIGNED_BOX_LOC);
        var size :Point = (teamId >= 0 ? TEAM_BOX_SIZE : UNASSIGNED_BOX_SIZE);

        var teamBox :Sprite = new Sprite();
        var g :Graphics = teamBox.graphics;
        g.beginFill(0x6868FF);
        g.drawRect(0, 0, size.x, size.y);
        g.endFill();
        teamBox.x = loc.x;
        teamBox.y = loc.y;

        // title text
        var tf :TextField = new TextField();
        tf.selectable = false;
        tf.scaleX = 2;
        tf.scaleY = 2;
        tf.text = (teamId >= 0 ? "Team " + String(teamId + 1) : "Undecided");
        tf.autoSize = TextFieldAutoSize.LEFT;
        tf.x = (teamBox.width * 0.5) - (tf.width * 0.5);
        tf.y = 12;

        teamBox.addChild(tf);

        // members text
        tf = new TextField();
        tf.selectable = false;
        tf.scaleX = 1.5;
        tf.scaleY = 1.5;
        tf.autoSize = TextFieldAutoSize.LEFT;
        tf.y = 50;

        _teamTexts[teamId] = tf;

        teamBox.addChild(tf);

        teamBox.addEventListener(MouseEvent.CLICK, function (...ignored) : void { teamSelected(teamId); } );
        this.modeSprite.addChild(teamBox);
    }

    protected function handicapChanged (...ignored) :void
    {
        var playerHandicaps :Array = MultiplayerConfig.handicaps;
        if (null != playerHandicaps) {
            var handicap :Boolean = _handicapCheckbox.checked;
            if (handicap != playerHandicaps[SeatingManager.localPlayerSeat]) {
                MultiplayerConfig.setPlayerHandicap(SeatingManager.localPlayerSeat, handicap);
                _handicapText.text = (handicap ? "Handicap ON" : "Handicap OFF");
                this.updateDisplay();
            }
        }
    }

    protected function teamSelected (teamId :int) :void
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
            this.updateDisplay();

            this.stopOrResetTimer();
        }
    }

    protected function updateDisplay () :void
    {
        // "inited" will be set to true when the multiplayer configuration has
        // been reset by the player in control.
        if (!MultiplayerConfig.inited) {
            return;
        }

        var teams :Array = MultiplayerConfig.teams;
        var handicaps :Array = MultiplayerConfig.handicaps;

        for (var teamId :int = -1; teamId < SeatingManager.numExpectedPlayers; ++teamId) {
            var text :String = "";

            if (null != teams) {
                for (var playerSeat :int = 0; playerSeat < SeatingManager.numExpectedPlayers; ++playerSeat) {
                    if (teams[playerSeat] == teamId) {
                        text += SeatingManager.getPlayerName(playerSeat);
                        if (handicaps[playerSeat]) {
                            text += " (handicap)";
                        }
                        text += "\n";
                    }
                }
            }

            if (text == "" && teamId >= 0) {
                text = "(no members)";
            }

            var teamText :TextField = _teamTexts[teamId];

            teamText.text = text;
            teamText.x = (teamText.parent.width * 0.5) - (teamText.width * 0.5);
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
        var teamSizes :Array = ArrayUtil.create(_numTeams, 0);
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

    protected var _numTeams :int;
    protected var _teamTexts :Array = [];
    protected var _statusText :TextField;
    protected var _handicapCheckbox :HandicapCheckbox;
    protected var _handicapText :TextField;
    protected var _hasSetMorbidInfection :Boolean;
    protected var _gameStartTimer :SimObjectRef = new SimObjectRef();

    protected static const TEAM_BOX_SIZE :Point = new Point(175, 150);
    protected static const TEAM_BOX_LOCS :Array = [
        new Point(50, 50), new Point(275, 50), new Point(50, 250), new Point(275, 250) ];

    protected static const UNASSIGNED_BOX_SIZE :Point = new Point(150, 350);
    protected static const UNASSIGNED_BOX_LOC :Point = new Point(500, 50);

    protected static const STATUS_TEXT_LOC :Point = new Point(350, 470);
    protected static const HANDICAP_BOX_LOC :Point = new Point(500, 415);
    protected static const HANDICAP_TEXT_LOC :Point = new Point(545, 420);

    protected static const GAME_START_COUNTDOWN :Number = 3;
}

}

import flash.display.Sprite;
import flash.display.Graphics;
import flash.display.Shape;
import flash.display.SimpleButton;
import flash.events.MouseEvent;
import flash.events.Event;

class HandicapCheckbox extends SimpleButton
{
    public static const STATE_CHANGED :String = "StateChanged";

    public function HandicapCheckbox ()
    {
        _checkedShape = new Shape();
        var g :Graphics = _checkedShape.graphics;
        g.lineStyle(2, 0);
        g.beginFill(0xFF0000);
        g.drawRect(0, 0, SIZE, SIZE);
        g.endFill();

        _uncheckedShape = new Shape();
        g = _uncheckedShape.graphics;
        g.lineStyle(2, 0);
        g.beginFill(0xFFFFFF);
        g.drawRect(0, 0, SIZE, SIZE);
        g.endFill();

        _checked = true;
        this.checked = false;

        this.addEventListener(MouseEvent.CLICK, handleClicked);
    }

    protected function handleClicked (...ignored) :void
    {
        this.checked = !this.checked;
    }

    public function set checked (val :Boolean) :void
    {
        if (_checked != val) {
            var theShape :Shape = (val ? _checkedShape : _uncheckedShape);
            this.upState = theShape;
            this.downState = theShape;
            this.overState = theShape;
            this.hitTestState = theShape;

            _checked = val;

            this.dispatchEvent(new Event(STATE_CHANGED));
        }
    }

    public function get checked () :Boolean
    {
        return _checked;
    }

    protected var _checked :Boolean;
    protected var _checkedShape :Shape;
    protected var _uncheckedShape :Shape;

    protected static const SIZE :int = 30;
}
