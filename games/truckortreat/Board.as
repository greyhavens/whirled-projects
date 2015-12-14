package {

import flash.display.Bitmap;
import flash.events.TimerEvent;

import com.threerings.ezgame.EZGameControl;
import com.threerings.ezgame.StateChangedEvent;
import com.threerings.ezgame.MessageReceivedEvent;

public class Board extends BaseSprite
{
    /** The y coordinate of the horizon line. */
    public static const HORIZON :int = 152;
    
    /** X coordinate of left side of each sidewalk. */
    public static const LEFT_SIDEWALK :int = 174;
    public static const RIGHT_SIDEWALK :int = 612;
    
    public function Board (gameCtrl :EZGameControl)
    {
        super(0, 0, Bitmap(new backgroundAsset()));
        
        _gameCtrl = gameCtrl;
        _myIndex = gameCtrl.seating.getMyPosition();
        
        _kids = new Array(gameCtrl.seating.getPlayerIds().length);
        // TODO: more hard coding that should go.
        _cars = new Array(2);
        // Add my own kid, and tell other players about it.
        var kid :Kid;
        var playerName :String = gameCtrl.seating.getPlayerNames()[_myIndex];
        var startX :int = getSidewalkX();
        // TODO: The height of both kid bitmaps is 35, but having this be 
        // hard coded is kind of lame.
        var startY :int = getSidewalkY() - 35;
        // TODO: we want to let the player choose the image to use rather 
        // than just grabbing one corresponding to his/her index.
        kid = new Kid(startX, startY, _myIndex * 8, playerName, this);
        _kids[_myIndex] = kid;
        addChild(kid);
        _gameCtrl.sendMessage("newkid" + _myIndex, new Array(startX, startY, _myIndex * 8, playerName));

        // TODO non-hard coded car creation.
        var car :Car = new Car(280, HORIZON + 10, 15, Car.DOWN, this);
        _cars[0] = car;
        addChild(car);
        car = new Car(548, height - 60, 10, Car.UP, this);
        _cars[1] = car;
        addChild(car);
        
        gameCtrl.addEventListener(MessageReceivedEvent.TYPE, msgReceived);
        if (gameCtrl.isInPlay()) {
            gameDidStart(null);
        } else {
            gameCtrl.addEventListener(StateChangedEvent.GAME_STARTED, gameDidStart);
        }
    }
    
    /** Returns the X coordinate of the left side of a random sidewalk. */
    public function getSidewalkX () :int
    {
        if (Math.random() < 0.5) {
            return LEFT_SIDEWALK;
        } else {
            return RIGHT_SIDEWALK;
        }
    }
    
    /** Returns a random Y coordinate of a point on a sidewalk. */
    public function getSidewalkY () :int
    {
        return int(Math.random() * (height - HORIZON)) + HORIZON;
    }
    
    /** Return the Kid object for the specified player. */
    public function getKid (playerIndex :int) :Kid
    {
        return _kids[playerIndex];
    }
    
    /** Tell all other players about this player's current location. */
    public function setMyKidLocation (newX :int, newY :int) :void
    {
        _gameCtrl.sendMessage("kidmoved" + _myIndex, new Array(newX, newY));
    }
    
    /** Tell other players that our avatar animation has changed. */
    public function setKidAnimation (newAnimation :int) :void
    {
        _gameCtrl.sendMessage("setanim" + _myIndex, newAnimation);
    }
    
    /** Do whatever needs to be done on each clock tick. */
    protected function doTick () :void
    {
        // Call tick() on cars to move them.
        var car :Car;
        for each (car in _cars) {
            car.tick();
        }
        
        // Call tick() on this player's kid to move it, and look for collisions.
        var kid :Kid = _kids[_myIndex];
        kid.tick();
        if (kid.isAlive()) {
            // TODO: look for collisions with candy too, perhaps before the 
            // cars so if a player gets a health power up at the same time as 
            // a death dealing hit by a car, he or she will survive.
            for each (car in _cars) {
                // We only need to look for collisions if the kid's feet 
                // intersect with the bottom half of the car. 
                if (car.y + car.height > kid.y + kid.getHeight() && 
                    kid.y + kid.getHeight() > car.y + car.height/2) {
                    if (kid.hitTestObject(car)) {
                        kid.wasKilled();
                        if (kid.livesLeft() <= 0) {
                            // TODO: endGame() takes one or more winning player 
                            // indices. Since we only have one player currently, 
                            // make that one the winner despite having just died.
                            //_gameCtrl.endGame.(0);
                        }
                    }
                }
            }
        }
    }
    
    /** Called when game is ready to start. */
    protected function gameDidStart (event :StateChangedEvent) :void
    {
        // Player 0 starts the ticker.
        if (_gameCtrl.seating.getMyPosition() == 0) {
            _gameCtrl.startTicker("tick", 150);
        }
    }
    
    /** Handles MessageReceivedEvents. */
    protected function msgReceived (event :MessageReceivedEvent) :void
    {
        var name :String = event.name;
        var kid :Kid;
        var kidIndex :int;
        if (name == "tick") {
            doTick();
        } else if (name.indexOf("kidmoved") == 0) {
            kidIndex = int(name.substring(8));
            // Only care if it's not our own kid that moved.
            if (kidIndex != _myIndex) {
                kid = Kid(_kids[kidIndex]);
                var coords :Array = event.value as Array;
                // Need to check this because we might get this message before 
                // we've created this kid.
                if (kid != null) {
                    kid.x = coords[0];
                    kid.y = coords[1];
                }
            }
        } else if (name.indexOf("newkid") == 0) {
            kidIndex = int(name.substring(6));
            // Again, only add the Kid if it's not ours.
            if (kidIndex != _myIndex) {
                // TODO: Wow this is horribly ugly. Perhaps we should serialize
                // when creating kid and unserialize as a ByteArray here.
                var kidArray :Array = event.value as Array;
                kid = new Kid(kidArray[0], kidArray[1], kidArray[2], kidArray[3], this);
                // Put under car and this player's layers. We want it on top of
                // the background image, though.
                addChildAt(kid, 1);
                _kids[kidIndex] = kid;
            }
        } else if (name.indexOf("setanim") == 0) {
            kidIndex = int(name.substring(7));
            if (kidIndex != _myIndex) {
                kid = Kid(_kids[kidIndex]);
                if (kid != null) {
                    // That false is important. Don't send more messages when 
                    // updating animation!
                    kid.setAnimation(event.value as int, false);
                }
            }
        }
    }
    
    protected function addKid (kid :Kid, playerIndex :int) :void
    {
        _gameCtrl.sendMessage("newkid" + playerIndex, kid);
    }
    
    /** The game controller object. */
    protected var _gameCtrl :EZGameControl;
    
    /** A list of characters, one for each player. */
    protected var _kids :Array;
    
    /** A list of cars on the board. */
    protected var _cars :Array;
    
    /** Our player index, or -1 if we're not a player. */
    protected var _myIndex :int;
    
    /** Background image. */
    [Embed(source="rsrc/background.png")]
    protected var backgroundAsset :Class;
}
}
