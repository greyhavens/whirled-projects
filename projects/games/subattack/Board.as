package {

import flash.events.Event;

import flash.geom.Point;

import flash.utils.Dictionary;

import com.threerings.ezgame.StateChangedEvent;
import com.threerings.ezgame.MessageReceivedEvent;

import com.whirled.WhirledGameControl;

import com.threerings.util.Log;
import com.threerings.util.Random;
import com.threerings.util.StringUtil;

public class Board
{
    /** Traversability constants. */
    public static const BLANK :int = 0;
    public static const TREE :int = 1;
    public static const TEMPLE :int = 2;
    public static const ROCK :int = int.MAX_VALUE;

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

        var size :int = _width * _height;
        var ii :int;
        for (ii = size - 1; ii >= 0; ii--) {
            _board[ii] = TREE;
        }

        var rando :Random = new Random(int(_gameCtrl.get("seed")));
        var pick :int;

        // scatter some rocks around
        var numRocks :int = size / 40;
        for (ii = 0; ii < numRocks; ii++) {
            do {
                pick = rando.nextInt(size);
            } while (_board[pick] != TREE);
            _board[pick] = ROCK;
        }

        // scatter some temples around
        var numTemples :int = size / 10;
        for (ii = 0; ii < numTemples; ii++) {
            do {
                pick = rando.nextInt(size);
            } while (_board[pick] != TREE);
            _board[pick] = TEMPLE;
        }

        // scatter some clumpy clearings
        var numBlanks :int = size / 100;
        for (ii = 0; ii < numBlanks; ii++) {
            do {
                pick = rando.nextInt(size);
            } while (_board[pick] != TREE);
            var radius :int = rando.nextInt(3);
            var x :int = int(pick % _width);
            var y :int = int(pick / _width);
            for (var yy :int = Math.max(0, y - radius); yy <= Math.min(_height - 1, y + radius);
                    yy++) {
                for (var xx :int = Math.max(0, x - radius); xx <= Math.min(_width - 1, x + radius);
                        xx++) {
                    _board[xx + (yy * _width)] = BLANK;
                }
            }
        }

        _seaDisplay.setupSea(_width, _height, _board, rando);

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

            var ghost :GhostSubmarine = sub.getGhost();
            if (ghost != null) {
                _seaDisplay.addChild(ghost);
            }
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
     * Is the specified tile completely traversable, not counting any factories?
     */
    public function isBlankOrFactory (xx :int, yy :int) :Boolean
    {
        return (xx >= 0) && (xx < _width) && (yy >= 0) && (yy < _height) &&
            (BLANK >= int(_board[coordsToIdx(xx, yy)]));
    }

    /**
     * Is the specified tile traversable by the specified player index or their torpedos?
     */
    public function isTraversable (playerIdx :int, xx :int, yy :int) :Boolean
    {
        if (xx < 0 || xx >= _width || yy < 0 || yy >= _height) {
            return false;
        }

        var val :int = int(_board[coordsToIdx(xx, yy)]);
        if (val > BLANK) {
            return false;

        } else if (val == BLANK) {
            return true;

        } else {
            return (playerIdx == int(val / -100));
        }
    }

    public function isDestructable (playerIdx :int, xx :int, yy :int) :Boolean
    {
        if (xx < 0 || xx >= _width || yy < 0 || yy >= _height) {
            return false;
        }

        var val :int = int(_board[coordsToIdx(xx, yy)]);
        if (val == BLANK || val == ROCK) {
            return false;

        } else if (val > BLANK) {
            return true;

        } else {
            return (playerIdx != int(val / -100));
        }
    }

    public function showPoints (x :int, y :int, points :int) :void
    {
        var pts :PointsSprite = new PointsSprite(points);
        pts.x = x * SeaDisplay.TILE_SIZE;
        pts.y = y * SeaDisplay.TILE_SIZE;
        _seaDisplay.addChild(pts);
    }

    /**
     * Called to build a factory at the specified location.
     */
    public function buildFactory (sub :Submarine) :void
    {
        var dex :int = coordsToIdx(sub.getX(), sub.getY());
        var val :int = int(_board[dex]);
        if (val == BLANK) {
            _board[dex] = -1 * (sub.getPlayerIndex() * 100 + Factory.MAX_HITS);
            var factory :Factory = new Factory(sub, this);
            _factories[dex] = factory;
            _seaDisplay.addFactory(factory);
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
                if (Board.BLANK == int(_board[coordsToIdx(xx, yy)])) {
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
        _seaDisplay.addChild(torpedo);
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

        var xx :int = torpedo.getX();
        var yy :int = torpedo.getY();
        var killer :Submarine = torpedo.getOwner();
        var killerIdx :int = killer.getPlayerIndex();

        // if it exploded in bounds, make that area traversable
        var subsAffected :Boolean = false;
        if (xx >= 0 && xx < _width && yy >= 0 && yy < _height) {
            // mark the board area as traversable there
            subsAffected = noteTorpedoExploded(xx, yy, killerIdx);
            _seaDisplay.addChild(new Explode(xx, yy, this));
        }

        // find all the subs affected
        var killCount :int = 0;
        if (subsAffected) {
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
        }

        return killCount;
    }

    protected function coordsToIdx (xx :int, yy :int) :int
    {
        return (yy * _width) + xx;
    }

    protected function setBlank (xx :int, yy :int) :void
    {
        _board[coordsToIdx(xx, yy)] = BLANK;
        _seaDisplay.updateTraversable(xx, yy, BLANK,
            isBlankOrFactory(xx, yy - 1), isBlankOrFactory(xx, yy + 1));
    }

    /**
     * Note that a torpedo exploded and make any required modifications to the board.
     *
     * @return true if subs should be affected by an explosion on this square.
     */
    protected function noteTorpedoExploded (xx :int, yy :int, playerIndex :int) :Boolean
    {
        var idx :int = coordsToIdx(xx, yy);
        var val :int = int(_board[idx]);
        if (val == ROCK) {
            return false; // there shouldn't even be any subs here

        } else if (val == BLANK) {
            return true; // there's ONLY subs here

        } else if (val > BLANK) {
            val--;

        } else {
            var pidx :int = int(val / -100);
            if (playerIndex == pidx) {
                // the torpedo exploded on one of the player's own defense squares
                // so it must have hit another sub
                return true;
            }

            var factory :Factory = Factory(_factories[idx]);
            var level :int = -val % 100;
            level--;
            if (level == 0) {
                val = BLANK;
                _seaDisplay.removeChild(factory);
                delete _factories[idx];

            } else {
                val = -(pidx * 100 + level)
                factory.updateVisual(level);
            }
            _board[idx] = val;
            return false;
        }

        // record the new traversability
        _board[idx] = val;

        // update the display
        _seaDisplay.updateTraversable(xx, yy, val,
            isBlankOrFactory(xx, yy - 1), isBlankOrFactory(xx, yy + 1));
        // we are exploding because we hit a non-traversable tile, so we don't affect
        // any subs on that tile...
        return false;
    }

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
        for each (var factory :Factory in _factories) {
            factory.tick();
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

    /** An array tracking the type of each tile. */
    protected var _board :Array = [];

    /** Holds the currently active factories. */
    protected var _factories :Dictionary = new Dictionary();

    /** Have we already ended the game? (Stop trying to do it again while a few
     * last ticks trickle in.) */
    protected var _endedGame :Boolean = false;

    protected static const DIMENSIONS :Array = [
        [  0,  0 ], // 0 player game
        [ 10, 10 ], // 1 player game
//        [ 90, 60], // TEST!
//        [ 10, 10 ], // 2 player game (testing)
//        [ 15, 15 ], // 2 player game (testing)
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
