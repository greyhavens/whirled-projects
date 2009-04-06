package lawsanddisorder {

import com.whirled.game.GameControl;

import lawsanddisorder.component.*;

/**
 * Contains references to the various bits used in the game.
 */
public class Context
{
	/** AI Intelligence multipliers */
    public static const LEVEL_DUMB :int = 0;
    public static const LEVEL_DUMBER :int = 50;
    public static const LEVEL_DUMBEST :int = 100;
    public static const LEVEL_DUMB_STRING :String = "dumb";
    public static const LEVEL_DUMBER_STRING :String = "dumber";
    public static const LEVEL_DUMBEST_STRING :String = "dumbest";
    
    /** AI Speed delays */
    public static const SPEED_SLOW :int = 7;
    public static const SPEED_NORMAL :int = 4;
    public static const SPEED_LIGHTSPEED :int = 1;
    public static const SPEED_SLOW_STRING :String = "slow";
    public static const SPEED_NORMAL_STRING :String = "normal";
    public static const SPEED_LIGHTSPEED_STRING :String = "lightspeed";
    
    public static const SOUND_ALL_STRING :String = "all";
    public static const SOUND_SFX_STRING :String = "sfx";
    public static const SOUND_NONE_STRING :String = "none";
    
    /** Should sounds be played? */
    public static function get sfxEnabled () :Boolean {
        return _sfxEnabled;
    }
    
    /** Should music be played? */
    public static function get musicEnabled () :Boolean {
        return _musicEnabled;
    }
    
    public function Context (control :GameControl)
    {
        this.control = control;
    }

    /**
     * Convienience pointer to board.players.player
     */
    public function get player () :Player
    {
        return board.players.player;
    }

    /**
     * Log this debugging message
     */
    public function log (message :String) :void
    {
        if (!control.isConnected()) {
            return;
        }
        
        control.local.feedback(message + "\n");
    }

    /**
     * Log this debugging message
     */
    public function error (message :String) :void
    {
        log("ERROR: " + message);
    }

    /**
     * Display an in-game notice message to the player
     */
    public function notice (notice :String, alsoLog :Boolean = true) :void
    {
        if (board != null) {
            board.notices.addNotice(notice, alsoLog);
        }
    }

    /**
     * Display an in-game notice message to all players or to one specific player
     */
    public function broadcast (message :String, player :Player = null, 
        displayInNotice :Boolean = false) :void
    {
        if (!control.isConnected()) {
            return;
        }
        
        var messageName :String = Notices.BROADCAST;
        if (displayInNotice) {
            messageName = Notices.BROADCAST_NOTICE;
        }
        if (player != null) {
           control.net.sendMessage(messageName, message, player.serverId);
        }
        else {
            control.net.sendMessage(messageName, message);
        }
    }

    /**
     * Display an in-game notice message to all other players
     * TODO watchers don't see this message
     */
    public function broadcastOthers (message :String, notPlayer :Player = null, 
        displayInNotice :Boolean = false) :void
    {
        if (!control.isConnected()) {
            return;
        }
        
        if (notPlayer == null) {
            notPlayer = player;
        }
        var messageName :String = Notices.BROADCAST;
        if (displayInNotice) {
            messageName = Notices.BROADCAST_NOTICE;
        }
        for each (var otherPlayer :Player in board.players.playerObjects) {
            if (otherPlayer != notPlayer && !(otherPlayer as AIPlayer)) {
                control.net.sendMessage(messageName, message, otherPlayer.serverId);
            }
        }
    }

    /**
     * Wrapper for sending messages through the WhirledGameControl
     */
    public function sendMessage (type :String, value :* = "") :void
    {
        if (!control.isConnected()) {
            return;
        }
        
        control.net.sendMessage(type, value);
    }
    
    /**
     * Gather number and level of AI players from game instance parameters
     */
    public function gatherConfig () :void
    {
        var config :Object = control.game.getConfig();
        
        // how many ais will be added to a maximum of 6 total players
        var aiCountString :String = config["AI Players"];
        var numHumanPlayers :int = control.game.seating.getPlayerIds().length;
        var maxAIPlayers :int = 6 - numHumanPlayers;
        var aiLevelString :String = config["AI Level"];
        var aiSpeedString :String = config["AI Speed"];
        
        // in single player games, try fetching config overrides from cookies
        if (numHumanPlayers == 1) {
            var cookieString :String;
            cookieString = CookieHandler.cookie.get(CookieHandler.DEFAULT_NUM_AI);
            if (cookieString != null && cookieString != "") {
                aiCountString = cookieString;
            }
            
            cookieString = CookieHandler.cookie.get(CookieHandler.DEFAULT_AI_LEVEL);
            if (cookieString != null && cookieString != "") {
                aiLevelString = cookieString;
            }
            
            cookieString = CookieHandler.cookie.get(CookieHandler.DEFAULT_AI_SPEED);
            if (cookieString != null && cookieString != "") {
                aiSpeedString = cookieString
            }
        }
        
        // set configuration of number, level and speed of ai players - store in cookies.
        setNumAIPlayers(aiCountString, numHumanPlayers, maxAIPlayers);
        setAiLevel(aiLevelString);
        setAiSpeed(aiSpeedString);
        
        // get sound settings from cookie
        var soundString :String = CookieHandler.cookie.get(CookieHandler.DEFAULT_SOUND);
        if (soundString != null && soundString != "") {
            Context.setSoundConfig(soundString);
        }
    }
    
    /**
     * how many ais will be added to a maximum of 6 total players
     * @param numHumanPlayers If 1, there must be at least one ai player (default = 1)
     * @param maxAIPlayers Six minus the number of players in the game (default = 5)
     */
    public function setNumAIPlayers (aiCountString :String, numHumanPlayers :int = 1, 
        maxAIPlayers :int = 5) :void
    {
        var numAIPlayers :int = 0;
        switch (aiCountString) {
            case "none":
                aiCountString = "0";
                // do not break, this is the same as 0
            case "0":
                if (numHumanPlayers == 1) {
                    log("Adding one AI Player - there must be at least two players.");
                	numAIPlayers = 1;
                } else {
                    numAIPlayers = 0;
                }
                break;
            case "1":
                numAIPlayers = Math.min(maxAIPlayers, 1);
                break;
            case "2":
                numAIPlayers = Math.min(maxAIPlayers, 2);
                break;
            case "3":
                numAIPlayers = Math.min(maxAIPlayers, 3);
                break;
            case "4":
                numAIPlayers = Math.min(maxAIPlayers, 4);
                break;
            case "fill to 6 seats":
                aiCountString = "5";
                // do not break, this is the same as 5
            case "5":
                numAIPlayers = Math.min(maxAIPlayers, 6);
                break;
            default:
                error("unknown value for 'AI Players': " + aiCountString);
                aiCountString = "2";
                numAIPlayers = Math.min(maxAIPlayers, 6);
                break;
        }
        
        this.numAIPlayers = numAIPlayers;
        this.numPlayers = numHumanPlayers + numAIPlayers;
        CookieHandler.cookie.set(CookieHandler.DEFAULT_NUM_AI, String(numAIPlayers));
    }
    
    /**
     * multiplier for random ai behavior from 0 (smartest) to 100 (dumbest)
     */
    public function setAiLevel (aiLevelString :String) :void
    {
        switch (aiLevelString) {
            case "S-M-R-T":
                aiLevelString = Context.LEVEL_DUMB_STRING;
                // do not break, SMRT is same as DUMB
            case Context.LEVEL_DUMB_STRING:
                aiDumbnessFactor = LEVEL_DUMB;
                break;
            case Context.LEVEL_DUMBER_STRING:
                aiDumbnessFactor = LEVEL_DUMBER;
                break;
            case Context.LEVEL_DUMBEST_STRING:
                aiDumbnessFactor = LEVEL_DUMBEST;
                break;
            default:
                error("unknown value for 'AI Level': " + aiLevelString);
                aiLevelString = Context.LEVEL_DUMB_STRING;
                aiDumbnessFactor = LEVEL_DUMBEST;
                break;
        }
        
        CookieHandler.cookie.set(CookieHandler.DEFAULT_AI_LEVEL, aiLevelString);
    }
    
    /**
     * delay between actions on an ai's turn (1 - 6 seconds)
     */
    public function setAiSpeed (aiSpeedString :String) :void
    {
        switch (aiSpeedString) {
            case Context.SPEED_SLOW_STRING:
                aiDelaySeconds = SPEED_SLOW;
                break;
            case Context.SPEED_NORMAL_STRING:
                aiDelaySeconds = SPEED_NORMAL;
                break;
            case Context.SPEED_LIGHTSPEED_STRING:
                aiDelaySeconds = SPEED_LIGHTSPEED;
                break;
            default:
                error("unknown value for 'AI Speed': " + aiSpeedString);
                aiSpeedString = Context.SPEED_LIGHTSPEED_STRING;
                aiDelaySeconds = SPEED_SLOW;
                break;
        }
        CookieHandler.cookie.set(CookieHandler.DEFAULT_AI_SPEED, aiSpeedString);
    }
    
    /**
     * Set whether music and/or sound effects should be played during the game. 
     */
    public static function setSoundConfig (soundName :String) :void 
    {
        switch (soundName) {
            case Context.SOUND_ALL_STRING:
                _sfxEnabled = true;
                _musicEnabled = true;
                break;
            case Context.SOUND_SFX_STRING:
                _sfxEnabled = true;
                _musicEnabled = false;
                break;
            case Context.SOUND_NONE_STRING:
                _sfxEnabled = false;
                _musicEnabled = false;
                break;
            default:
                soundName = Context.SOUND_ALL_STRING;
                _sfxEnabled = true;
                _musicEnabled = true;
                break;
        }
        
        if (!musicEnabled) {
            Content.stopMusic();
        } else {
            Content.playMusic(Content.THEME_MUSIC);
        }
        CookieHandler.cookie.set(CookieHandler.DEFAULT_SOUND, soundName);
    }
    
    /** Connection to the game server */
    public var control :GameControl;

    /** Controls the user interface and player actions */
    public var state :State;

    /** Contains game components such as players, deck, laws */
    public var board :Board;

    /** Wraps incoming data and message events from the server */
    public var eventHandler :EventHandler;

    /** Awards Whirled trophies - spoken to only through messages */
    public var trophyHandler :TrophyHandler;

    /** Has the game started */
    public var gameStarted :Boolean = false;
    
    /** config - The number of AI players in the game */
    public var numAIPlayers :int;
    
    /** config - The number of players in the game, human + ai, from 2 to 6 */
    public var numPlayers :int;
    
    /** config - Multiplier for random ai behavior from 0 (smartest) to 100 (dumbest) */
    public var aiDumbnessFactor :int;
    
    /** config - How many seconds to wait between each ai action on their turn */
    public var aiDelaySeconds :int;
    
    /** Should sounds be played? */
    protected static var _sfxEnabled :Boolean = true;
    
    /** Should music be played? */
    protected static var _musicEnabled :Boolean = true;
}
}