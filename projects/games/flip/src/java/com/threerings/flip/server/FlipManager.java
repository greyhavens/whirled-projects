//
// $Id$

package com.threerings.flip.server;

import com.samskivert.util.Interval;
import com.samskivert.util.StringUtil;

import com.samskivert.util.RandomUtil;

import com.threerings.crowd.data.BodyObject;
import com.threerings.crowd.data.PlaceObject;
import com.threerings.crowd.server.CrowdServer;

import com.threerings.parlor.game.server.GameManager;
import com.threerings.parlor.turn.server.TurnGameManager;
import com.threerings.parlor.turn.server.TurnGameManagerDelegate;

import com.threerings.toybox.data.ToyBoxGameConfig;

// import com.threerings.yohoho.roister.server.RatingDelegate;
// import com.threerings.yohoho.roister.server.WagerGameManagerDelegate;

import com.threerings.flip.client.FlipBoardView;
import com.threerings.flip.data.Ball;
import com.threerings.flip.data.BoardObserver;
import com.threerings.flip.data.DropContext;
import com.threerings.flip.data.Flip;
import com.threerings.flip.data.FlipBoard;
import com.threerings.flip.data.FlipCodes;
import com.threerings.flip.data.FlipObject;

import static com.threerings.flip.Log.log;

/**
 * Manages the server-side of a game of Flip.
 */
