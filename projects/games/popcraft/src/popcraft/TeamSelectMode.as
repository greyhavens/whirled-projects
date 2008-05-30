package popcraft {

import com.threerings.util.ArrayUtil;
import com.whirled.contrib.simplegame.AppMode;
import com.whirled.game.ElementChangedEvent;
import com.whirled.game.PropertyChangedEvent;

import flash.display.Graphics;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;

public class TeamSelectMode extends AppMode
{
    override protected function setup () :void
    {
        var g :Graphics = this.modeSprite.graphics;
        g.beginFill(0xB7B6B4);
        g.drawRect(0, 0, Constants.SCREEN_DIMS.x, Constants.SCREEN_DIMS.y);
        g.endFill();

        this.createTeamBox(-1);
        for (var teamId :int = 0; teamId < this.numPlayers; ++teamId) {
            this.createTeamBox(teamId);
        }

        AppContext.gameCtrl.net.addEventListener(PropertyChangedEvent.PROPERTY_CHANGED, onPropChanged);
        AppContext.gameCtrl.net.addEventListener(ElementChangedEvent.ELEMENT_CHANGED, onElemChanged);

        if (this.isFirstPlayer) {
            // initialize the team selection array. nobody's on a team yet.
            AppContext.gameCtrl.net.set(PROP_TEAMS, ArrayUtil.create(this.numPlayers, -1));
        } else {
            _playerTeams = AppContext.gameCtrl.net.get(PROP_TEAMS) as Array;
            this.updateDisplay();
        }
    }

    override protected function destroy () :void
    {
        AppContext.gameCtrl.net.removeEventListener(PropertyChangedEvent.PROPERTY_CHANGED, onPropChanged);
        AppContext.gameCtrl.net.removeEventListener(ElementChangedEvent.ELEMENT_CHANGED, onElemChanged);
    }

    protected function onPropChanged (e :PropertyChangedEvent) :void
    {
        if (e.name == PROP_TEAMS) {
            _playerTeams = e.newValue as Array;
            this.updateDisplay();
        }
    }

    protected function onElemChanged (e :ElementChangedEvent) :void
    {
        if (e.name == PROP_TEAMS) {
            this.updateDisplay();
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
        if (null != _playerTeams && _playerTeams[this.localPlayerId] != teamId) {
            AppContext.gameCtrl.net.setAt(PROP_TEAMS, this.localPlayerId, teamId, true);
            this.updateDisplay();
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

    protected function get numPlayers () :int
    {
        return AppContext.gameCtrl.game.seating.getPlayerIds().length;
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

    protected var _teamsInited :Boolean;
    protected var _playerTeams :Array;
    protected var _teamTexts :Array = [];

    protected static const TEAM_BOX_SIZE :Point = new Point(175, 175);
    protected static const TEAM_BOX_LOCS :Array = [
        new Point(50, 50), new Point(275, 50), new Point(50, 275), new Point(275, 275) ];

    protected static const UNASSIGNED_BOX_SIZE :Point = new Point(150, 400);
    protected static const UNASSIGNED_BOX_LOC :Point = new Point(500, 50);

    protected static const PROP_TEAMS :String = "Teams";
}

}
