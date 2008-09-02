package {

import flash.events.Event;

import flash.geom.Point;

import flash.media.Sound;

import flash.utils.Dictionary;

import com.threerings.util.Log;
import com.threerings.util.Random;
import com.threerings.util.StringUtil;

import com.whirled.game.*;
import com.whirled.net.*;

public class Board
{
    /** Traversability constants. */
    public static const BLANK :int = 0;
    public static const TREE :int = 1;
    public static const ROCK :int = int.MAX_VALUE;

    public static const DODO :int = 100;
    public static const PANDA :int = 101;
    public static const DINOSAUR :int = 102;
    public static const UNICORN :int = 103;
    public static const NUM_ANIMALS :int = 4;

    public function Board (gameCtrl :GameControl, seaDisplay :SeaDisplay)
    {
        _gameCtrl = gameCtrl;
        _gameCtrl.addEventListener(Event.UNLOAD, shutdown);
        _seaDisplay = seaDisplay;
        _rando = new Random(int(_gameCtrl.net.get("seed")));

        _explode = Sound(new EXPLODE_SOUND());

        var playerIds :Array = _gameCtrl.game.seating.getPlayerIds();
        const playerCount :int = playerIds.length;
        const dimIndex :int = Math.min(DIMENSIONS.length - 1, playerCount);
        _width = int(DIMENSIONS[dimIndex][0]);
        _height = int(DIMENSIONS[dimIndex][1]);

        var x :int;
        var y :int;
        var size :int = _width * _height;
        var ii :int;
        for (ii = size - 1; ii >= 0; ii--) {
            _board[ii] = TREE;
        }

        var pick :int;

        // scatter some clumpy clearings
        var numBlanks :int = size / 100;
        for (ii = 0; ii < numBlanks; ii++) {
            do {
                pick = _rando.nextInt(size);
            } while (_board[pick] != TREE);
            var radius :int = _rando.nextInt(3);
            x = int(pick % _width);
            y = int(pick / _width);
            for (var yy :int = Math.max(0, y - radius); yy <= Math.min(_height - 1, y + radius);
                    yy++) {
                for (var xx :int = Math.max(0, x - radius); xx <= Math.min(_width - 1, x + radius);
                        xx++) {
                    _board[coordsToIdx(xx, yy)] = BLANK;
                }
            }
        }

        // scatter some rocks around
        var numRocks :int = size / 40;
        for (ii = 0; ii < numRocks; ii++) {
            // don't let a rock ever be within 1 tile of another rock, that way we
            // prevent blocked-off areas
            var rocksNearby :Boolean;
            do {
                pick = _rando.nextInt(size);
                rocksNearby = false;
                for (y = -1; y < 2 && !rocksNearby; y++) {
                    for (x = -1; x < 2; x++) {
                        // don't worry about the fact that this may wrap around the board
                        var idx :int = pick + (y * _width) + x;
                        if (idx >= 0 && idx < size && _board[idx] == ROCK) {
                            rocksNearby = true;
                            break;
                        }
                    }
                }
            } while (rocksNearby);
            _board[pick] = ROCK;
        }

        // now draw the board we've created
        _seaDisplay.setupSea(_width, _height, this, _board, _rando);

        // create a submarine for each player
        var sub :Submarine;
        for (ii = 0; ii < playerCount; ii++) {
            var playerId :int = (playerIds[ii] as int);
            var p :Point = getStartingPosition(ii, playerCount);

            sub = new Submarine(
                playerId, ii, _gameCtrl.game.getOccupantName(playerId), p.x, p.y, this, _gameCtrl);
            _gameCtrl.player.getCookie(sub.gotPlayerCookie, playerId);
            _seaDisplay.addChild(sub);
            _subs[ii] = sub;

            // mark this sub's starting location as traversable
            setBlank(p.x, p.y);
        }

        // if we're a player, put our submarine last, so that it
        // shows up always on top of other submarines
        var myIndex :int = gameCtrl.game.seating.getMyPosition();
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

        _gameCtrl.net.addEventListener(MessageReceivedEvent.MESSAGE_RECEIVED, msgReceived);
        if (gameCtrl.game.isInPlay()) {
            // this may happen if we're rematching
            gameDidStart(null);

        } else {
            _gameCtrl.game.addEventListener(StateChangedEvent.GAME_STARTED, gameDidStart);
        }
        _gameCtrl.game.addEventListener(StateChangedEvent.GAME_ENDED, gameDidEnd);
    }

    /**
     * Shutdown this board when it's no longer the active board.
     */
    public function shutdown (... ignored) :void
    {
        _seaDisplay.removeEventListener(Event.ENTER_FRAME, enterFrame);
        _gameCtrl.net.removeEventListener(MessageReceivedEvent.MESSAGE_RECEIVED, msgReceived);
        _gameCtrl.game.removeEventListener(StateChangedEvent.GAME_STARTED, gameDidStart);
        _gameCtrl.game.removeEventListener(StateChangedEvent.GAME_ENDED, gameDidEnd);
    }

    public function playSound (sound :Sound, xx :int, yy :int) :void
    {
        _seaDisplay.playSound(sound, xx, yy);
    }

    public static function isAnimal (tileKind :int) :Boolean
    {
        switch (tileKind) {
        case DODO:
        case PANDA:
        case DINOSAUR:
        case UNICORN:
            return true;

        default:
            return false;
        }
    }

    /**
     * Used only for rendering: is the specified tile one that casts no moss upon the tile
     * below it?
     */
    public function castsMoss (xx :int, yy :int) :Boolean
    {
        if ((xx < 0) || (xx >= _width) || (yy < 0) || (yy >= _height)) {
            return false; // out of bounds
        }
        var val :int = int(_board[coordsToIdx(xx, yy)]);
        return (val == TREE);
        //return (BLANK < val) && (val != DODO) && (val != PANDA);
    }

    /**
     * Is the specified tile blank?
     */
    public function isBlank (xx :int, yy :int) :Boolean
    {
        return (xx >= 0) && (xx < _width) && (yy >= 0) && (yy < _height) &&
            (BLANK == _board[coordsToIdx(xx, yy)]);
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
        return (val == BLANK);
    }

    public function isDestructable (playerIdx :int, xx :int, yy :int) :Boolean
    {
        if (xx < 0 || xx >= _width || yy < 0 || yy >= _height) {
            return false;
        }

        var val :int = int(_board[coordsToIdx(xx, yy)]);
        return (val != BLANK) && (val != ROCK);
    }

    public function showPoints (x :int, y :int, points :int) :void
    {
        new PointsSprite(points, x, y, _seaDisplay);
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

    public function removeTorpedo (torpedo :Torpedo) :void
    {
        // remove it from our list of torpedos
        var idx :int = _torpedos.indexOf(torpedo);
        if (idx == -1) {
            trace("OMG! Unable to find torpedo??");
            return;
        }
        _torpedos.splice(idx, 1); // remove that torpedo
        _seaDisplay.removeChild(torpedo);
    }

    /**
     * Called by a torpedo when it has exploded.
     *
     * @return the number of subs hit by the explosion.
     */
    public function torpedoExploded (torpedo :Torpedo) :int
    {
        removeTorpedo(torpedo);

        var xx :int = torpedo.getX();
        var yy :int = torpedo.getY();
        var killer :Submarine = torpedo.getOwner();
        var killerIdx :int = killer.getPlayerIndex();

        // if it exploded in bounds, make that area traversable
        var subsAffected :Boolean = false;
        var oldVal :int = Board.BLANK;
        if (xx >= 0 && xx < _width && yy >= 0 && yy < _height) {
            // mark the board area as traversable there
            oldVal = int(_board[coordsToIdx(xx, yy)]);
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

                    _gameCtrl.local.feedback(killer.getPlayerName() + " has shot " +
                        sub.getPlayerName());
                }
            }
        }
        if (killCount == 0) {
            // if no subs were affected, play a generic explode
            playSound(_explode, xx, yy);
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
        _seaDisplay.updateTraversable(xx, yy, BLANK, this);
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

        } else if (isAnimal(val)) {
            Submarine(_subs[playerIndex]).animalKilled(xx, yy, getAnimalName(val));
            val = BLANK;

        } else {
            val = BLANK;
        }

        // record the new traversability
        _board[idx] = val;

        // update the display
        _seaDisplay.updateTraversable(xx, yy, val, this);
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
        if (_gameCtrl.game.seating.getMyPosition() == 0) {
            _gameCtrl.services.startTicker("tick", SubAttack.TIME_PER_TICK);
        }
    }

    protected function gameDidEnd (event :StateChangedEvent) :void
    {
        var mydex :int = _gameCtrl.game.seating.getMyPosition();
        if (mydex >= 0) {
            _gameCtrl.player.setCookie(Submarine(_subs[mydex]).getNewCookie());
        }

        _seaDisplay.displayGameOver();
        shutdown();
    }

    /**
     * Handles MessageReceivedEvents.
     */
    protected function msgReceived (event :MessageReceivedEvent) :void
    {
        var name :String = event.name;
        if (name == "tick") {
            _ticks.push([ event.value ]);

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
        var tickId :int = int(array.shift());
        for (var ii :int = 0; ii < array.length; ii += 2) {
            processAction(String(array[ii]), (array[ii + 1] as Array));
        }

        var sub :Submarine;
        var torp :Torpedo;
        // tick all subs and torps
        for each (sub in _subs) {
            sub.tick();
        }
        checkTorpedosPassThroughSubs();

        var torpsCopy :Array = _torpedos.concat();
        for each (torp in torpsCopy) {
            // this may explode a torpedo if it hits seaweed or a wall
            torp.tick();
        }

        // then we check torpedo-on-torpedo action, and pass-through
        checkTorpedos();

        if (tickId < SubAttack.TICKS_PER_GAME) {
            if (tickId % 300 == 0) {
                addAnimal();
            }

        } else if (_gameCtrl.game.seating.getMyPosition() == 0 && !_endedGame) {
            endGame();
            _endedGame = true;
        }
    }

    protected function addAnimal () :void
    {
        var size :int = _width * _height;
        var pick :int = _rando.nextInt(size);
        var origPick :int = pick;
        var kind :int = DODO + _rando.nextInt(NUM_ANIMALS);
        while (_board[pick] != BLANK || areSubsAt(pick)) {
            pick++;
            if (pick >= size) {
                pick = 0;
            }
            if (pick == origPick) {
                return; // couldn't add the animal
            }
        }
        _board[pick] = kind;
        _seaDisplay.updateTraversable(int(pick % _width), int(pick / _width), kind, this);
    }

    /**
     * Helper method for addAnimal.
     */
    protected function areSubsAt (index :int) :Boolean
    {
        var xx :int = int(index % _width);
        var yy :int = int(index / _width);
        for each (var sub :Submarine in _subs) {
            if (!sub.isDead() && sub.getX() == xx && sub.getY() == yy) {
                return true;
            }
        }
        return false;
    }

    protected function endGame () :void
    {
        var ids :Array = [];
        var scores :Array = [];
        for (var ii :int = 0; ii < _subs.length; ii++) {
            var sub :Submarine = _subs[ii] as Submarine;
            ids[ii] = sub.getPlayerId();
            scores[ii] = int(Math.max(0, sub.getPoints()));
        }

        _gameCtrl.game.endGameWithScores(ids, scores, GameSubControl.TO_EACH_THEIR_OWN);
    }

    /**
     * Called after we've ticked subs, but prior to ticking torpedos. See if
     * any of the torpedos will potentially pass through a sub.
     */
    protected function checkTorpedosPassThroughSubs () :void
    {
        var torp :Torpedo;
        var sub :Submarine;
        var exploders :Array = [];
        for each (torp in _torpedos) {
            for each (sub in _subs) {
                if (!sub.isDead() && torp.checkSubPass(sub)) {
                    exploders.push(torp);
                    break; // all we need is to hit one sub..
                }
            }
        }

        // now explode them
        for each (torp in exploders) {
            torp.explode();
        }
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
            var willExplode :Boolean = false;
            xx = torp.getX();
            yy = torp.getY();
            for each (sub in _subs) {
                if (!sub.isDead() && (xx == sub.getX()) && (yy == sub.getY())) {
                    // we have a hit!
                    willExplode = true;
                    if (-1 == exploders.indexOf(torp)) {
                        exploders.push(torp);
                    }
                    break; // break the inner loop (one sub is enough!)
                }
            }

            for each (var torp2 :Torpedo in _torpedos) {
                var checkAdvance :Boolean = !willExplode && (-1 == exploders.indexOf(torp2));
                if (torp != torp2 && torp.willExplode(torp2, checkAdvance)) {
                    willExplode = true;
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

    protected function getAnimalName (kind :int) :String
    {
        switch (kind) {
        case DODO:
            return "dodo";

        case PANDA:
            return "panda";

        case DINOSAUR:
            return "dinosaur";

        case UNICORN:
            return "unicorn";

        default:
            return "Rick Keagy";
        }
    }

    /**
     * Return the starting x coordinate for the specified player.
     */
    protected function getStartingPosition (playerIndex :int, playerCount :int) :Point
    {
        var perc :Number = playerIndex / playerCount; // floating point math, as always in AS
        const maxW :int = _width - 1;
        const maxH :int = _height - 1;

        if (perc < .25) {
            // along the top wall
            perc = perc * 4;
            return new Point(Math.round(perc * maxW), 0);

        } else if (perc < .50) {
            // along the right wall
            perc = (perc - .25) * 4;
            return new Point(maxW, Math.round(perc * maxH));

        } else if (perc < .75) {
            // along the bottom wall
            perc = 1 - ((perc - .50) * 4);
            return new Point(Math.round(perc * maxW), maxH);

        } else {
            // along the left wall
            perc = 1 - ((perc - .75) * 4);
            return new Point(0, Math.round(perc * maxH));
        }
    }

    /** The game Control. */
    protected var _gameCtrl :GameControl;

    /** The 'sea' where everything lives. */
    protected var _seaDisplay :SeaDisplay;

    /** Used for generating random numbers consistently across clients. */
    protected var _rando :Random;

    protected var _explode :Sound;

    /** The width of the board. */
    protected var _width :int;

    /** The height of the board. */
    protected var _height :int;
    
    protected var _ticks :Array = [ [ 0 ] ];

    /** Contains the submarines, indexed by player index. */
    protected var _subs :Array = [];

    /** Contains active torpedos, in no particular order. */
    protected var _torpedos :Array = [];

    /** An array tracking the type of each tile. */
    protected var _board :Array = [];

    /** Have we already ended the game? (Stop trying to do it again while a few
     * last ticks trickle in.) */
    protected var _endedGame :Boolean = false;

    protected static const DIMENSIONS :Array = [
        [  0,  0 ], // 0 player game
        [ 10, 10 ], // 1 player game
//        [ 90, 60], // TEST!
//        [ 10, 10 ], // 2 player game (testing)
        [ 50, 25 ], // 2 player game
        [ 60, 30 ], // 3 player game
        [ 60, 40 ], // 4 player game
        [ 75, 40 ], // 5 player game
        [ 75, 50 ], // 6 player game
        [ 80, 54 ], // 7 player game
        [ 80, 60 ], // 8 players!
        [ 80, 65 ], // 9 players!
        [ 80, 65 ], // 10 players!
        [ 80, 70 ], // 10 players!
        [ 80, 70 ], // 11 players!
        [ 80, 75 ], // 12 players!
        [ 80, 75 ], // 13 players!
        [ 80, 80 ], // 14 players!
        [ 80, 80 ], // 15 players!
        [ 80, 80 ], // 16 players!
        [ 80, 80 ], // 17 players!
        [ 85, 80 ], // 18 players!
        [ 85, 80 ], // 19 players!
        [ 85, 85 ]  // 20 players and up!
    ];

    protected static const MAX_QUEUED_TICKS :int = 5;

    [Embed(source="rsrc/missile_explode.mp3")]
    protected static const EXPLODE_SOUND :Class;
}
}
