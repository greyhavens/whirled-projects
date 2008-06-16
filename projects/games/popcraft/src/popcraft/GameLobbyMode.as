package popcraft {

import com.threerings.util.ArrayUtil;
import com.whirled.contrib.simplegame.*;
import com.whirled.contrib.simplegame.objects.SimpleTimer;
import com.whirled.game.ElementChangedEvent;
import com.whirled.game.PropertyChangedEvent;

import flash.display.Graphics;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;

public class GameLobbyMode extends AppMode
{
    override protected function setup () :void
    {
        var g :Graphics = this.modeSprite.graphics;
        g.beginFill(0xB7B6B4);
        g.drawRect(0, 0, Constants.SCREEN_DIMS.x, Constants.SCREEN_DIMS.y);
        g.endFill();

        this.createTeamBox(-1);
        for (var teamId :int = 0; teamId < this.maxTeams; ++teamId) {
            this.createTeamBox(teamId);
        }

        _statusText = new TextField();
        _statusText.selectable = false;
        _statusText.scaleX = 2;
        _statusText.scaleY = 2;
        _statusText.autoSize = TextFieldAutoSize.LEFT;
        _statusText.x = STATUS_TEXT_LOC.x;
        _statusText.y = STATUS_TEXT_LOC.y;

        this.modeSprite.addChild(_statusText);

        AppContext.gameCtrl.net.addEventListener(PropertyChangedEvent.PROPERTY_CHANGED, onPropChanged);
        AppContext.gameCtrl.net.addEventListener(ElementChangedEvent.ELEMENT_CHANGED, onElemChanged);

        if (this.isFirstPlayer) {
            // initialize the team selection array. nobody's on a team yet.
            MultiplayerConfig.teams = ArrayUtil.create(MultiplayerConfig.numPlayers, -1);
            MultiplayerConfig.handicaps = ArrayUtil.create(MultiplayerConfig.numPlayers, 1);
        } else {
            _playerTeams = MultiplayerConfig.teams;
            this.updateDisplay();
        }
    }

    override protected function destroy () :void
    {
        AppContext.gameCtrl.net.removeEventListener(PropertyChangedEvent.PROPERTY_CHANGED, onPropChanged);
        AppContext.gameCtrl.net.removeEventListener(ElementChangedEvent.ELEMENT_CHANGED, onElemChanged);
    }

    override public function update (dt :Number) :void
    {
        super.update(dt);

        var statusText :String = "";

        if (!this.allPlayersDecided) {
            statusText = "Divide into teams!";
        } else if (!this.teamsDividedProperly) {
            statusText = "Two teams are required to start the game."
        } else if (!_gameStartTimer.isNull) {
            var timer :SimpleTimer = _gameStartTimer.object as SimpleTimer;
            statusText = "Starting in " + Math.ceil(timer.timeLeft) + "...";
        }

        _statusText.text = statusText;
        _statusText.x = (_statusText.parent.width * 0.5) - (_statusText.width * 0.5);
    }

    protected function onPropChanged (e :PropertyChangedEvent) :void
    {
        if (e.name == MultiplayerConfig.PROP_TEAMS) {
            _playerTeams = e.newValue as Array;
            this.updateDisplay();
        }
    }

    protected function onElemChanged (e :ElementChangedEvent) :void
    {
        if (e.name == MultiplayerConfig.PROP_TEAMS) {
            this.updateDisplay();
            this.stopOrResetTimer();
        }
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

    protected function teamSelected (teamId :int) :void
    {
        // don't allow team selection changes with < 2 seconds on the timer
        if (!_gameStartTimer.isNull) {
            var timer :SimpleTimer = _gameStartTimer.object as SimpleTimer;
            if (timer.timeLeft < 2) {
                return;
            }
        }

        if (null != _playerTeams && _playerTeams[this.localPlayerId] != teamId) {
            MultiplayerConfig.setPlayerTeam(this.localPlayerId, teamId);
            this.updateDisplay();

            this.stopOrResetTimer();
        }
    }

    protected function updateDisplay () :void
    {
        for (var teamId :int = -1; teamId < this.numPlayers; ++teamId) {
            var text :String = "";

            if (null != _playerTeams) {
                for (var playerId :int = 0; playerId < this.numPlayers; ++playerId) {
                    if (_playerTeams[playerId] == teamId) {
                        text += this.getPlayerName(playerId) + "\n";
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
        MainLoop.instance.changeMode(new GameMode());
    }

    protected function get numPlayers () :int
    {
        return AppContext.gameCtrl.game.seating.getPlayerIds().length;
    }

    protected function get maxTeams () :int
    {
        return this.numPlayers;
    }

    protected function getPlayerName (id :int) :String
    {
        return AppContext.gameCtrl.game.seating.getPlayerNames()[id];
    }

    protected function get localPlayerId () :int
    {
        return AppContext.gameCtrl.game.seating.getMyPosition();
    }

    protected function get isFirstPlayer () :Boolean
    {
        return this.localPlayerId == 0;
    }

    protected function get allPlayersDecided () :Boolean
    {
        if (null == _playerTeams) {
            return false;
        }

        for each (var teamId :int in _playerTeams) {
            if (teamId < 0) {
                return false;
            }
        }

        return true;
    }

    protected function get teamsDividedProperly () :Boolean
    {
        if (null == _playerTeams) {
            return false;
        }

        // how large is each team?
        var teamSizes :Array = ArrayUtil.create(this.maxTeams, 0);
        for each (var teamId :int in _playerTeams) {
            if (teamId >= 0) {
                teamSizes[teamId] += 1;
            }
        }

        // does one team have all the players?
        for each (var teamSize :int in teamSizes) {
            if (teamSize == this.numPlayers) {
                return false;
            }
        }

        return true;
    }

    protected function get canStartCountdown () :Boolean
    {
        return this.allPlayersDecided && this.teamsDividedProperly;
    }

    protected var _playerTeams :Array;
    protected var _teamTexts :Array = [];
    protected var _statusText :TextField;
    protected var _gameStartTimer :SimObjectRef = new SimObjectRef();

    protected static const TEAM_BOX_SIZE :Point = new Point(175, 150);
    protected static const TEAM_BOX_LOCS :Array = [
        new Point(50, 50), new Point(275, 50), new Point(50, 250), new Point(275, 250) ];

    protected static const UNASSIGNED_BOX_SIZE :Point = new Point(150, 350);
    protected static const UNASSIGNED_BOX_LOC :Point = new Point(500, 50);

    protected static const STATUS_TEXT_LOC :Point = new Point(350, 450);

    protected static const GAME_START_COUNTDOWN :Number = 5;
}

}
