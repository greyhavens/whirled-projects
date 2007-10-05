package
{

import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.display.Shape;
import flash.events.Event;
import flash.text.TextField;
import mx.core.BitmapAsset;

import com.threerings.ezgame.MessageReceivedEvent;
import com.threerings.ezgame.StateChangedEvent;

import com.whirled.WhirledGameControl;

/**
 * Main game takes care of initializing network connections,
 * maintaining distributed data representation, and responding to events.
 */

[SWF(width="700", height="500")]
public class TangleWord extends Sprite
{
    //
    //
    // PUBLIC METHODS

    // Constructor creates the board, and registers itself for events and other startup
    // information.
    public function TangleWord () :void
    {
        // Register unloader
        root.loaderInfo.addEventListener(Event.UNLOAD, handleUnload);

        // Initialize game data
        _gameCtrl = new WhirledGameControl (this);
        _gameCtrl.registerListener (this);
        if (!_gameCtrl.isConnected())
        {
            // Initialize the background bitmap
            var background :DisplayObject = new Resources.logo();
            Assert.NotNull (background, "Background bitmap failed to initialize!");
            addChild (background);
            // Error message
            var label :TextField = new TextField();
            label.x = 100;
            label.y = 400;
            label.width = Properties.DISPLAY.width - 200;
            label.multiline = true;
            label.htmlText = "<center><p align=\"center\"><font size=\"+2\">TangleWord</font>" +
                "<br/>This game can only be played in <a href=\"http://www.whirled.com\">" +
                "<u>Whirled</u></a>.</p>";
            addChild(label);
            return;
        }

        _gameCtrl.addEventListener(StateChangedEvent.GAME_STARTED, gameDidStart);
        _gameCtrl.addEventListener(MessageReceivedEvent.TYPE, messageReceived);
        _gameCtrl.addEventListener(StateChangedEvent.GAME_ENDED, gameDidEnd);

        // Create MVC elements
        _controller = new Controller (_gameCtrl, null); // we'll set the model later...
        _display = new Display (_gameCtrl, _controller, "Tangleword v. 1.3");
        _model = new Model (_gameCtrl, _display);
        _controller.setModel (_model); // ... as in, right here :)
        addChild (_display);

        // If I'm in control, initialize the scoreboard
        if (_gameCtrl.amInControl()) {
            initializeScoreboard ();
        }

        // If the game's already going, do what you have to do to catch up
        if (_gameCtrl.isInPlay()) {
            gameDidStart(null);
            if (! _gameCtrl.amInControl()) {
                _model.updateFromExistingGame();
            }
        }
    }

    /** Clean up and shut down. */
    public function handleUnload (event :Event) :void
    {
        _display.handleUnload (event);
    }

    protected function gameDidStart (event :StateChangedEvent) :void
    {
        // start up our game ticker if we're the one in control, and call every second
        if (_gameCtrl.amInControl()) {
            _gameCtrl.startTicker("countdown", 1000);
        }
        _model.roundStarted();
        _controller.roundStarted();
        // TODO: if the game is already in progress, deduct the start time from the round length;
        // also we need the board to be in the game object
        _display.roundStarted(Properties.ROUND_LENGTH);
    }

    protected function messageReceived (event :MessageReceivedEvent) :void
    {
        if (event.name == "countdown") {
            var elapsed :int = int(event.value);
            // end the round when the ticks have met or exceeded our round length
            _display.setTimer(Properties.ROUND_LENGTH - elapsed);
            if (elapsed >= Properties.ROUND_LENGTH) {
                _model.endRound();
            }                 
        } else if (event.name == "restart") {
            // we're in a paused state between games
            elapsed = int(event.value);
            _display.setTimer(Properties.PAUSE_LENGTH - elapsed);
            if (elapsed >= Properties.PAUSE_LENGTH) {
                if (_gameCtrl.amInControl()) {
                    // note: this doesn't work on the test server right now
                    _gameCtrl.restartGameIn(1);
                    // to work around the bug, use this when on test server:
                    // _gameCtrl.playerReady();
                    _gameCtrl.stopTicker("restart");
                }
            }
        }
    }

    protected function gameDidEnd (event :StateChangedEvent) :void
    {
        _model.roundEnded();
        _controller.roundEnded();
        _display.roundEnded(Properties.PAUSE_LENGTH);

        if (_gameCtrl.amInControl()) {
            _gameCtrl.stopTicker("countdown");
            _gameCtrl.startTicker("restart", 1000);
        }
    }

    /**
       Sets up the game information. This needs to happen after all of the
       MVC objects have been initialized.
    */
    private function startGame () :void
    {
    }

    /** Creates a new distributed scoreboard */
    private function initializeScoreboard () :void
    {
        // Create a new instance, and fill in the names
        var board :Scoreboard = new Scoreboard ();
        var occupants :Array = _gameCtrl.getOccupants ();
        for each (var id :int in occupants)
        {
            board.addPlayer (_gameCtrl.getOccupantName (id));
        }

        // Finally, share it!
        _gameCtrl.set (SHARED_SCOREBOARD, board.internalScoreObject);
    }

    /** Game control object */
    private var _gameCtrl :WhirledGameControl;

    /** Data interface */
    private var _model :Model;

    /** Data display */
    private var _display :Display;

    /** Data validation */
    private var _controller :Controller;


    // PRIVATE CONSTANTS

    /** Key name: shared letter set */
    private static const SHARED_LETTER_SET :String = "Shared Letter Set";

    /** Key name: shared scoreboard */
    private static const SHARED_SCOREBOARD :String = "Shared Scoreboard";


}



}
