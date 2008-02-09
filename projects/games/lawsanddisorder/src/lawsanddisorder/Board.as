package lawsanddisorder {

import flash.display.Sprite;
import flash.display.Bitmap;
import lawsanddisorder.component.*;
import com.threerings.ezgame.EZGameControl;
import com.threerings.util.HashMap;
import com.threerings.ezgame.StateChangedEvent;

/**
 * Layout of the game board.  Components such as Player can be publicly accessed through here.
 */
public class Board extends Sprite
{
    /**
     * Constructor
     */
    public function Board (ctx :Context)
    {
        _ctx = ctx;
        _ctx.control.game.addEventListener(StateChangedEvent.TURN_CHANGED, turnChanged);
    }

    /**
     * Create the board components and initialize them 
     */
    public function init () :void
    {
        // display background
        initDisplay();
        
        turnIndicator = new TurnIndicator(_ctx);
        turnIndicator.x = 20;
        turnIndicator.y = 210;
        addChild(turnIndicator);
        
        deck = new Deck(_ctx);
        deck.x = 20;
        deck.y = 300;
        addChild(deck);
        
        newLaw = new NewLaw(_ctx);
        newLaw.x = 160;
        newLaw.y = 290;
        addChild(newLaw);
        
        laws = new Laws(_ctx);
        laws.x = 160;
        laws.y = 30;
        addChild(laws);
                
        opponents = new Opponents(_ctx);
        
        // create the players
        // lists player ids and names by seating position
        var playerIds :Array = _ctx.control.game.seating.getPlayerIds();
        var playerNames :Array = _ctx.control.game.seating.getPlayerNames();
        for (var i :int = 0; i < playerIds.length; i++) {
            var player :Player;
            if (_ctx.control.game.seating.getMyPosition() == i) {
                player = new Player(_ctx, i, playerIds[i], playerNames[i]);
                player.x = 0;
                player.y = 0;
                addChild(player);
                this.player = player;
            }
            else {
                player = new Opponent(_ctx, i, playerIds[i], playerNames[i]);
                opponents.addOpponent(Opponent(player));
            }
            playerObjects[i] = player;
        }
        
        // add opponents as child after player so they'll be displayed over top
        opponents.x = 560;
        opponents.y = 20;
        addChild(opponents);
        
        // notices display above everything else
        notices = new Notices(_ctx);
        notices.x = 0;
        notices.y = 380;
        addChild(notices);
    }
    
    /**
     * Setup is only performed by the player who is in control at the start of the game.
     * Called by the controller player; add cards to deck, deal hands, assign jobs to players.
     */
    public function setup () :void
    {
    	deck.setup();
    	// setup the player hands and jobs
        for (var i :int = 0; i < playerObjects.length; i++) {
            var player :Player = playerObjects[i];
            player.setup();
        }
    }
    
    /**
     * Initialize the table; draw the background
     */
    protected function initDisplay () :void
    {
    	// TODO increases compile/launch time - reinstate later
    	//var background :Bitmap = new BOARD_BACKGROUND();
    	//addChild(background);
		
        // fill the background color
        graphics.clear();
        graphics.beginFill(0x77FF77);
        graphics.drawRect(0, 0, 700, 500);
        graphics.endFill();
        
        // add a box for laws area
        graphics.lineStyle(2, 0x4499EE);
        graphics.drawRect(150, 10, 400, 380);
    }
    
    /**
     * Return the player with the given id.
     */
    public function getPlayer (playerId :int) :Player
    {
    	if (playerId < 0 || playerId > playerObjects.length) {
    		_ctx.log("WTF playerId is " + playerId + " in getPlayer");
    		return null;
    	}
        return playerObjects[playerId];
    }
    
    /**
     * Remove a card from the board layer
     */
    public function removeCard (card :Card) :void
    {
        if (contains(card)) {
            try {
                removeChild(card);
            }
            catch (error :ArgumentError) {
                return;
            }
        }
    }
    
    /**
     * Return the player whose turn it is.
     * TODO could be more efficient?  Listen for turn changed event?  Does turn changed event 
     *      include turnholder id?  Should be here?  Should player array be moved?
     */
    public function getTurnHolder () :Player
    {
    	// getTurnHolder returns a serverId, not their seating position
    	var serverId :int = _ctx.control.game.getTurnHolderId();
    	for (var i :int = 0; i < playerObjects.length; i++) {
    		var player :Player = playerObjects[i];
    		if (player.serverId == serverId) {
    			return player;
    		}
    	}
    	return null;
    }
    
    /**
     * Return the array of players in order of seating.     */
    public function get players () :Array {
    	return playerObjects;
    }
    
    /**
     * The turn just changed.  Indicate if it is the player's turn
     */
    protected function turnChanged (event :StateChangedEvent) :void
    {
        var turnHolder :Player = _ctx.board.getTurnHolder();
        if (turnHolder == player) {
            graphics.lineStyle(5, 0xFFFF00);
        }
        else {
            graphics.lineStyle(5, 0x77FF77);
        }
        graphics.drawRect(2, 2, 695, 495);
    }
    
    /** Game context */
    protected var _ctx :Context;
    
    /** TODO make components readonly using getters */
    
    /** Displays in-game messages to the player */
    public var notices :Notices;
    
    /** Display of turn and end turn button */
    public var turnIndicator :TurnIndicator;
    
    /** Deck of cards */
    public var deck :Deck;
    
    /** Play area for creating a new law */
    public var newLaw :NewLaw;
    
    /** List of finished laws */
    public var laws :Laws;
    
    /** All the other players */
    public var opponents :Opponents;
    
    /** Current player */
    public var player :Player;
    
    /** All player objects in the game, indexed by id */
    protected var playerObjects :Array = new Array();
    
    ///** Background image for the game board */
    //[Embed(source="../../rsrc/images/board.png")]
    //protected var BOARD_BACKGROUND :Class;
}
}