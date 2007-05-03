//
// $Id$

package com.threerings.flip.client;

import java.awt.Color;
import java.awt.Dimension;
import java.awt.EventQueue;
import java.awt.Font;
import java.awt.Graphics2D;
import java.awt.Point;
import java.awt.Rectangle;

import java.util.HashMap;
import java.util.Iterator;
import java.util.LinkedList;

import com.samskivert.swing.Label;

import com.samskivert.util.Interval;
import com.samskivert.util.IntListUtil;

import com.threerings.util.DirectionCodes;
import com.threerings.util.MessageBundle;
import com.samskivert.util.RandomUtil;

import com.threerings.presents.dobj.AttributeChangedEvent;
import com.threerings.presents.dobj.AttributeChangeListener;

import com.threerings.crowd.client.PlaceView;
import com.threerings.crowd.data.PlaceObject;

import com.threerings.media.MediaPanel;
import com.threerings.media.animation.FadeImageAnimation;
import com.threerings.media.animation.SparkAnimation;
import com.threerings.media.image.Mirage;
import com.threerings.media.sound.SoundCodes;
import com.threerings.media.sprite.ImageSprite;
import com.threerings.media.sprite.PathObserver;
import com.threerings.media.sprite.Sprite;
import com.threerings.media.tile.TileMultiFrameImage;
import com.threerings.media.tile.TileSet;
import com.threerings.media.util.ArcPath;
import com.threerings.media.util.LinePath;
import com.threerings.media.util.LineSegmentPath;
import com.threerings.media.util.MultiFrameImage;
import com.threerings.media.util.Path;
import com.threerings.media.util.PathSequence;
import com.threerings.media.util.SingleFrameImageImpl;

import com.threerings.parlor.media.ScoreAnimation;

import com.threerings.toybox.data.ToyBoxGameConfig;
import com.whirled.util.WhirledContext;

import com.threerings.flip.data.Ball;
import com.threerings.flip.data.BoardObserver;
import com.threerings.flip.data.DropContext;
import com.threerings.flip.data.Flip;
import com.threerings.flip.data.FlipCodes;
import com.threerings.flip.data.FlipObject;
import com.threerings.flip.data.Slot;

/**
 * The view of the FlipBoard that is displayed for occupants of the room.
 */
