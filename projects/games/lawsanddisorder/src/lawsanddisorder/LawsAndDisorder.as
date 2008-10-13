package lawsanddisorder {

import flash.display.Sprite;
import flash.display.MovieClip;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.text.TextField;

import com.whirled.game.GameControl;
//import com.whirled.net.PropertyChangedEvent;
import com.whirled.game.PropertyChangedEvent;
import com.whirled.game.PropertyChangedEvent;
import com.whirled.game.StateChangedEvent;
import com.whirled.game.OccupantChangedEvent;

import lawsanddisorder.component.*

/**
 * Main game class handles game setup and players joining/leaving.
 * 
 * TODO logic & bugs:
 * re-implement afk boot code because the sdk changed
 * make number of (including ai) players a variable set by players from game lobby
 * replace players with ai when they leave mid-game
 * if last card drawn during ai turn, play until the end of ai turn
 * test and finish implementing trophies
 * improve ai handling of job powers
 *
 * TODO interface:
 * opponent hands go under buttons
 * make splash screen a 3 screen click through
 * animate opponent we are waiting for
 * animations when playing law, gain/lose/give monies
 * card mouseover tooltips, esp job powers?
 * display job power in use power button
 * connect use power button to job
 * better explanation of each ability (in help?  tooltips?  with pictures?)
 * end turn queuing when waiting for other players (great idea!)
 * handling long names / special characters in names
 * color-code the law contents to match card colors (?)
 * improve notice text & clear after notices complete
 */
[SWF(width="1000", height="550")]
public class LawsAndDisorder extends Sprite
{
    /** Message that game is ending */
    public static const GAME_ENDING :String = "gameEnding";
    
    /** The number of players in the game (2-6) */
    public static const NUM_PLAYERS :int = 6;

    /**
     * Constructor.  Set up game control, context, and board.  Add listeners for game events, and
     * begin data initilization.
     */
    public function LawsAndDisorder ()
    {
        // create context and game controller
        var control :GameControl = new GameControl(this, false);
        _ctx = new Context(control);
        if (!_ctx.control.isConnected()) {
            return;
        }

        // connect game state listeners
        _ctx.control.game.addEventListener(StateChangedEvent.GAME_STARTED, gameStarted);
        _ctx.control.game.addEventListener(OccupantChangedEvent.OCCUPANT_ENTERED, occupantEntered);
        _ctx.control.game.addEventListener(OccupantChangedEvent.OCCUPANT_LEFT, occupantLeft);
        _ctx.control.game.addEventListener(StateChangedEvent.CONTROL_CHANGED, controlChanged);
        addEventListener(Event.REMOVED_FROM_STAGE, removedFromStage);

        // create our state, event, and trophy handlers
        _ctx.state = new State(_ctx);
        _ctx.eventHandler = new EventHandler(_ctx);
        _ctx.trophyHandler = new TrophyHandler(_ctx);

        // if we're a watcher, assume the game has already started and fetch data
        if (_ctx.control.game.seating.getMyPosition() == -1) {
            _gameStarted = true;
            _ctx.board = new Board(_ctx);
            addChild(_ctx.board);
            _ctx.board.refreshData();
        }

        _ctx.control.game.playerReady();
    }

    /**
     * Game is no longer being displayed; stop the timers.
     */
    protected function removedFromStage (event :Event) :void
    {
        _ctx.state.unload();
    }

    /**
     * Fires when all players have called playerReady(), whether for the first time during the
     * constructor or automatically after a rematch has been called.  Have the control player
     * set up the board data then start the first turn.
     */
    protected function gameStarted (event :StateChangedEvent) :void
    {
        if (_ctx.board == null) {
            _ctx.board = new Board(_ctx);
            addChild(_ctx.board);
            
            /*
            // FOR TESTING start the last round button
            var endGameButton :TextField = new TextField();
            endGameButton.height = 30;
            endGameButton.text = "LAST ROUND";
            endGameButton.addEventListener(MouseEvent.CLICK, 
                function () :void {_ctx.eventHandler.startLastRound();});
            addChild(endGameButton);
            */
        }
        
        if (_ctx.control.game.amInControl()) {
            //_ctx.notice("You are the game controller.");
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
            _ctx.control.net.addEventListener(
                PropertyChangedEvent.PROPERTY_CHANGED, initPropertyChanged);
            var playerCount :int = _ctx.control.game.seating.getPlayerIds().length;

            _ctx.eventHandler.setData(Player.MONIES_DATA, new Array(NUM_PLAYERS).map(
                function (): int { return Player.STARTING_MONIES; }));
            _ctx.eventHandler.setData(Hand.HAND_DATA, new Array(NUM_PLAYERS).map(
                function (): Array { return new Array(); }));
            _ctx.eventHandler.setData(Deck.JOBS_DATA, new Array(NUM_PLAYERS).map(
                function (): int { return -1; }));
        }
    }

    /**
     * Fires when a data event occurs during control player init.  Control player must receive
     * these data initialization messages before they can send the player, hand and deck data in
     * Board.setup().  Other players skip this step.
     */
    protected function initPropertyChanged (event :PropertyChangedEvent) :void
    {
        if (event.name == Player.MONIES_DATA) {
            _ctx.log("monies reset");
            _initMoniesData = true;
        }
        else if (event.name == Hand.HAND_DATA) {
            _ctx.log("hand data reset");
            _initHandsData = true;
        }
        else if (event.name == Deck.JOBS_DATA) {
            _ctx.log("job data reset");
            _initJobsData = true;
        }

        // once all data messages are recieved, disconnect this listener and finish setup
        if (_initMoniesData && _initHandsData && _initJobsData) {
            _initMoniesData = false;
            _initHandsData = false;
            _initJobsData = false;
            
            _ctx.control.net.removeEventListener(
                PropertyChangedEvent.PROPERTY_CHANGED, initPropertyChanged);
            // delay this so that other objects have a chance to clear data
            EventHandler.startTimer(30, 
                function (): void { 
                    _ctx.board.setup();
                    // control player starts the first turn
                    if (_ctx.control.game.amInControl()) {
                        _ctx.control.game.startNextTurn();
                    }
                });
        }
    }

    /**
     * Handler for dealing with players / watchers joining.
     * Players can't join this game on the fly, sorry
     */
    protected function occupantEntered (event :OccupantChangedEvent) :void
    {
        if (event.player && _ctx != null && _gameStarted) {
            _ctx.log("WTF player joined the game partway through - impossible!");
        }
    }

    /**
     * Handler for dealing with players / watchers leaving
     * TODO what if we're waiting for that player?
     */
    protected function occupantLeft (event :OccupantChangedEvent) :void
    {
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
            _ctx.board.players.playerLeft(event.occupantId);
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