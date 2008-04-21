package lawsanddisorder {

import flash.display.Sprite;
import flash.display.MovieClip;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.text.TextField;

import com.whirled.game.GameControl;
import com.whirled.game.CoinsAwardedEvent;
import com.whirled.game.MessageReceivedEvent;
import com.whirled.game.PropertyChangedEvent;
import com.whirled.game.StateChangedEvent;
import com.whirled.game.OccupantChangedEvent;

import lawsanddisorder.component.*

/**
 * Handles game setup / game start / game end logic.
 *
 * TODO gameplay:
 * 1-2-3 step process?  change positions, use power, create law, done
 * ai to play against & allow 1 player games?
 * include a purple card when massaging starting hands?
 * don't use "monies"?
 * 
 * TODO interface:
 * add highlighting and cursors to doctor's ability
 * make splash screen a 3 screen click through
 * animate opponent we are waiting for
 * display important notices (eg pick a card) onscreen
 * animations when drawing cards, stealing cards, playing law, gain/lose/give monies
 * card mouseover tooltips, esp job powers?
 * display job power in use power button
 * connect use power button to job
 * highlight your job's name in laws
 * better explanation of each ability (in help?  tooltips?  with pictures?)
 * highlighting cues or better ui for doctor's ability
 * displaying notices directly related to you in the game itself
 * opponent list should start with the opponent whose turn comes after you
 * end turn queuing when waiting for other players (great idea!)
 * handling long names / special characters in names
 * playing one more round after the last card is drawn
 * color-code the law contents to match card colors
 * highlight laws on mouse over when selecting for judge or doctor
 * 
 * TODO bugs:
 * disappearing cards, appearing cards - ask server every time?
 * issues with players leaving
 * issues with rematches and data getting out of synch
 * unload timers?
 * theif can undo rearranging your hand; propagate hand rearranging data events?
 *  
 * TODO graphics/flavor:
 * talk to artists about improving graphics
 * animate backgrounds (from robert: people milling about, something behind the columns)
 * chisel animation
 * sound - chisel, focus gain, card/money loss, card/money gain, background(?)
 * 
 */
[SWF(width="1000", height="550")]
public class LawsAndDisorder extends Sprite
{
    /** Message that game is ending */
    public static const GAME_ENDING :String = "gameEnding";

    /**
     * Constructor.  Set up game control, context, and board.  Add listeners for game events,
     * and begin data initilization.
     */
    public function LawsAndDisorder ()
    {
        // create context and game controller
        var control :GameControl = new GameControl(this, false);
        _ctx = new Context(control);
		
		// if we're not connected, stop here
        if (!_ctx.control.isConnected()) {
            return;
        }
        
        // connect game state listeners
        _ctx.control.game.addEventListener(StateChangedEvent.GAME_STARTED, gameStarted);
        _ctx.control.game.addEventListener(StateChangedEvent.GAME_ENDED, gameEnded);
        _ctx.control.player.addEventListener(CoinsAwardedEvent.COINS_AWARDED, coinsAwarded);
        _ctx.control.game.addEventListener(OccupantChangedEvent.OCCUPANT_ENTERED, occupantEntered);
        _ctx.control.game.addEventListener(OccupantChangedEvent.OCCUPANT_LEFT, occupantLeft);
        _ctx.control.game.addEventListener(StateChangedEvent.CONTROL_CHANGED, controlChanged);
        
        // create our state and our board, and initialize them
        _ctx.state = new State(_ctx);
        _ctx.eventHandler = new EventHandler(_ctx);
        _ctx.board = new Board(_ctx);
        addChild(_ctx.board);
        
		/*
        var endGameButton :TextField = new TextField();
        endGameButton.text = "END GAME";
        endGameButton.addEventListener(MouseEvent.CLICK, function () {_ctx.eventHandler.startLastRound();});
        addChild(endGameButton);
        _ctx.log("[testing] Your player id is " + _ctx.control.game.getMyId());
		*/
        
        _ctx.control.game.playerReady();
    }
    
    /** 
     * Fires when all players have called playerReady().  Have the control player set
     * up the board data then start the first turn.
     */
    protected function gameStarted (event :StateChangedEvent) :void
    {
    	if (_ctx.control.game.amInControl()) {
    		beginInit();
    	}
    	
        _ctx.notice("Welcome to Laws & Disorder.  Click on the board to start!");
        _gameStarted = true;
    }
    
    /**
     * Have the control player set the distributed data objects to blank arrays.  
     * Control player will then wait to hear about it 
     * from the server before contiinuing to fill properties with actual data.
     * Also reset deck, hands, and scores for all players.
     */
    protected function beginInit () :void
    {
        if (_ctx.control.game.amInControl()) {
            _ctx.control.net.addEventListener(PropertyChangedEvent.PROPERTY_CHANGED, initPropertyChanged);
            var playerCount :int = _ctx.control.game.seating.getPlayerIds().length;
            
            _ctx.eventHandler.setData(Player.MONIES_DATA, new Array(playerCount).map(function (): int { return Player.STARTING_MONIES; }));
            _ctx.eventHandler.setData(Hand.HAND_DATA, new Array(playerCount).map(function (): Array { return new Array(); }));
            _ctx.eventHandler.setData(Deck.JOBS_DATA, new Array(playerCount).map(function (): int { return -1; }));
        }
    }
    
    /**
     * Fires when a data event occurs during control player init.  Control player must receive
     * these data initialization messages before they can send the player, hand and deck data
     * in Board.setup().  Other players skip this step.
     */
    protected function initPropertyChanged (event :PropertyChangedEvent) :void
    {
        if (event.name == Player.MONIES_DATA) {
            _initMoniesData = true;
        }
        else if (event.name == Hand.HAND_DATA) {
            _initHandsData = true;
        }
        else if (event.name == Deck.JOBS_DATA) {
            _initJobsData = true;
        }

        // once all data messages are recieved, disconnect this listener and finish setup
        if (_initMoniesData && _initHandsData && _initJobsData) {
            _ctx.control.net.removeEventListener(PropertyChangedEvent.PROPERTY_CHANGED, initPropertyChanged);
            _ctx.board.setup();
            
            if (_ctx.control.game.amInControl()) {
                // control player starts the first turn
                _ctx.control.game.startNextTurn();
            }
            
        }
    }
    
    /**
     * Handler for recieving game end events
     * TODO move to Notices?
     */
    protected function gameEnded (event :StateChangedEvent) :void
    {
        _ctx.notice("Game over - thanks for playing!");
        // TODO for testing, start over
        //_ctx.control.game.playerReady();
    }

    /**
     * Handler for receiving coins awarded events
     * TODO move to Notices?
     */
    protected function coinsAwarded (event :CoinsAwardedEvent) :void
    {
        _ctx.notice("You got: " + event.amount + " coins for playing.  That's " + event.percentile + "%");
    }

    /**
     * Handler for dealing with players / watchers joining.
     * Players can't join this game on the fly, sorry
     */
    protected function occupantEntered (event :OccupantChangedEvent) :void
    {
        if (event.player) {
        	if (_ctx != null) {
        		_ctx.log("WTF player joined the game partway through - impossible!");
        	}
        }
    }
    
    /**
     * Handler for dealing with players / watchers leaving
     * TODO what if we're waiting for that player?
     */
    protected function occupantLeft (event :OccupantChangedEvent) :void
    {
    	_ctx.log("player left: " + event.occupantId);
        // player left before game started; start game over and hope that works
        // TODO it won't though, because player objects are already created.
        if (!_gameStarted && event.player) {
        	if (_ctx != null) {
        		_ctx.notice("Player left before the game started.  Attempting to start over.");
        	}
            if (_ctx.control.game.amInControl()) {
                beginInit();
            }
        }
        else if (event.player) {
            _ctx.log("Player " + event.occupantId + " left.");
        	_ctx.board.playerLeft(event.occupantId);
        }
    }
    
    /**
     * Handler for dealing with control switching to another player
     */
    protected function controlChanged (event :StateChangedEvent) :void
    {
    	_ctx.notice("Control changed when player left.");
    }
    
    /** Context */
    protected var _ctx :Context;
    
    /** Indicates data objects have been setup on the server */
    protected var _initMoniesData :Boolean = false;
    protected var _initHandsData :Boolean = false;
    protected var _initJobsData :Boolean = false;
    
    /** Has the game started */
    protected var _gameStarted :Boolean = false;
}
}