package lawsanddisorder.component {

import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;

import lawsanddisorder.*;

/**
 * Contains display and logic for game players including all opponents
 */
public class Players extends Component
{
    /**
     * Constructor.  Create players
     */
    public function Players (ctx :Context)
    {
        super(ctx);
        
        // lists player ids and names by seating position
        var playerServerIds :Array = _ctx.control.game.seating.getPlayerIds();
        var playerNames :Array = _ctx.control.game.seating.getPlayerNames();
        numHumanPlayers = playerServerIds.length;
        playerObjects = new Array(_ctx.numPlayers);
        
        // get the player's position; -1 means the player is a watcher
        var myPosition :int = _ctx.control.game.seating.getMyPosition();
        var isWatcher :Boolean;
        if (myPosition == -1) {
            isWatcher = true;
        }

        // for testing, pretend as a watcher
        /* numHumanPlayers = playerServerIds.length - 1;
        playerServerIds.length = numHumanPlayers;
        playerNames.length = numHumanPlayers;
        if (myPosition == numHumanPlayers) {
            isWatcher = true;
            myPosition = -1;
        } */

        // watchers don't get a job, hand, etc.
        if (isWatcher) {
            player = new Player(_ctx, -1, -1, "watcher");
        }
        else {
            player = new Player(_ctx, myPosition, playerServerIds[myPosition], playerNames[myPosition]);
            playerObjects[myPosition] = player;
        }
        addChild(player);

        opponents = new Opponents(_ctx);

        // players create the opponents in order, starting with the opponent whose turn is next
        var playerId :int = myPosition + 1;
        while (playerId < numHumanPlayers) {
            var nextOpponent :Opponent = new Opponent(
                _ctx, playerId, playerServerIds[playerId], playerNames[playerId]);
            opponents.addOpponent(nextOpponent);
            playerObjects[playerId] = nextOpponent;
            playerId++;
        }
        
        // add ai players after last human player to fill the seats up to NUM_PLAYERS
        while (playerId < _ctx.numPlayers) {
            var aiPlayer :AIPlayer = new AIPlayer(_ctx, playerId);
            opponents.addOpponent(aiPlayer);
            playerObjects[playerId] = aiPlayer;
            playerId++;
        }
        
        // finish by adding human players who came before this player
        playerId = 0;
        while (playerId < myPosition) {
            var prevOpponent :Opponent = new Opponent(
                _ctx, playerId, playerServerIds[playerId], playerNames[playerId]);
            opponents.addOpponent(prevOpponent);
            playerObjects[playerId] = prevOpponent;
            playerId++;
        }

        // add opponents as child after player so they'll be displayed over top
        opponents.x = 590;
        opponents.y = 10;
        addChild(opponents);
    }
    
    /**
     * Setup is only performed by the player who is in control at the start of the game.
     * Called by the controller player; add cards to deck, deal hands, assign jobs to players.
     */
    public function setup () :void
    {
        // setup the player hands and jobs
        for (var i :int = 0; i < playerObjects.length; i++) {
            var player :Player = playerObjects[i];
            player.setup();
        }
    }

    /**
     * For watchers who join partway through the game, fetch the existing board data
     */
    public function refreshData () :void
    {
        for each (var player :Player in playerObjects) {
            player.refreshData();
        }
    }

    /**
     * Return the player with the given id.
     */
    public function getPlayer (playerId :int) :Player
    {
        if (playerId < 0 || playerId > playerObjects.length) {
            _ctx.error("playerId is " + playerId + " in getPlayer");
            return null;
        }
        return playerObjects[playerId];
    }
    
    /**
     * Called as soon as turn starts before the TURN_STARTED message goes out.
     */
    public function advanceTurnHolder () :void
    {
        if (turnHolder != null) {
            turnHolder = nextPlayer;
        } else {
            turnHolder = playerObjects[0];
        }
    }

    /**
     * Return true if it is this player's turn
     */
    public function isMyTurn () :Boolean
    {
        if (player != null && turnHolder == player) {
            return true;
        } else {
            return false;
        }
    }
    
    /**
     * Return the player whose turn it is next, including AI players
     */
    protected function get nextPlayer () :Player
    {
        if (playerObjects == null) {
            _ctx.error("playerOjbects null in Players.nextPlayer");
            return null;
        }
        if (turnHolder == null) {
            _ctx.error("turnHolder null in Players.nextPlayer");
            advanceTurnHolder();
        }
        return playerObjects[((turnHolder.id+1) % playerObjects.length)];
    }

    /**
     * Called when a player leaves the game.  Replace them with an ai player controlled by the
     * controller player.
     */
    public function playerLeft (playerServerId :int) :void
    {
        // if controller instance was controlling an ai player, halt that player's turn
        if (player.isController && turnHolder as AIPlayer) {
            AIPlayer(turnHolder).canPlay = false;
        }
        
        // every instance halts all actions on all players
        _ctx.state.cancelMode();
        _ctx.board.laws.cancelTriggering();
        
        // every instance finds the opponent who left and determines the new controller player
        var opponentWhoLeft :Opponent;
        for each (var somePlayer :Player in playerObjects) {
            if (somePlayer.serverId == playerServerId) {
                opponentWhoLeft = somePlayer as Opponent;
            } else if (_ctx.control.game.getControllerId() == somePlayer.serverId) {
                somePlayer.isController = true;
            }
        }
        if (opponentWhoLeft == null) {
            _ctx.error("Could not find player who left.");
            _ctx.sendMessage(EventHandler.TURN_CHANGED);
            return;
        }
        
        // every instance replaces opponent who left with an ai
        var aiPlayer :AIPlayer = new AIPlayer(_ctx, opponentWhoLeft.id, opponentWhoLeft);
        _ctx.notice("Replacing " + opponentWhoLeft + " with an AI Player: " + aiPlayer);
        opponents.replaceOpponent(opponentWhoLeft, aiPlayer);
        playerObjects[opponentWhoLeft.id] = aiPlayer;

        // controller instance moves the game to the next turn
        if (player.isController && (
            turnHolder == null || turnHolder == opponentWhoLeft || turnHolder as AIPlayer)) {
            _ctx.broadcast("Moving on to next player's turn.");
            _ctx.sendMessage(EventHandler.TURN_CHANGED);
        }

        // unload the opponent object
        opponentWhoLeft.unload();
    }

    /** All player objects in the game, indexed by id, including ais and humans */
    public var playerObjects :Array;

    /** All the other players (ai or human) who are not our player */
    public var opponents :Opponents;

    /** Our player */
    public var player :Player;
    
    /** The player (including AIs) whose turn it is now */
    public var turnHolder :Player;
    
    /** How many of the players are human? 1-6 */
    public var numHumanPlayers :int;
}
}