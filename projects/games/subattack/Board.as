package {

import flash.events.Event;

import flash.geom.Point;

import com.threerings.ezgame.StateChangedEvent;
import com.threerings.ezgame.MessageReceivedEvent;

import com.whirled.WhirledGameControl;

public class Board
{
    /** Traversability constants. */
    public static const BLANK :int = 0;
    public static const BLOCKED :int = 1;

    public function Board (gameCtrl :WhirledGameControl, seaDisplay :SeaDisplay)
    {
        _gameCtrl = gameCtrl;
        _gameCtrl.addEventListener(Event.UNLOAD, shutdown);
        _seaDisplay = seaDisplay;

        var playerIds :Array = _gameCtrl.seating.getPlayerIds();
        var playerCount :int = playerIds.length;
        _width = int(DIMENSIONS[playerCount][0]);
        _height = int(DIMENSIONS[playerCount][1]);

        // compute some game-ending numbers
        _maxTotalDeaths = playerCount * 5;
        _maxKills = Math.max(1, (playerCount - 1) * 5);

        _seaDisplay.setupSea(_width, _height);

        var ii :int;
        for (ii = _width * _height - 1; ii >= 0; ii--) {
            _traversable[ii] = BLOCKED;
        }

        // create a submarine for each player
        var sub :Submarine;
        for (ii = 0; ii < playerIds.length; ii++) {
            var playerId :int = (playerIds[ii] as int);
            var p :Point = getStartingPosition(ii);

            sub = new Submarine(
                playerId, ii, _gameCtrl.getOccupantName(playerId), p.x, p.y, this, _gameCtrl);
            _gameCtrl.getUserCookie(playerId, sub.gotPlayerCookie);
            _seaDisplay.addChild(sub);
            _subs[ii] = sub;

            // mark this sub's starting location as traversable
            setBlank(p.x, p.y);
        }

        // if we're a player, put our submarine last, so that it
        // shows up always on top of other submarines
        var myIndex :int = gameCtrl.seating.getMyPosition();
        if (myIndex != -1) {
            sub = (_subs[myIndex] as Submarine);
            _seaDisplay.setChildIndex(sub, _seaDisplay.numChildren - 1);
            _seaDisplay.setFollowSub(sub);
        }

        _seaDisplay.addEventListener(Event.ENTER_FRAME, enterFrame);

        _gameCtrl.addEventListener(MessageReceivedEvent.TYPE, msgReceived);
        if (gameCtrl.isInPlay()) {
            // this may happen if we're rematching
            gameDidStart(null);

        } else {
            _gameCtrl.addEventListener(StateChangedEvent.GAME_STARTED,
                gameDidStart);
        }
        _gameCtrl.addEventListener(StateChangedEvent.GAME_ENDED,
            gameDidEnd);
    }

    /**
     * Shutdown this board when it's no longer the active board.
     */
    public function shutdown (... ignored) :void
    {
        _seaDisplay.removeEventListener(Event.ENTER_FRAME, enterFrame);
        _gameCtrl.removeEventListener(MessageReceivedEvent.TYPE, msgReceived);
        _gameCtrl.removeEventListener(StateChangedEvent.GAME_STARTED, gameDidStart);
        _gameCtrl.removeEventListener(StateChangedEvent.GAME_ENDED, gameDidEnd);
    }

    /**
     * Is the specified tile completely traversable?
     */
    public function isBlank (xx :int, yy :int) :Boolean
    {
        return (xx >= 0) && (xx < _width) && (yy >= 0) && (yy < _height) &&
            (BLANK == int(_traversable[coordsToIdx(xx, yy)]));
    }

    /**
     * Is the specified tile traversable by the specified player index or their torpedos?
     */
    public function isTraversable (playerIdx :int, xx :int, yy :int) :Boolean
    {
        if (xx < 0 || xx >= _width || yy < 0 || yy >= _height) {
            return false;
        }

        var val :int = int(_traversable[coordsToIdx(xx, yy)]);
        if (val == BLOCKED) {
            return false;

        } else if (val == BLANK) {
            return true;

        } else {
            return (playerIdx == int(val / -100));
        }
    }

    /**
     * Called to build a barrier at the specified location.
     */
    public function buildBarrier (playerIdx :int, xx :int, yy :int) :void
    {
        var dex :int = coordsToIdx(xx, yy);
        var val :int = int(_traversable[dex]);
        if (val == BLANK) {
            val = -1 * (playerIdx * 100 + 2);
            _traversable[dex] = val;
            _seaDisplay.updateTraversable(xx, yy, val, isBlank(xx, yy - 1), isBlank(xx, yy + 1));
        }
    }

    /**
     * Called by a submarine to respawn.
     */
    public function respawn (sub :Submarine) :void
    {
        // scan through the entire array and remember the location furthest
        // away from other subs and torpedos
        var bestx :int = sub.getX();
        var besty :int = sub.getY();
        var bestDist :Number = 0;
        for (var yy :int = 0; yy < _height; yy++) {
            for (var xx :int = 0; xx < _width; xx++) {
                if (0 == int(_traversable[coordsToIdx(xx, yy)])) {
                    var minDist :Number = Number.MAX_VALUE;
                    for each (var otherSub :Submarine in _subs) {
                        if (otherSub != sub && !otherSub.isDead()) {
                            minDist = Math.min(minDist,
                                otherSub.distance(xx, yy));
                        }
                    }
                    for each (var torp :Torpedo in _torpedos) {
                        var checkDist :Boolean = false;
                        switch (torp.getOrient()) {
                        case Action.UP:
                            checkDist = (torp.getX() == xx) &&
                                (torp.getY() >= yy);
                            break;

                        case Action.DOWN:
                            checkDist = (torp.getX() == xx) &&
                                (torp.getY() <= yy);
                            break;

                        case Action.LEFT:
                            checkDist = (torp.getY() == yy) &&
                                (torp.getX() >= xx);
                            break;

                        case Action.RIGHT:
                            checkDist = (torp.getY() == yy) &&
                                (torp.getX() <= xx);
                            break;
                        }

                        if (checkDist) {
                            minDist = Math.min(minDist,
                                torp.distance(xx, yy));
                        }
                    }
                    if (minDist > bestDist) {
                        bestDist = minDist;
                        bestx = xx;
                        besty = yy;
                    }
                }
            }
        }

        // we've found such a great spot, and all the other clients
        // should find the same spot
        sub.respawn(bestx, besty);
    }

    /**
     * Called by a torpedo to notify us that it was added.
     */
    public function torpedoAdded (torpedo :Torpedo) :void
    {
        _torpedos.push(torpedo);
        _seaDisplay.addChildAt(torpedo, 0);
    }

    /**
     * Called by a torpedo when it has exploded.
     *
     * @return the number of subs hit by the explosion.
     */
    public function torpedoExploded (torpedo :Torpedo) :int
    {
        // remove it from our list of torpedos
        var idx :int = _torpedos.indexOf(torpedo);
        if (idx == -1) {
            trace("OMG! Unable to find torpedo??");
            return 0;
        }
        _torpedos.splice(idx, 1); // remove that torpedo
        _seaDisplay.removeChild(torpedo);

        // find all the subs affected
        var killer :Submarine = torpedo.getOwner();
        var killCount :int = 0;
        var killerIdx :int = killer.getPlayerIndex();
        var xx :int = torpedo.getX();
        var yy :int = torpedo.getY();
        for each (var sub :Submarine in _subs) {
            if (!sub.isDead() && sub.getX() == xx && sub.getY() == yy) {
                sub.wasKilled();
                killCount++;
                _totalDeaths++;

                _gameCtrl.localChat(killer.getPlayerName() + " has shot " +
                    sub.getPlayerName());

                if (killerIdx == _gameCtrl.seating.getMyPosition()) {
                    // TODO: new flow awarding
//                    var flowAvailable :Number = _gameCtrl.getAvailableFlow();
//                    trace("Available flow at time of kill: " + flowAvailable);
//                    var awarded :int = int(flowAvailable * .75);
//                    trace("Awarding: " + awarded);
//                    _gameCtrl.awardFlow(awarded);
                }
            }
        }

        // if it exploded in bounds, make that area traversable
        if (xx >= 0 && xx < _width && yy >= 0 && yy < _height) {
            // mark the board area as traversable there
            noteTorpedoExploded(xx, yy, killerIdx);
            _seaDisplay.addChildAt(new Explode(xx, yy, this), 0);
        }

        return killCount;
    }

    protected function coordsToIdx (xx :int, yy :int) :int
    {
        return (yy * _width) + xx;
    }

    protected function setBlank (xx :int, yy :int) :void
    {
        _traversable[coordsToIdx(xx, yy)] = BLANK;
        _seaDisplay.updateTraversable(xx, yy, BLANK, isBlank(xx, yy - 1), isBlank(xx, yy + 1));
    }

    /**
     * Note that a torpedo exploded and make any required modifications to the board.
     */
    protected function noteTorpedoExploded (xx :int, yy :int, playerIndex :int) :void
    {
        var idx :int = coordsToIdx(xx, yy);
        var val :int = int(_traversable[idx]);
        if (val == BLANK) {
            // that's strange, but ok
            return; // nothing to do

        } else if (val > BLANK) {
            val--;

        } else {
            var pidx :int = int(val / -100);
            if (playerIndex == pidx) {
                // the torpedo exploded on one of the player's own defense squares
                return;
            }

            var level :int = -val % 100;
            level--;
            if (level == 0) {
                val = BLANK;
            } else {
                val = -(pidx * 100 + level)
            }
        }

        // record the new traversability
        _traversable[idx] = val;

        // update the display
        _seaDisplay.updateTraversable(xx, yy, val, isBlank(xx, yy - 1), isBlank(xx, yy + 1));
    }

//    protected function incTraversable (xx :int, yy :int) :void
//    {
//        var idx :int = coordsToIdx(xx, yy);
//        var val :int = int(_traversable[idx]);
//        if (val > 0) {
//            val--;
//            _traversable[idx] = val;
//            _seaDisplay.updateTraversable(xx, yy, val, isTraversable(xx, yy - 1),
//                isTraversable(xx, yy + 1));
//        }
//    }

    /**
     * Handles game did start, and that's it.
     */
    protected function gameDidStart (event :StateChangedEvent) :void
    {
        // player 0 starts the ticker
        if (_gameCtrl.seating.getMyPosition() == 0) {
            _gameCtrl.startTicker("tick", 100);
        }
    }

    protected function gameDidEnd (event :StateChangedEvent) :void
    {
        var mydex :int = _gameCtrl.seating.getMyPosition();
        if (mydex >= 0) {
            _gameCtrl.setUserCookie(Submarine(_subs[mydex]).getNewCookie());
        }

        _seaDisplay.setStatus("<P align=\"center\"><font size=\"+4\"><b>Game Over</b></font></P>");
        shutdown();
    }

    /**
     * Handles MessageReceivedEvents.
     */
    protected function msgReceived (event :MessageReceivedEvent) :void
    {
        var name :String = event.name;
        if (name == "tick") {
            _ticks.push(new Array());

            if (_ticks.length > MAX_QUEUED_TICKS) {
                doTick(); // do one now...
            }

        } else {
            // add any actions received during this tick
            var array :Array = (_ticks[_ticks.length - 1] as Array);
            array.push(event.name);
            array.push(event.value);
        }
    }

    protected function processAction (name :String, actions :Array) :void
    {
        if (name.indexOf("sub") == 0) {
            var subIndex :int = int(name.substring(3));
            var sub :Submarine = Submarine(_subs[subIndex]);
            for each (var action :int in actions) {
                sub.performAction(action);
            }
        }
    }

    protected function doTick () :void
    {
        var array :Array = (_ticks.shift() as Array);
        for (var ii :int = 0; ii < array.length; ii += 2) {
            processAction(String(array[ii]), (array[ii + 1] as Array));
        }

        var sub :Submarine;
        var torp :Torpedo;
        // tick all subs and torps
        for each (sub in _subs) {
            sub.tick();
        }
        var torpsCopy :Array = _torpedos.concat();
        for each (torp in torpsCopy) {
            // this may explode a torpedo if it hits seaweed or a wall
            torp.tick();
        }

        // then we check torpedo-on-torpedo action, and pass-through
        checkTorpedos();

        if (_gameCtrl.seating.getMyPosition() == 0 && !_endedGame) {
            checkGameOver();
        }
    }

    protected function checkGameOver () :void
    {
        var endGame :Boolean = (_totalDeaths >= _maxTotalDeaths);
        var sub :Submarine;
        if (!endGame) {
            for each (sub in _subs) {
                if (sub.getKills() >= _maxKills) {
                    endGame = true;
                    break;
                }
            }
            if (!endGame) {
                return;
            }
        }

        // if we get here, we DO want to end the game.
        // compute a score for each player based on _maxKills and normalize
        // from 0 - 99.
        var ids :Array = [];
        var scores :Array = [];
        for (var ii :int = 0; ii < _subs.length; ii++) {
            sub = _subs[ii] as Submarine;
            ids[ii] = sub.getPlayerId();
            scores[ii] = int(99 * Math.max(0, sub.getKills() - sub.getDeaths()) / _maxKills);
        }

        trace("Computed scores as " + scores);

        _gameCtrl.endGameWithScores(ids, scores, WhirledGameControl.TO_EACH_THEIR_OWN);
        _endedGame = true;
    }

    protected function checkTorpedos () :void
    {
        // check to see if any torpedos are hitting subs
        var torp :Torpedo;
        var sub :Submarine;
        var xx :int;
        var yy :int;
        var exploders :Array = [];
        for each (torp in _torpedos) {
            xx = torp.getX();
            yy = torp.getY();
            for each (sub in _subs) {
                if (!sub.isDead() && (xx == sub.getX()) && (yy == sub.getY())) {
                    // we have a hit!
                    if (-1 == exploders.indexOf(torp)) {
                        exploders.push(torp);
                    }
                    break; // break the inner loop (one sub is enough!)
                }
            }

            for each (var torp2 :Torpedo in _torpedos) {
                if (torp != torp2 && torp.willExplode(torp2)) {
                    if (-1 == exploders.indexOf(torp)) {
                        exploders.push(torp);
                    }
                    if (-1 == exploders.indexOf(torp2)) {
                        exploders.push(torp2);
                    }
                }
            }
        }

        // now explode any torps that need it
        for each (torp in exploders) {
            torp.explode();
        }
    }

    /**
     * Handles Event.ENTER_FRAME.
     */
    protected function enterFrame (event :Event) :void
    {
        if (_ticks.length > 1) {
            doTick();
        }
    }

    /**
     * Return the starting x coordinate for the specified player.
     */
    protected function getStartingPosition (playerIndex :int) :Point
    {
        switch (playerIndex) {
        default:
            trace("Cannot yet handle " + (playerIndex + 1) + " player games!");
            // fall through to 0
        case 0:
            return new Point(0, 0);

        case 1:
            return new Point(_width - 1, _height - 1);

        case 2:
            return new Point(0, _height - 1);

        case 3:
            return new Point(_width - 1, 0);

        case 4:
            return new Point(0, _height / 2);

        case 5:
            return new Point(_width - 1, _height / 2);

        case 6:
            return new Point(_width / 2, 0);

        case 7:
            return new Point(_width / 2, _height - 1);
        }
    }

    /** The game Control. */
    protected var _gameCtrl :WhirledGameControl;

    /** The 'sea' where everything lives. */
    protected var _seaDisplay :SeaDisplay;

    protected var _totalDeaths :int = 0;

    /** The maximum number of total deaths before we end the game. */
    protected var _maxTotalDeaths :int;

    /** The maximum number of kills any player may accumulate before we end the game. */
    protected var _maxKills :int;

    /** The width of the board. */
    protected var _width :int;

    /** The height of the board. */
    protected var _height :int;
    
    protected var _ticks :Array = [];

    /** Contains the submarines, indexed by player index. */
    protected var _subs :Array = [];

    /** Contains active torpedos, in no particular order. */
    protected var _torpedos :Array = [];

    /** An array tracking the traversability of each tile. */
    protected var _traversable :Array = [];

    /** Have we already ended the game? (Stop trying to do it again while a few
     * last ticks trickle in.) */
    protected var _endedGame :Boolean = false;

    protected static const DIMENSIONS :Array = [
        [  0,  0 ], // 0 player game
        [ 10, 10 ], // 1 player game
//        [ 10, 10 ], // 2 player game (testing)
        [ 50, 25 ], // 2 player game
        [ 60, 30 ], // 3 player game
        [ 75, 30 ], // 4 player game
        [ 75, 40 ], // 5 player game
        [ 80, 40 ], // 6 player game
        [ 80, 50 ], // 7 player game
        [ 90, 50 ]  // 8 players!
    ];

    protected static const MAX_QUEUED_TICKS :int = 5;

    protected static const SHOTS_TO_DESTROY :int = 1; // 2;
}
}