public class FlipManager extends GameManager
    implements TurnGameManager, FlipCodes
{
    /**
     * Constructor.
     */
    public FlipManager ()
    {
        addDelegate(_turnDelegate = new TurnGameManagerDelegate(this));
//         addDelegate(new WagerGameManagerDelegate(this));
//         addDelegate(new RatingDelegate(this));
    }

    /**
     * Called by the client when they want to make a move.
     */
    public void drop (BodyObject caller, short turnId, byte slot)
    {
        if (_turnPlayed) {
            log.fine("Got drop request when turn was already played! [who=" + caller.who() + "].");
            return;
        }

        if (!_flipObj.isInPlay()) {
            log.fine("Received drop request while not in play! [who=" + caller.who() + "].");
            return;
        }

        int pidx = _turnDelegate.getTurnHolderIndex();
        if (_playerOids[pidx] != caller.getOid()) {
            log.fine("Received drop request from non-turn holder! [who=" + caller.who() + "].");
            return;
        }

        if (turnId != _flipObj.turnId) {
            // don't log a warning
            return;
        }

        if (slot < 0 || slot > _flipObj.topSlots) {
            log.fine("Received bogus drop slot! [who=" + caller.who() + ", slot=" + slot + "].");
            return;
        }

        _turnTimeout.cancel();
        doDrop(slot);
    }

    // documentation inherited
    protected PlaceObject createPlaceObject ()
    {
        return new FlipObject();
    }

    // documentation inherited
    protected void didInit ()
    {
        super.didInit();

        ToyBoxGameConfig config = (ToyBoxGameConfig)_config;
        _holes = (Boolean)config.params.get("holes");
        _speedy = (Boolean)config.params.get("speedy");
//         _wagerPerDrop = (Boolean)config.params.get("wagerPerDrop");
    }

    // documentation inherited
    public void didStartup ()
    {
        super.didStartup();

        // grab a casted reference to our own game object
        _flipObj = (FlipObject) _gameobj;

        // put some of our configuration parameters into the game object
        ToyBoxGameConfig config = (ToyBoxGameConfig)_config;
        _flipObj.startTransaction();
        try {
            _flipObj.setTopSlots(
                Integer.parseInt((String)config.params.get("topSlots")));
            _flipObj.setPointStructure(
                Integer.parseInt((String)config.params.get("pointStructure")));
            _flipObj.setMoveTimeout(
                Integer.parseInt((String)config.params.get("timePerTurn")));
        } finally {
            _flipObj.commitTransaction();
        }
    }

    // documentation inherited
    protected void gameWillStart ()
    {
        super.gameWillStart();

        // initialize the board
        _flipObj.startTransaction();
        try {
            _flipObj.setScores(new int[2][ROUNDS]);
            _flipObj.setRoundId(0);
            _flipObj.setBoard(new FlipBoard(_flipObj.topSlots, _holes ? 3 : 0, RandomUtil.rand));

            // and wire the flip object to the board
            _flipObj.board.setFlipObject(_flipObj);
            _flipObj.board.setObserver(new BoardTimeObserver());

        } finally {
            _flipObj.commitTransaction();
        }
    }

    // documentation inherited
    public void endGame ()
    {
        _turnStarter.cancel();
        _turnTimeout.cancel();
        super.endGame();
        _flipObj.setTurnHolder(null);
    }

    // documentation inherited
    public void endPlayerGame (int pidx)
    {
        _leaverIdx = pidx;
        super.endPlayerGame(pidx);
    }

    /**
     * Process a correctly formed drop request.
     */
    protected void doDrop (int slot)
    {
        _turnPlayed = true;
        _flipObj.addBall(slot);
    }

    /**
     * Possibly start the next turn, unless we decide to instead end
     * the game.
     */
    protected void maybeStartNextTurn ()
    {
        _flipObj.startTransaction();
        try {
            // we end if we're past the last round
            if (_flipObj.roundId == ROUNDS) {
                endGame();

            } else {
                _flipObj.setTurnId((short) (_flipObj.turnId + 1));
                _turnDelegate.endTurn();
                _turnPlayed = false;

                // do some extra kooky stuff if we're playing wager-per-drop
                if (_wagerPerDrop && _flipObj.turnId >= 2) {
                    increasePerDropWager();
                }
            }

        } finally {
            _flipObj.commitTransaction();
        }
    }

    /**
     * Called when we should increase the wager of the active player in a per-drop game.
     */
    protected void increasePerDropWager ()
    {
        /*
        // we need increase the new player's wager
        int tidx = _turnDelegate.getTurnHolderIndex();
        int eights = _flipConfig.protoWager.eights;
        Wager[] wagers = _flipObj.getWagers();
        Wager w = wagers[tidx];
        boolean secondPass = false;
        while (!w.source.increaseDebt(w, eights)) {
            if (!_warnedBroke[tidx]) {
                systemMessage(FLIP_MESSAGE_BUNDLE, MessageBundle.tcompose(
                        "m.cant_increase_wager", getPlayerName(tidx)));
                _warnedBroke[tidx] = true;
            }

            // we were unable to increase the player's debt
            // if he is behind here, he automatically loses
            int oidx = 1 - tidx;
            if (secondPass ||
                    (_flipObj.getScore(tidx) < _flipObj.getScore(oidx))) {
                // if both player's can't pay, or just leader
                // can pay, end the game.
                endGame();
                return;

            } else {
                // do a fake drop so that normal round checking happens
                _flipObj.addBall(-1);
                if (_flipObj.round == ROUNDS) {
                    endGame();
                    return;

                } else {
                    // make it the other guy's turn
                    _turnDelegate.endTurn();
                    tidx = oidx;
                    w = wagers[tidx];
                }
            }
            secondPass = true;
        }

        // refresh the wagers
        _flipObj.setWagers(wagers);
        */
    }

    // documentation inherited from interface TurnGameManager
    public void turnWillStart ()
    {
        // nada
    }

    // documentation inherited from interface TurnGameManager
    public void turnDidStart ()
    {
        int secs = _flipObj.moveTimeout;
        if (secs > 0) {
            _turnTimeout.schedule(secs * 1000L);
        }
    }

    // documentation inherited from interface TurnGameManager
    public void turnDidEnd ()
    {
        // nada
    }

    // documentation inherited
    protected void assignWinners (boolean[] winners)
    {
        log.info("Flip game ended: earlyLeaver=" + _leaverIdx +
                 ", pointStruct=" + _flipObj.pointStructure +
                 ", p0=" + StringUtil.toString(_flipObj.scores[0]) +
                 ", p1=" + StringUtil.toString(_flipObj.scores[1]));

        if (_leaverIdx != -1) {
            winners[1 - _leaverIdx] = true;
            return;
        }

        int p0 = _flipObj.getScore(0);
        int p1 = _flipObj.getScore(1);
        int max = Math.max(p0, p1);
        if (p0 == max) {
            winners[0] = true;
        }
        if (p1 == max) {
            winners[1] = true;
        }
    }

    protected class BoardTimeObserver
        implements BoardObserver
    {
        public void newBoard () {}
        public void addHoles (int numAdd, int numRemove, long seed) {
            _flipObj.board.addHoles(numAdd, numRemove, seed);
        }
        public void configureFlip (Flip flip, int flipIdx) {}
        public void flipFlipped (Flip flip, int times) {}
        public void ballAdded (Ball ball) {}
        public void ballUpdated (Ball ball) {}
        public void ballRemoved (Ball ball, int pidx, boolean scored) {}
        public void evolveStarted (DropContext ctx, int pidx) {
            _duration = 0;
            _ctx = ctx;
            _ctx.evolveDrop();
        }
        public void nowWaiting () {
            // always add 50ms, plus the actual duration
            _duration += 50 + (FlipBoardView.DURATION / (_speedy ? 5 : 1));
            _ctx.evolveDrop();
        }
        public void evolveFinished (int pidx, boolean roundEnded) {
            // don't react to empty drops
            if (_duration > 0) {
                // add an extra 2 seconds if this finishes the round
                if (roundEnded) {
                    _duration += 2000;
                }

                // possibly add some holes to the board
                if (roundEnded && _holes && _flipObj.roundId < 4) {
                    new Interval(CrowdServer.omgr) {
                        public void expired () {
                            // remove one hole, add two more
                            _flipObj.addHoles(2, 1);
                        }
                    }.schedule(_duration);
                }

                // start the next turn
                if (_duration > 1) {
                    _turnStarter.schedule(_duration);
                } else {
                    maybeStartNextTurn();
                }
            }
        }

        protected long _duration;
        protected DropContext _ctx;
    };

    /** Whether we're in "wager per drop" mode (disabled). */
    protected boolean _wagerPerDrop;

    /** Whether or not to place holes on the board. */
    protected boolean _holes;

    /** Whether or not we're configured to play in turbo mode. */
    protected boolean _speedy;

    /** The game object. */
    protected FlipObject _flipObj;

    /** Set to true when we've already warned that a particular player is broke. */
    protected boolean[] _warnedBroke = new boolean[2];

    /** If not -1, the index of the player that left early. */
    protected int _leaverIdx = -1;

    /** Since we don't change the turn immediately when a turn is received we set this to indicate
     * that the turn has already been played. */
    protected boolean _turnPlayed;

    /** The delegate responsible for managing turns. */
    protected TurnGameManagerDelegate _turnDelegate;

    /** An interval to timeout the current player and move for them. */
    protected Interval _turnTimeout = new Interval(CrowdServer.omgr) {
        public void expired () {
            doDrop(RandomUtil.getInt(_flipObj.topSlots));
        }
    };

    protected Interval _turnStarter = new Interval(CrowdServer.omgr) {
        public void expired () {
            maybeStartNextTurn();
        }
    };
}
