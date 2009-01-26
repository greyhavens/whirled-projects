package popcraft.lobby {

import com.threerings.flash.TextFieldUtil;
import com.threerings.util.Log;
import com.whirled.contrib.simplegame.*;
import com.whirled.contrib.simplegame.audio.AudioManager;
import com.whirled.contrib.simplegame.objects.SimpleTimer;
import com.whirled.contrib.simplegame.resource.SwfResource;
import com.whirled.game.GameContentEvent;
import com.whirled.game.NetSubControl;
import com.whirled.game.OccupantChangedEvent;
import com.whirled.net.ElementChangedEvent;
import com.whirled.net.MessageReceivedEvent;
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
import popcraft.game.*;
import popcraft.game.endless.*;
import popcraft.game.mpbattle.MultiplayerGameMode;
import popcraft.ui.UIBits;

public class MultiplayerLobbyMode extends AppMode
{
    override protected function setup () :void
    {
        super.setup();

        _bg = ClientCtx.getSwfDisplayRoot("multiplayer_lobby") as MovieClip;
        this.modeSprite.addChild(_bg);

        // create headshots
        for (var seat :int = 0; seat < ClientCtx.seatingMgr.numExpectedPlayers; ++seat) {
            _headshots.push(new PlayerHeadshot(seat));
        }

        // handle clicks on the team boxes
        if (ClientCtx.seatingMgr.numExpectedPlayers == 2) {
            createTeamBoxMouseListener(_bg, LobbyConfig.ENDLESS_TEAM_ID);
        } else {
            _endlessWarnText = UIBits.createText(
                "Team Survival is accessible in 2-player games only", 1.2, 0, 0x444444);
            _endlessWarnText.x = ENDLESS_MODE_WARN_LOC.x - (_endlessWarnText.width * 0.5);
            _endlessWarnText.y = ENDLESS_MODE_WARN_LOC.y - (_endlessWarnText.height * 0.5);
            _bg.addChild(_endlessWarnText);
        }

        for (var teamId :int = LobbyConfig.UNASSIGNED_TEAM_ID; teamId < LobbyConfig.NUM_TEAMS;
             ++teamId) {
            createTeamBoxMouseListener(_bg, teamId);
        }

        _statusText = _bg["instructions"];

        registerListener(ClientCtx.gameCtrl.net, MessageReceivedEvent.MESSAGE_RECEIVED,
            onMsgReceived);
        registerListener(ClientCtx.gameCtrl.net, PropertyChangedEvent.PROPERTY_CHANGED,
            onPropChanged);
        registerListener(ClientCtx.gameCtrl.net, ElementChangedEvent.ELEMENT_CHANGED,
            onElemChanged);
        registerListener(ClientCtx.gameCtrl.game, OccupantChangedEvent.OCCUPANT_LEFT,
            onOccupantLeft);

        if (ClientCtx.lobbyConfig.inited) {
            initLocalPlayerData();
        }

        _handicapCheckbox = _bg["handicap"];
        registerListener(_handicapCheckbox, MouseEvent.CLICK, onHandicapBoxClicked);
        this.handicapOn = false;

        updateHandicapsDisplay();
        updateTeamsDisplay();
        updatePremiumContentDisplay();

        registerListener(ClientCtx.gameCtrl.player, GameContentEvent.PLAYER_CONTENT_ADDED,
            onPlayerPurchasedContent);

        if (ResetSavedGamesDialog.shouldShow) {
            ClientCtx.mainLoop.pushMode(new ResetSavedGamesDialog());
        }
    }

    override protected function enter () :void
    {
        super.enter();
        StageQualityManager.pushStageQuality(StageQuality.HIGH);

        if (!_playedSound) {
            ClientCtx.audio.playSoundNamed("sfx_day");
            _playedSound = true;
        }
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

            sendServerMsg(LobbyConfig.MSG_SET_PREMIUM_CONTENT, true);
        }
    }

    protected function initLocalPlayerData () :void
    {
        if (Constants.DEBUG_GIVE_MORBID_INFECTION) {
            ClientCtx.globalPlayerStats.hasMorbidInfection = true;
        }

        if (ClientCtx.globalPlayerStats.hasMorbidInfection) {
            sendServerMsg(LobbyConfig.MSG_SET_MORBID_INFECTION, true);
        }

        if (ClientCtx.isEndlessModeUnlocked) {
            sendServerMsg(LobbyConfig.MSG_SET_PREMIUM_CONTENT, true);
        }

        _initedLocalPlayerData = true;
    }

    protected function createTeamBoxMouseListener (_bg :MovieClip, teamId :int) :void
    {
        var boxName :String;
        switch (teamId) {
        case LobbyConfig.UNASSIGNED_TEAM_ID:
            boxName = UNASSIGNED_BOX_NAME;
            break;

        case LobbyConfig.ENDLESS_TEAM_ID:
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
        if (!ClientCtx.seatingMgr.allPlayersPresent) {
            ClientCtx.mainLoop.unwindToMode(new MultiplayerFailureMode());
        }

        var statusText :String = "";

        if (!ClientCtx.lobbyConfig.isEveryoneTeamed) {
            statusText = "Divide into teams!";
        } else if (!ClientCtx.lobbyConfig.teamsDividedProperly) {
            statusText = "At least two teams are required to start the game."
        } else if (!_gameStartTimer.isNull) {
            var timer :SimpleTimer = _gameStartTimer.object as SimpleTimer;
            var timeLeft :Number = Math.ceil(timer.timeLeft);
            statusText =
                (timeLeft > 0 ? "Starting in " + Math.ceil(timer.timeLeft) + "..." : "Starting...");
        }

        _statusText.text = statusText;
    }

    protected function onMsgReceived (e :MessageReceivedEvent) :void
    {
        if (e.name == LobbyConfig.MSG_START_GAME) {
            startGame();
        }
    }

    protected function onPropChanged (e :PropertyChangedEvent) :void
    {
        if (e.name == LobbyConfig.PROP_INITED && Boolean(e.newValue)) {
            if (!_initedLocalPlayerData) {
                initLocalPlayerData();
            }

            updateTeamsDisplay();
            updateHandicapsDisplay();

        } else if (e.name == LobbyConfig.PROP_GAMESTARTCOUNTDOWN) {
            var showCountdown :Boolean = e.newValue as Boolean;
            if (showCountdown) {
                _gameStartTimer = addObject(new SimpleTimer(LobbyConfig.COUNTDOWN_TIME));
            } else {
                destroyObject(_gameStartTimer);
            }
        }
    }

    protected function onElemChanged (e :ElementChangedEvent) :void
    {
        if (e.name == LobbyConfig.PROP_PLAYER_TEAMS) {
            updateTeamsDisplay();
        } else if (e.name == LobbyConfig.PROP_HANDICAPS) {
            updateHandicapsDisplay();
        } else if (e.name == LobbyConfig.PROP_HASPREMIUMCONTENT) {
            updatePremiumContentDisplay();
        }
    }

    protected function startGame () :void
    {
        if (ClientCtx.lobbyConfig.isEndlessModeSelected) {
            ClientCtx.mainLoop.pushMode(new MpEndlessLevelSelectMode());
        } else {
            ClientCtx.mainLoop.unwindToMode(new MultiplayerGameMode());
        }
    }

    protected function onOccupantLeft (...ignored) :void
    {
        updateTeamsDisplay();
    }

    protected function onHandicapBoxClicked (...ignored) :void
    {
        var playerHandicaps :Array = ClientCtx.lobbyConfig.handicaps;
        if (null != playerHandicaps) {
            this.handicapOn = !this.handicapOn;
            if (this.handicapOn != playerHandicaps[ClientCtx.seatingMgr.localPlayerSeat]) {
                sendServerMsg(LobbyConfig.MSG_SET_HANDICAP, this.handicapOn);
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
        if (!ClientCtx.lobbyConfig.inited) {
            return;
        }

        // don't allow selection of the endless team unless there are 2 players
        // and somebody has unlocked the premium content
        if (teamId == LobbyConfig.ENDLESS_TEAM_ID &&
            (ClientCtx.seatingMgr.numExpectedPlayers != 2 ||
             !ClientCtx.lobbyConfig.someoneHasPremiumContent)) {
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
        if (ClientCtx.lobbyConfig.isTeamFull(teamId)) {
            return;
        }

        var teams :Array = ClientCtx.lobbyConfig.playerTeams;
        if (null != teams && teams[ClientCtx.seatingMgr.localPlayerSeat] != teamId) {
            sendServerMsg(LobbyConfig.MSG_SET_TEAM, teamId);
            updateTeamsDisplay();
        }
    }

    protected function updateHandicapsDisplay () :void
    {
        var handicaps :Array = ClientCtx.lobbyConfig.handicaps;
        if (null != handicaps) {
            for (var playerSeat :int = 0; playerSeat < ClientCtx.seatingMgr.numExpectedPlayers; ++playerSeat) {
                var headshot :PlayerHeadshot = _headshots[playerSeat];
                headshot.handicap = handicaps[playerSeat];
            }
        }
    }

    protected function updateTeamsDisplay () :void
    {
        // "inited" will be set to true when the multiplayer configuration is valid
        if (!ClientCtx.lobbyConfig.inited || null == ClientCtx.lobbyConfig.playerTeams) {
            return;
        }

        var teams :Array = ClientCtx.lobbyConfig.playerTeams;
        var handicaps :Array = ClientCtx.lobbyConfig.handicaps;

        for (var teamId :int = LobbyConfig.ENDLESS_TEAM_ID; teamId < LobbyConfig.NUM_TEAMS; ++teamId) {
            var boxLoc :Point;
            switch (teamId) {
            case LobbyConfig.UNASSIGNED_TEAM_ID:
                boxLoc = UNASSIGNED_BOX_LOC;
                break;

            case LobbyConfig.ENDLESS_TEAM_ID:
                boxLoc = ENDLESS_BOX_LOC;
                break;

            default:
                boxLoc = TEAM_BOX_LOCS[teamId];
                break;
            }

            var xLoc :Number = boxLoc.x + INITIAL_HEADSHOT_OFFSET.x;
            var yLoc :Number = boxLoc.y + INITIAL_HEADSHOT_OFFSET.y;

            for (var playerSeat :int = 0; playerSeat < ClientCtx.seatingMgr.numExpectedPlayers; ++playerSeat) {
                if (teams[playerSeat] == teamId) {
                    var headshot :PlayerHeadshot = _headshots[playerSeat];
                    headshot.x = xLoc;
                    headshot.y = yLoc;

                    if (null == headshot.parent) {
                        this.modeSprite.addChild(headshot);
                    }

                    if (teamId == LobbyConfig.ENDLESS_TEAM_ID) {
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
            (ClientCtx.isEndlessModeUnlocked ||
             ClientCtx.lobbyConfig.someoneHasPremiumContent);

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
                    ClientCtx.showGameShop();
                });
            _showingPremiumContent = false;
        }
    }

    protected function sendServerMsg (name :String, val :Object = null) :void
    {
        ClientCtx.gameCtrl.net.sendMessage(name, val, NetSubControl.TO_SERVER_AGENT);
    }

    protected var _bg :MovieClip;
    protected var _headshots :Array = [];
    protected var _statusText :TextField;
    protected var _handicapCheckbox :MovieClip;
    protected var _handicapOn :Boolean;
    protected var _initedLocalPlayerData :Boolean;
    protected var _gameStartTimer :SimObjectRef = SimObjectRef.Null();
    protected var _showingPremiumContent :Boolean;
    protected var _endlessWarnText :TextField;
    protected var _playedSound :Boolean;

    protected static var log :Log = Log.getLog(MultiplayerLobbyMode);

    protected static const TEAM_BOX_LOCS :Array = [
        new Point(236, 113),
        new Point(466, 113),
        new Point(236, 249),
        new Point(466, 249)
    ];

    protected static const UNASSIGNED_BOX_LOC :Point = new Point(26, 113);
    protected static const ENDLESS_BOX_LOC :Point = new Point(240, 431);

    protected static const ENDLESS_MODE_WARN_LOC :Point = new Point(455, 454);

    protected static const TEAM_BOX_NAMES :Array = [ "red_box", "blue_box", "green_box", "yellow_box" ];
    protected static const UNASSIGNED_BOX_NAME :String = "unassigned_box";
    protected static const ENDLESS_BOX_NAME :String = "survival_box";

    protected static const INITIAL_HEADSHOT_OFFSET :Point = new Point(2, 2);
    protected static const HEADSHOT_OFFSET :Number = 40;

    protected static const STATUS_TEXT_LOC :Point = new Point(350, 470);
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
        var headshot :DisplayObject = ClientCtx.seatingMgr.getPlayerHeadshot(playerSeat);
        headshot.scaleX = 1;
        headshot.scaleY = 1;
        var scale :Number = Math.max(HEADSHOT_SIZE.x / headshot.width,
                                     HEADSHOT_SIZE.y / headshot.height);
        headshot.scaleX = scale;
        headshot.scaleY = scale;
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
        var tfName :TextField = UIBits.createText(ClientCtx.seatingMgr.getPlayerName(playerSeat), 1.2);
        TextFieldUtil.setMaximumTextWidth(tfName, NAME_MAX_WIDTH);
        tfName.x = NAME_OFFSET;
        tfName.y = (HEADSHOT_SIZE.y - tfName.height) * 0.5;
        addChild(tfName);

        _handicapObj = ClientCtx.instantiateMovieClip("multiplayer_lobby", "handicapped");
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
    protected static const NAME_OFFSET :Number = HEADSHOT_SIZE.x + 2;
    protected static const NAME_MAX_WIDTH :Number = 140;
}
