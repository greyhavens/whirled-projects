//
// $Id$

package com.threerings.flip.client;

import java.awt.Color;
import java.awt.Dimension;
import java.awt.Graphics2D;

import com.samskivert.swing.Label;

import com.threerings.util.MessageBundle;

import com.threerings.media.MediaPanel;

import com.threerings.crowd.data.PlaceObject;

import com.whirled.client.PlayerView;
import com.whirled.util.WhirledContext;

import com.threerings.flip.data.FlipCodes;
import com.threerings.flip.data.FlipObject;

/**
 * Displays a player's score and so on.
 */
public class PlayerScoreView extends PlayerView
    implements FlipCodes
{
    public PlayerScoreView (WhirledContext ctx, MediaPanel host, long turnDuration,
                            int pidx, int x, int y)
    {
        super(ctx, host, turnDuration, pidx, x, y, new Color(0x800E90));

        _msgs = ctx.getMessageManager().getBundle(FLIP_MESSAGE_BUNDLE);

        for (int ii=0; ii < ROUNDS; ii++) {
            _roundLabels[ii] = new Label("", Label.OUTLINE, Color.YELLOW, Color.BLACK, SMALL_FONT);
            _roundLabels[ii].layout(host);
            _pointLabels[ii] = new Label("", Label.OUTLINE, Color.YELLOW, Color.BLACK, SMALL_FONT);
        }
        _scoreLabel = new Label("", Label.OUTLINE, Color.YELLOW, Color.BLACK, MEDIUM_FONT);
    }

    @Override // documentation inherited
    public int getWidth ()
    {
        return 97;
    }

    @Override // documentation inherited
    public int getHeight ()
    {
        return 172;
    }

    @Override // documentation inherited
    public void willEnterPlace (PlaceObject placeObject)
    {
        super.willEnterPlace(placeObject);
        checkLabels();
    }

    /**
     * Called to hide the timer for the player (when it's still their turn but we're animating
     * their move.
     */
    public void hideTimer ()
    {
        _timerView.setEnabled(false);
        invalidate();
    }

    /**
     * Recheck the values of the score labels and invalidate.
     */
    public void checkLabels ()
    {
        FlipObject flipObj = (FlipObject) _gameObj;
        int total = 0;
        int round = flipObj.roundId;
        for (int ii=0; ii < ROUNDS; ii++) {
            String roundText = _msgs.get("m.round_scores", String.valueOf(ii + 1));
            if (ii == round) {
                roundText += "        /" + POINT_TARGETS[ii];
            }
            _roundLabels[ii].setText(roundText);

            int points = (flipObj.scores == null) ? 0 : flipObj.scores[_pidx][ii];
            total += points;
            String pointText = "";
            if (points > 0 || round >= ii) {
                pointText = String.valueOf(points);
            }
            _pointLabels[ii].setText(pointText);
        }

        _scoreLabel.setText(_msgs.get("m.score", String.valueOf(total)));

        _labelsNeedLayout = true;
        invalidate();
    }

    @Override // documentation inherited
    protected void paintExtra (Graphics2D gfx)
    {
        if (_labelsNeedLayout) {
            for (int ii=0; ii < ROUNDS; ii++) {
                _roundLabels[ii].layout(gfx);
                _pointLabels[ii].layout(gfx);
            }
            _scoreLabel.layout(gfx);
            _labelsNeedLayout = false;

            Label l = new Label(_msgs.get("m.round_scores", "1") + "      .",
                                Label.OUTLINE, Color.YELLOW, Color.BLACK, SMALL_FONT);
            l.layout(gfx);
            Dimension d = l.getSize();
            _pointsPosition = d.width;
        }

        // draw the points and round labels or you don't get no rating ables...  hackity hack!
        // (don't talk back)
        Dimension d;
        int x = 7, y = 74;
        for (int ii=0; ii < ROUNDS; ii++) {
            d = _pointLabels[ii].getSize();
            _roundLabels[ii].render(gfx, x, y);
            _pointLabels[ii].render(gfx, x + _pointsPosition - d.width, y);
            y += 17; // we know the font is 10 point... this works
        }

        // draw a line in the same style
        gfx.setColor(Color.BLACK);
        gfx.fillRect(x, y, LINE_WIDTH, 3);
        gfx.setColor(Color.YELLOW);
        y += 1;
        gfx.fillRect(x + 1, y, LINE_WIDTH - 2, 1);
        y += 3;

        // draw the final score
        _scoreLabel.render(gfx, x, y);
    }

    protected MessageBundle _msgs;

    protected Label[] _roundLabels = new Label[ROUNDS];
    protected Label[] _pointLabels = new Label[ROUNDS];
    protected Label _scoreLabel;

    protected int _pointsPosition;

    protected boolean _labelsNeedLayout = true;

    protected static final int LINE_WIDTH = 80;
}