public class FlipBoardView extends MediaPanel
    implements PlaceView, BoardObserver, FlipCodes
{
    /**
     * Create the board view.
     */
    public FlipBoardView (WhirledContext ctx, FlipController ctrl)
    {
        super(ctx.getFrameManager());
        _ctx = ctx;
        _ctrl = ctrl;
        _msgs = ctx.getMessageManager().getBundle(FLIP_MESSAGE_BUNDLE);
        _evolveWaiter = new EvolveWaiter();

        // load media
        _flipImage = new TileMultiFrameImage(
            _ctx.getTileManager().loadTileSet("images/flip.png", 46, 52));
        _ballImage = new TileMultiFrameImage(
            _ctx.getTileManager().loadTileSet("images/ball.png", 20, 19));
        _holeImage = new SingleFrameImageImpl(
            _ctx.getImageManager().getMirage("images/hole.png"));
        TileSet set = _ctx.getTileManager().loadTileSet("images/sparkles.png", 20, 20);
        _sparkles[0] = set.getTileMirage(0);
        _sparkles[1] = set.getTileMirage(1);
        set = _ctx.getTileManager().loadTileSet("images/chest.png", 55, 60);
        _chest[0] = set.getTileMirage(0);
        _chest[1] = set.getTileMirage(1);
        Mirage coinPile = _ctx.getImageManager().getMirage("images/coin_pile.png");
        for (int ii=0; ii < 2; ii++) {
            _coinPiles[ii] = new CoinPileSprite((ii == 0) ? 20 : 408, 229, coinPile);
            _coinPiles[ii].setRenderOrder(1);
            addSprite(_coinPiles[ii]);
        }

        _pointValueFont = SMALL_FONT.deriveFont(Font.BOLD);

        // create the round label
        _roundLabel = new Label("", Label.OUTLINE, Color.WHITE, Color.BLACK, SMALL_FONT);

        // se if we're speedy-mode
        _speedy = (Boolean)((ToyBoxGameConfig) ctrl.getPlaceConfig()).params.get("speedy");

        // an interval to play the turn warning sound
        _turnWarningInterval = new Interval(ctx.getClient().getRunQueue()) {
            public void expired () {
                _ctx.getSoundManager().play(
                    SoundCodes.GAME_ALERT, FlipSounds.PACKAGE_PATH, FlipSounds.YOUR_TURN);
            }
        };
    }

    protected void init ()
    {
        String bgfile = (_flipObj.topSlots == 8) ? "background" : "bg" + _flipObj.topSlots;
        _background = _ctx.getImageManager().getMirage("images/" + bgfile + ".png");

        _xDim = (_flipObj.topSlots == 10) ? 23 : 26;
        _bottomSlots = _flipObj.topSlots + 2 * (FlipCodes.HEIGHT-1);

        // create some sprites
        MultiFrameImage laneImage = new TileMultiFrameImage(
            _ctx.getTileManager().loadTileSet("images/lane.png", 26, 61));
        _dropFeedback = new BallSprite(_ballImage);
        _lanes = new LaneSprite[_flipObj.topSlots];
        for (int ii=0; ii < _lanes.length; ii++) {
            _lanes[ii] = new LaneSprite(laneImage, ii, this);
            // magic numbers to make the layout right
            _lanes[ii].setLocation(X_OFS + (4 + ii) * _xDim,
                Y_OFS - 20);
            addSprite(_lanes[ii]);
        }

        _playerViews = new PlayerScoreView[2];
        for (int ii=0; ii < 2; ii++) {
            int x = (ii == 0) ? 4 : 350;
            _playerViews[ii] = new PlayerScoreView(
                _ctx, this, _flipObj.moveTimeout * 1000L, ii, x, 3);
            _playerViews[ii].willEnterPlace(_flipObj);
        }

        updateRoundLabel();

        // set the coin piles to the correct values
        if (_flipObj.state == FlipObject.GAME_OVER) {
            int s0 = _flipObj.getScore(0);
            int s1 = _flipObj.getScore(1);
            int max = Math.max(s0, s1);
            _coinPiles[0].jumpPoints(s0, max);
            _coinPiles[1].jumpPoints(s1, max);

        } else if (_flipObj.scores != null) {
            int round = _flipObj.roundId;
            int target = POINT_TARGETS[round];
            _coinPiles[0].jumpPoints(_flipObj.scores[0][round], target);
            _coinPiles[1].jumpPoints(_flipObj.scores[1][round], target);
        }

        _ctx.getSoundManager().lock(FlipSounds.PACKAGE_PATH, FlipSounds.LOCK_KEYS);

        repaint();
    }

    /**
     * Play a sound.
     */
    public void playSound (String key)
    {
        _ctx.getSoundManager().play(SoundCodes.GAME_FX, FlipSounds.PACKAGE_PATH, key);
    }

    /**
     * Callback from a lane sprite when it's being hovered over.
     */
    protected void laneHovered (int idx, boolean hov)
    {
        _hoverLane = hov ? idx : -1;
        if (_ctrl.waitingForOurTurn()) {
            checkLaneHover();
        }
    }

    /**
     * Check to see which lane we should highlight.
     */
    protected void checkLaneHover ()
    {
        boolean showing = isManaged(_dropFeedback);
        if (_hoverLane >= 0) {
            Point p = computeBallLocation(2 * (_hoverLane + 4), 0);
            _dropFeedback.setRotatingQuickly(false);
            _dropFeedback.setLocation(p.x, p.y);
            if (!showing) {
                addSprite(_dropFeedback);
            }
        } else {
            if (showing) {
                removeSprite(_dropFeedback);
            }
        }
    }

    /**
     * Have the specified ball drop a sparkle on the game board.
     */
    protected void dropSparkle (BallSprite sprite)
    {
        dropSparkle(sprite.getX(), sprite.getY(), Math.max(1, sprite._additional));
    }

    /**
     * Drop a sparkle.
     *
     * @param brightness at least 1, more to have the sparkle last longer
     */
    protected void dropSparkle (int x, int y, int brightness)
    {
        long dur = (_duration == 0) ? (DURATION / 5) : _duration;
        FadeImageAnimation fia = new FadeImageAnimation(
            _sparkles[RandomUtil.getInt(2)], x, y, brightness, -.8f / (2 * dur), .2f);
        fia.setRenderOrder(-1);
        addAnimation(fia);
    }

    /**
     * Called by the controlled to when the turn changes to our turn.
     */
    public void setOurTurn (int idx)
    {
        int start, inc, stop;
        if (idx == 0) {
            start = _lanes.length - 1; inc = -1; stop = -1;
        } else if (idx == 1) {
            start = 0; inc = 1; stop = _flipObj.topSlots;
        } else {
            return;
        }

        int dex = 0;
        for (int ii=start; ii != stop; ii += inc, dex++) {
            _lanes[ii].flash(dex * 300, 250, 10500);
        }
        checkLaneHover();

        // schedule the warning sound
        _turnWarningInterval.schedule(FlipSounds.turnSoundDelay(_flipObj.moveTimeout * 1000));
    }

    /**
     * Called after we have submitted a move to the server.
     */
    public void moveSubmitted ()
    {
        _turnWarningInterval.cancel();
        _dropFeedback.setRotatingQuickly(true);
        stopLanes();
    }

    /**
     * Stop the laned from doing their little animation.
     */
    protected void stopLanes ()
    {
        for (int ii=0; ii < _flipObj.topSlots; ii++) {
            _lanes[ii].stop();
        }
    }

    // documentation inherited from interface PlaceView
    public void willEnterPlace (PlaceObject plobj)
    {
        _flipObj = (FlipObject) plobj;

        if (_flipObj.topSlots != 0) {
            init();
        }

        _flipObj.setObserver(this);
        _flipObj.addListener(_listener);
    }

    // documentation inherited from interface PlaceView
    public void didLeavePlace (PlaceObject plobj)
    {
        _ctx.getSoundManager().unlock(FlipSounds.PACKAGE_PATH, FlipSounds.LOCK_KEYS);

        _flipObj.setObserver(null);
        _flipObj.removeListener(_listener);

        for (int ii=0; ii < _playerViews.length; ii++) {
            _playerViews[ii].didLeavePlace(_flipObj);
        }
        _playerViews = null;

        _flipObj = null;
    }

    // documentation inherited from interface BoardObserver
    public void newBoard ()
    {
        // clean everything up
        clearSprites(_flipSprites);
        clearSprites(_ballSprites);
        clearSprites(_holeSprites);
    }

    // documentation inherited from interface BoardObserver
    public void addHoles (int numAdd, int numRemove, long seed)
    {
        _evolveWaiter.addHoles(numAdd, numRemove, seed);
    }

    /**
     * Update the text of the round label.
     */
    protected void updateRoundLabel ()
    {
        dirtyScreenRect(new Rectangle(_roundLoc, _roundLabel.getSize()));
        boolean inPlay = (_flipObj.roundId < ROUNDS) &&
            (_flipObj.isInPlay() || _flipObj.state == FlipObject.PRE_GAME);
        String msg = inPlay ? _msgs.get("m.round", String.valueOf(_flipObj.roundId + 1)) :
            _msgs.get("m.game_over");
        if (!inPlay) {
            _roundLabel.setFont(BIG_FONT);
        }
        _roundLabel.setText(msg);
        doRoundLabelLayout();
    }

    /**
     * Do the layout of the round label.
     */
    protected void doRoundLabelLayout ()
    {
        _roundLabel.layout(this);
        if (_roundLabel.isLaidOut()) {
            Dimension size = _roundLabel.getSize();
            _roundLoc.x = (getWidth() - size.width) / 2;
            dirtyScreenRect(new Rectangle(_roundLoc, size));
        }
    }

    /**
     * Clear out all the sprites in the supplied map, and clear the map.
     */
    protected <T extends Sprite> void clearSprites (HashMap<?,T> sprites)
    {
        for (Iterator<T> itr = sprites.values().iterator(); itr.hasNext(); ) {
            Sprite s = itr.next();
            removeSprite(s);
        }
        sprites.clear();
    }
 
    // documentation inherited from interface BoardObserver
    public void configureFlip (Flip flip, int flipIdx)
    {
        FlipSprite sprite = new FlipSprite(_flipImage, flip, this);
        _flipSprites.put(flip, sprite);

        int height;
        for (height = 0; height < FlipCodes.HEIGHT; height++) {
            int flipsOnRow = _flipObj.topSlots/2 + height;
            if (flipIdx < flipsOnRow) {
                break;
            }
            flipIdx -= flipsOnRow;
        }

        int x = (FlipCodes.HEIGHT - 1 - height) + (flipIdx * 2);
        int y = (height * 4) + 3;

        sprite.setLocation(X_OFS + 3 + x * _xDim, Y_OFS - 8 + y * Y_DIM);
        addSprite(sprite);

        // maybe add some holes
        maybeAddHole(flip.left);
        maybeAddHole(flip.right);
    }

    /**
     * Possibly add a hole sprite for the specified slot.
     */
    protected void maybeAddHole (Slot slot)
    {
        if (slot.hole && !_holeSprites.containsKey(slot)) {
            ImageSprite sprite = new ImageSprite(_holeImage);
            Point p = computeBallLocation(slot.x, slot.y);
            sprite.setLocation(p.x, p.y + Y_DIM);
            sprite.setRenderOrder(-1);
            addSprite(sprite);
            _holeSprites.put(slot, sprite);
        }
    }

    // documentation inherited from interface BoardObserver
    public void flipFlipped (Flip flip, int times)
    {
        FlipSprite sprite = _flipSprites.get(flip);
        sprite.didFlip(times);
    }

    /**
     * Compute the location of the specified ball.
     */
    protected Point computeBallLocation (Ball ball)
    {
        return computeBallLocation(ball.x, ball.y);
    }

    /**
     * Compute the location of the specified ball.
     */
    protected Point computeBallLocation (int ballx, int bally)
    {
        Point p = new Point(X_OFS + 4 + (ballx / 2) * _xDim, Y_OFS + 3 + bally * Y_DIM);
        if (ballx % 2 == 1) {
            p.x += _xDim/2;
        }
        return p;
    }

    // documentation inherited from interface BoardObserver
    public void ballAdded (Ball ball)
    {
        BallSprite sprite = new BallSprite(_ballImage, ball, this);
        sprite.addSpriteObserver(_evolveWaiter);
        _ballSprites.put(ball, sprite);

        Point p = computeBallLocation(ball);
        sprite.setLocation(p.x, p.y);
        addSprite(sprite);

        // see if the ball is resting (when a ball is added from a split)
        if (_evolveWaiter.isEvolving()) {
            checkResting(ball, sprite, true);
        }
    }

    // documentation inherited from interface BoardObserver
    public void ballUpdated (Ball ball)
    {
        BallSprite sprite = _ballSprites.get(ball);
        sprite.updated(ball);

        Point p = computeBallLocation(ball);
        int ox = sprite.getX();
        int oy = sprite.getY();
        if (oy != p.y || ox != p.x) {
            Path path = null;
            if (ball.warping) {
                if (_duration > 0) {
                    LinePath wait1 = new LinePath(ox, oy, ox, oy, _duration/2);
                    LinePath wait2 = new LinePath(p.x, p.y, p.x, p.y, _duration/2);
                    path = new PathSequence(wait1, wait2);
                }

            } else if (oy > p.y) { // we're popping up
                playSound(FlipSounds.BALL_POPUP);
                if (_duration > 0) {
                    long waitDur = FlipSprite.initialDelay(_duration);
                    LinePath wait = new LinePath(ox, oy, ox, oy, waitDur);
                    LinePath basicPath = new LinePath(p, _duration - waitDur);
                    path = new PathSequence(wait, basicPath);
                }

            } else if (oy != p.y && ox != p.x && (ball.x % 2 == 1)) {
                // ball is hitting another ball, arc it over to the other side
                playSound(FlipSounds.BALL_PASS);
                if (_duration > 0) {
                    double initialTheta = 3*Math.PI/2;
                    double delta = ((ox > p.x) ? -1 : 1) * Math.PI/2;
                    int ballhei = _ballImage.getHeight(0);
                    int fallhei = Y_DIM - ballhei;
                    p.x = ox;
                    p.y = oy + fallhei;
                    long falldur = (long) (_duration * (fallhei / (float)Y_DIM));
                    LinePath fall = new LinePath(p, falldur);
                    ArcPath arc = new ArcPath(
                        p, 3 * _xDim / 4, ballhei, initialTheta, delta, _duration - falldur,
                        DirectionCodes.NORTH);
                    path = new PathSequence(fall, arc);
                }

            } else if (_duration > 0) {
                // normal progress downward
                path = new LinePath(p, _duration);
            }

            if (_duration == 0) {
                sprite.setLocation(p.x, p.y);

            } else {
                _evolveWaiter.pathAdded();
                sprite.move(path);
            }

        } else {
            checkResting(ball, sprite, false);
        }
    }

    /**
     * Check if the ball is now resting.
     */
    protected void checkResting (Ball ball, BallSprite sprite, boolean fromSplit)
    {
        if (ball.isResting()) {
            if (_duration > 0) {
                int ox = sprite.getX();
                int oy = sprite.getY();
                LineSegmentPath jig = new LineSegmentPath(ox, oy + 1, ox, oy);
                jig.setDuration(_duration / 5);
                // we do not indicate to the waiter that a path was added as this path is just "for
                // show" (and it will ignore it when it completes)
                sprite.move(jig);
            }
            playSound(fromSplit ? FlipSounds.BALL_SPLIT : FlipSounds.BALL_LAND);
        }
    }

    // documentation inherited from interface BoardObserver
    public void ballRemoved (Ball ball, int pidx, boolean scored)
    {
        BallSprite sprite = _ballSprites.remove(ball);
        if (scored) {
            playSound(FlipSounds.BALL_SCORED);
            dropSparkle(sprite);
            _playerViews[pidx].checkLabels();
            int round = _flipObj.roundId;
            _coinPiles[pidx].setPoints(_flipObj.scores[pidx][round], POINT_TARGETS[round], null);
//             if (_flipObj.isInPlay()) {
//                 _playerViews[pidx].setAction(YoFaceIcon.HAPPY);
//             }
        }
        removeSprite(sprite);
    }

    // documentation inherited from interface BoardObserver
    public void evolveStarted (DropContext ctx, int pidx)
    {
        _turnWarningInterval.cancel();
        stopLanes();
        _playerViews[pidx].hideTimer();
        if (isManaged(_dropFeedback)) {
            removeSprite(_dropFeedback);
        }
        _evolveWaiter.addDropContext(ctx);
    }

    // documentation inherited from interface BoardObserver
    public void nowWaiting ()
    {
        // if we're not animating anything, then we need to manually proceed to the next step
        if (_duration == 0) {
            _evolveWaiter.evolveSoon();
        }
    }

    // documentation inherited from interface BoardObserver
    public void evolveFinished (final int pidx, boolean roundEnded)
    {
//         // turn off any smiles after 2 secs
//         new Interval(_ctx.getClient().getRunQueue()) {
//             public void expired () {
//                 // only if we're still in play, if the game is over, leave at
//                 // crying/smiling/whatever
//                 if (_flipObj != null && _flipObj.isInPlay()) {
//                     _playerViews[pidx].setAction(YoFaceIcon.NORMAL);
//                 }
//             }
//         }.schedule(2000);

        if (roundEnded && (_flipObj.roundId < ROUNDS)) {
            roundStarted();
        }

        _evolveWaiter.processNext();
    }

    /**
     * A callback from our evolvewaiter.
     */
    protected void allEvolvesFinished ()
    {
        if (!_flipObj.isInPlay() && _flipObj.getWinnerCount() > 0) {
            displayGameOver();
        }
    }

    /**
     * Display game over stuff.
     */
    protected void displayGameOver ()
    {
        updateRoundLabel();
        for (int ii=0; ii < _playerViews.length; ii++) {
            _playerViews[ii].checkLabels();
        }

        int[] scores = new int[2];
        for (int ii=0; ii < 2; ii++) {
            scores[ii] = _flipObj.getScore(ii);
            _coinPiles[ii].clear();
        }
        int max = Math.max(scores[0], scores[1]);

        boolean calledback = false;
        for (int ii=0; ii < 2; ii++) {
            FlipBoardView cb = null;
            // make sure only one of them calls back to us
            if (!calledback && scores[ii] == max) {
                cb = this;
                calledback = true;
            }
            _coinPiles[ii].setPoints(scores[ii], max, cb);
        }
    }

    /**
     * Called from the coinpile when it's gotten all the way to the top at the end of the game.
     */
    public void openChest ()
    {
        final boolean[] winners = _flipObj.winners;
        TileSet set = _ctx.getTileManager().loadTileSet("images/sparks.png", 9, 9);
        int count = set.getTileCount();
        Mirage[] sparks = new Mirage[count];
        for (int ii=0; ii < count; ii++) {
            sparks[ii] = set.getTileMirage(ii);
        }

        for (int ii=0; ii < winners.length; ii++) {
            if (!winners[ii]) {
                continue;
            }

            Rectangle chest = new Rectangle(
                CHEST_X[ii], CHEST_Y, _chest[1].getWidth(), _chest[1].getHeight());
            // we don't actually need to dirty the chest area, cuz the animation does it for us

            // splash between 10 and 20 sparks depending on the score
            int score = _flipObj.getScore(ii);
            float minScore = IntListUtil.sum(POINT_TARGETS);
            int sparkCount = 10 +
                Math.max(0, Math.min(10, 10 * (Math.round(score / minScore) - 1)));
            Mirage[] mySparks = new Mirage[sparkCount + 2];
            for (int jj=0; jj < sparkCount; jj++) {
                mySparks[jj] = sparks[RandomUtil.getInt(count)];
            }
            for (int jj=sparkCount; jj < sparkCount + 2; jj++) {
                mySparks[jj] = _sparkles[jj - sparkCount];
            }
            chest.grow(100, 40);
            SparkAnimation anim = new SparkAnimation(
                chest, chest.x + chest.width/2, chest.y + chest.height/3, 0, 0,
                -.1f, .01f, .1f, .04f, 0f, .00005f, mySparks, 2000, true);
            anim.setRenderOrder(20);
            addAnimation(anim);
        }

        // play the chest open sound (at least one does, right?)
        playSound(FlipSounds.CHEST_OPEN);

        // play the other sound and show the winner label
        new Interval(_ctx.getClient().getRunQueue()) {
            public void expired () {
                if (_flipObj == null) {
                    // the user must have closed the flip panel.
                    return;
                }

                // display a score animation announcing the winner
                String winMsg;
                if (_flipObj.isDraw()) {
                    winMsg = "m.tie";

                } else {
                    winMsg = MessageBundle.tcompose(
                        "m.won", _flipObj.players[_flipObj.getWinnerIndex()]);
                }
                addScoreAnimation(winMsg);

                // if we were involved, play a win or lose sound
                int pidx = _flipObj.getPlayerIndex(_ctx.getUsername());
                if (pidx != -1) {
                    playSound(_flipObj.isWinner(pidx) ?
                              FlipSounds.YE_WIN : FlipSounds.YE_LOSE);
                }
            }
        }.schedule(1552); // approx duration of chest_open
    }

    /**
     * Called when a round is started.
     */
    public void roundStarted ()
    {
        // update the score views
        _playerViews[0].checkLabels();
        _playerViews[1].checkLabels();
        _coinPiles[0].clear();
        _coinPiles[1].clear();

        updateRoundLabel();

        addScoreAnimation(MessageBundle.tcompose("m.round", String.valueOf(_flipObj.roundId + 1)));

        // on the transitions to the later rounds, make a big show of changing the score values
        if (_flipObj.roundId > 0) {
            _scoreLabelSeq = _bottomSlots/2;
            new Interval(_ctx.getClient().getRunQueue()) {
                public void expired () {
                    _scoreLabelSeq--;

                    int oldPoint = _flipObj.getBucketValue(_scoreLabelSeq, true);
                    Label label = new Label(
                        String.valueOf(oldPoint), Label.OUTLINE, SCORE_INNER_COLOR,
                        SCORE_OUTER_COLOR, _pointValueFont);
                    Dimension d = label.getSize();
                    int y = Y_OFS + ((4 * FlipCodes.HEIGHT + 2) * Y_DIM);
                    for (int ii=0; ii < 2; ii++) {
                        int x = (ii == 0) ?
                            _scoreLabelSeq :  (_bottomSlots-1) - _scoreLabelSeq;
                        x = X_OFS + (x * _xDim);
                        // dirty the whole region (the animations aren't big enough)
                        dirtyScreenRect(new Rectangle(x, y, _xDim, Y_DIM));

                        // then add a sparkle and floating text...
                        dropSparkle(x, y, 1);
                        label.layout(FlipBoardView.this);
                        addAnimation(new ScoreAnimation(
                                         label, x + (_xDim - d.width) / 2,
                                         y + (Y_DIM - d.height) / 2, 1000));
                    }

                    // cancel this interval when we're done
                    if (_scoreLabelSeq == 0) {
                        cancel();
                    }
                }
            }.schedule(300, true);
        }
    }

    /**
     * Add a score animation.
     */
    protected void addScoreAnimation (String msg)
    {
        // create and configure the label
        Label label = new Label(_ctx.xlate(FLIP_MESSAGE_BUNDLE, msg));
        label.setTargetWidth(getWidth());
        label.setStyle(Label.OUTLINE);
        label.setTextColor(Color.WHITE);
        label.setAlternateColor(Color.BLACK);
        label.setFont(HUGE_FONT);
        label.setAlignment(Label.CENTER);
        label.layout(this);

        // create the score animation
        int x = (getWidth() - label.getSize().width)/2, y = getHeight()/2;
        addAnimation(new ScoreAnimation(label, x, y, 2000));
    }

    // documentation inherited
    protected void paintBehind (Graphics2D gfx, Rectangle dirty)
    {
        if (_background == null) {
            return;
        }
        Rectangle r = new Rectangle(dirty);
        r = r.union(new Rectangle(
                        _background.getWidth(), _background.getHeight(),
                        getWidth() - _background.getWidth(),
                        getHeight() - _background.getHeight()));
        gfx.setColor(getBackground());
        gfx.fill(r);

        // paint the background
        _background.paint(gfx, 0, 0);

        super.paintBehind(gfx, dirty);

        if (!_roundLabel.isLaidOut()) {
            doRoundLabelLayout();
        }
        _roundLabel.render(gfx, _roundLoc.x, _roundLoc.y);

        // draw the player status views
        if (_playerViews != null) {
            for (int ii=0; ii < _playerViews.length; ii++) {
                _playerViews[ii].render(gfx);
            }
        }

        // paint the bucket score values
        int y = Y_OFS + ((4 * FlipCodes.HEIGHT) + 2) * Y_DIM;
        int x = X_OFS;
        Label label = new Label(
            "", Label.OUTLINE, SCORE_INNER_COLOR, SCORE_OUTER_COLOR, _pointValueFont);
        Dimension d;
        for (int ii = 0; ii < _bottomSlots; ii++) {
            boolean lastRound;
            if (ii < _bottomSlots/2) {
                lastRound = ii < _scoreLabelSeq;
            } else {
                lastRound = ((_bottomSlots - 1) - ii) < _scoreLabelSeq;
            }

            String s = String.valueOf(_flipObj.getBucketValue(ii, lastRound));
            label.setText(s);
            label.layout(gfx);
            d = label.getSize();
            label.render(gfx, x + (_xDim - d.width) / 2, y + (Y_DIM - d.height) / 2);
            x += _xDim;
        }

        // paint the chests
        for (int ii=0; ii < 2; ii++) {
            boolean open = (_flipObj.state == FlipObject.GAME_OVER) && _flipObj.winners[ii];
            _chest[open ? 1 : 0].paint(gfx, CHEST_X[ii], CHEST_Y);
        }
    }

    /**
     * Get the current duration for evolving things on the board.
     */
    public long getEvolveDuration ()
    {
        return _duration;
    }

    /**
     * A class for waiting until each sprite has finished moving along the path prior to evolving
     * the board.
     */
    protected class EvolveWaiter
        implements PathObserver
    {
        public void addDropContext (DropContext ctx)
        {
            add(ctx);
        }

        public void addHoles (int numAdd, int numRemove, long seed)
        {
            add(new long[] { numAdd, numRemove, seed});
        }

        private void add (Object ctx)
        {
            _queue.addLast(ctx);
            if (_dctx == null)  {
                processNext();
            }
        }

        public void processNext ()
        {
            // we might be done
            if (_queue.isEmpty()) {
                _dctx = null;
                allEvolvesFinished();
                return;
            }

            _dctx = _queue.removeFirst();
            // our next action could be to add holes to the board
            if (_dctx instanceof long[]) {
                long[] addRem = (long[]) _dctx;
                _flipObj.board.addHoles((int) addRem[0], (int) addRem[1],
                    addRem[2]);
                processNext();
                return;
            }

            // otherwise, it's a ball drop
            playSound(FlipSounds.BALL_DROP);
            // turn off any hover ball in case 
            if (isManaged(_dropFeedback)) {
                removeSprite(_dropFeedback);
            }
            evolveStep();
        }

        public boolean isEvolving ()
        {
            return (_dctx instanceof DropContext);
        }

        public void pathAdded ()
        {
            _count++;
        }

        // documentation inherited from interface PathObserver
        public void pathCancelled (Sprite sprite, Path path)
        {
            pathCompleted(sprite, path, 0L); // treat the same
        }

        // documentation inherited from interface PathObserver
        public void pathCompleted (Sprite sprite, Path path, long when)
        {
            if (path instanceof LineSegmentPath) {
                // used for the jiggle, we ignore these
                return;
            }

            // normal path-ending processing, see if we're ready to evolve the drop
            if (--_count == 0 && _dctx != null) {
                evolveStep();
            }
        }

        /**
         * Called when we're not actually animating drops, to move the board evolution to the next
         * step.
         */
        protected void evolveSoon ()
        {
            // make sure we're not cleared and that the board isn't getting replaced
            final Object dctx = _dctx;
            if (dctx != null) {
                EventQueue.invokeLater(new Runnable() {
                    public void run () {
                        // make sure it's the same evolve step
                        if (_dctx == dctx) {
                            evolveStep();
                        }
                    }
                });
            }
        }

        /**
         * Do the next step in board evolution.
         */
        protected void evolveStep ()
        {
            // recalculate our duration for this next step
            boolean oldTurn =
                ((DropContext) _dctx).getPlayerIndex() != _ctrl._turnDelegate.getTurnHolderIndex();
            boolean queuedDrops = !_queue.isEmpty();
            if (_speedy) {
                if (queuedDrops || oldTurn) {
                    _duration = 0L;
                } else {
                    _duration = DURATION / 5;
                }

            } else if (queuedDrops) {
                _duration = DURATION / 10;

            } else if (oldTurn) {
                _duration = DURATION / 5;

            } else {
                _duration = DURATION;
            }

            // do it
            ((DropContext) _dctx).evolveDrop();
        }

        protected LinkedList<Object> _queue = new LinkedList<Object>();

        /** The drop context, or long[] if adding holes. */
        protected Object _dctx;

        /** The number of paths we're currently waiting on. */
        protected int _count = 0;
    }

    /** Listens for specified updates to the game configuration. */
    protected AttributeChangeListener _listener = new AttributeChangeListener() {
        public void attributeChanged (AttributeChangedEvent ace) {
            String name = ace.getName();
            if (FlipObject.TOP_SLOTS.equals(name)) {
                init();
            }
            if (FlipObject.MOVE_TIMEOUT.equals(name)) {
                long ms = 1000L * _flipObj.moveTimeout;
                for (int ii=0; ii < _playerViews.length; ii++) {
                    _playerViews[ii].setTurnDuration(ms);
                }

            } else if (FlipObject.WINNERS.equals(name)) {
                if (!_evolveWaiter.isEvolving()) {
                    displayGameOver();
                }
                stopLanes();
            }
        }
    };

    /** The giver of life. */
    protected WhirledContext _ctx;

    /** the number of slots along the bottom. */
    protected int _bottomSlots;

    /** Our controller. */
    protected FlipController _ctrl;

    /** The message bundle. */
    protected MessageBundle _msgs;

    /** The flip object. */
    protected FlipObject _flipObj;

    protected int _xDim;

    protected Font _pointValueFont;

    /** Player score views. */
    protected PlayerScoreView[] _playerViews;

    /** The background image. */
    protected Mirage _background;

    /** Sparkle images ejected by multiballs. */
    protected Mirage[] _sparkles = new Mirage[2];

    /** Chest images. */
    protected Mirage[] _chest = new Mirage[2];

    /** A label displaying the current round. */
    protected Label _roundLabel;

    /** The location of the round label. */
    protected Point _roundLoc = new Point(0, 33);

    /** Plays a warning sound near the end of a player's turn. */
    protected Interval _turnWarningInterval;

    /** Which score labels we're currently showing from the current round. */
    protected int _scoreLabelSeq = 0;

    /** Which lane is being hovered over by the mouse, or -1 if none. */
    protected int _hoverLane = -1;

    /** The frames for a flip, ball, hole. */
    protected MultiFrameImage _flipImage, _ballImage, _holeImage;

    /** A hash of all current flip sprites. */
    protected HashMap<Flip,FlipSprite> _flipSprites = new HashMap<Flip,FlipSprite>();

    /** A hash of all current ball sprites. */
    protected HashMap<Ball,BallSprite> _ballSprites = new HashMap<Ball,BallSprite>();

    /** A hash of all current hole sprites. */
    protected HashMap<Slot,ImageSprite> _holeSprites = new HashMap<Slot,ImageSprite>();

    /** The ball sprite that indicates where the user will move. */
    protected BallSprite _dropFeedback;

    /** The coin pile sprites. */
    protected CoinPileSprite[] _coinPiles = new CoinPileSprite[2];

    /** The list of button sprites. */
    protected LaneSprite[] _lanes;

    /** Waits for sprite paths to finish and continues board evolution. */
    protected EvolveWaiter _evolveWaiter = new EvolveWaiter();

    /** The computed duration of the board evolution step. Normally this is DURATION, but we speed
     * up if we've lagged and we're catching up. */
    protected long _duration;

    protected boolean _speedy;

    /** The colors of the score labels. */
    protected final Color SCORE_INNER_COLOR = new Color(0xedf44f);
    protected final Color SCORE_OUTER_COLOR = new Color(0x89358a);

    /** Chest x positions. */
    protected final int[] CHEST_X = { 3, 391 };

    /** Chest y positions. */
    protected static final int CHEST_Y = 174;

    /** The basic board dimension. */
    protected static final int Y_DIM = 22;
    protected static final int X_OFS = 16;
    protected static final int Y_OFS = 66;

    public static final long DURATION = 200;
}
