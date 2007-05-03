//
// $Id$

package com.threerings.flip.client;

import java.awt.BorderLayout;
import java.awt.Dimension;

import com.threerings.crowd.client.PlacePanel;

import com.whirled.util.WhirledContext;

/**
 * Contains the UI for a game of flip.
 */
public class FlipPanel extends PlacePanel
{
    /** The board view. */
    public FlipBoardView view;

    /**
     * Create the flip panel.
     */
    public FlipPanel (WhirledContext ctx, FlipController ctrl)
    {
        super(ctrl);

        setLayout(new BorderLayout());
        view = new FlipBoardView(ctx, ctrl);
        add(view, BorderLayout.CENTER);

        // TODO
        setPreferredSize(new Dimension(450, 600));
    }
}
