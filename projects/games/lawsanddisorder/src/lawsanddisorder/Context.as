package lawsanddisorder {

import com.whirled.game.GameControl;

import lawsanddisorder.component.*;

/**
 * Contains references to the various bits used in the game.
 */
public class Context
{
    public function Context (control :GameControl)
    {
        this.control = control;
        gatherConfig();
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
        control.net.sendMessage(type, value);
    }
    
    /**
     * Gather number and level of AI players from game instance parameters
     */
    protected function gatherConfig () :void
    {
        var config :Object = control.game.getConfig();
        
        // how many ais will be added to a maximum of 6 total players
        var numHumanPlayers :int = control.game.seating.getPlayerIds().length;
        var maxAIPlayers :int = 6 - numHumanPlayers;
        var aiCountString :String = config["AI Players"];
        var numAIPlayers :int = 0;
        switch (aiCountString) {
            case "none":
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
                numAIPlayers = Math.min(maxAIPlayers, 6);
                break;
            default:
                error("unknown value for 'AI Players': " + aiCountString);
                numAIPlayers = Math.min(maxAIPlayers, 6);
                break;
        }
        numPlayers = numHumanPlayers + numAIPlayers;
        
        // multiplier for random ai behavior from 0 (smartest) to 100 (dumbest)
        var aiLevelString :String = config["AI Level"];
        switch (aiLevelString) {
            case "S-M-R-T":
                aiDumbnessFactor = 0;
                break;
            case "dumber":
                aiDumbnessFactor = 50;
                break;
            case "dumbest":
                aiDumbnessFactor = 100;
                break;
            default:
                error("unknown value for 'AI Level': " + aiLevelString);
                aiDumbnessFactor = 0;
                break;
        }
        
        // delay between actions on an ai's turn (1 - 6 seconds)
        var aiSpeedString :String = config["AI Speed"];
        switch (aiSpeedString) {
            case "slow":
                aiDelaySeconds = 8;
                break;
            case "normal":
                aiDelaySeconds = 5;
                break;
            case "lightspeed":
                aiDelaySeconds = 1;
                break;
            default:
                error("unknown value for 'AI Speed': " + aiSpeedString);
                aiDelaySeconds = 1;
                break;
        }
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
    
    /** config - The number of players in the game, human + ai, from 2 to 6 */
    public var numPlayers :int;
    
    /** config - Multiplier for random ai behavior from 0 (smartest) to 100 (dumbest) */
    public var aiDumbnessFactor :int;
    
    /** config - How many seconds to wait between each ai action on their turn */
    public var aiDelaySeconds :int;
}
}