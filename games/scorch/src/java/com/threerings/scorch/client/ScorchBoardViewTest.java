//
// $Id$

package com.threerings.scorch.client;

import javax.swing.JComponent;

import com.threerings.toybox.util.GameViewTest;
import com.threerings.toybox.util.ToyBoxContext;

import com.whirled.util.WhirledContext;

/**
 * A test harness for our board view.
 */
public class ScorchBoardViewTest extends GameViewTest
{
    public static void main (String[] args)
    {
        ScorchBoardViewTest test = new ScorchBoardViewTest();
        test.display();
    }

    protected JComponent createInterface (ToyBoxContext ctx)
    {
        return _view = new ScorchBoardView((WhirledContext)ctx);
    }

    protected void initInterface ()
    {
        // add sprites and other media to the board view here
    }

    protected ScorchBoardView _view;
}
