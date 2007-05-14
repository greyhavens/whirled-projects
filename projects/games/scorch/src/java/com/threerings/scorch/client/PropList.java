//
// $Id$

package com.threerings.scorch.client;

import java.awt.BorderLayout;
import javax.swing.JComboBox;
import javax.swing.JPanel;

import com.whirled.util.WhirledContext;

import com.threerings.scorch.util.ContentPack;

/**
 * Displays a scrolling list of all props available from all registered content packs.
 */
public class PropList extends JPanel
{
    public PropList (WhirledContext ctx)
    {
        super(new BorderLayout(5, 5));

        add(_packs = new JComboBox(ContentPack.packs.toArray()), BorderLayout.NORTH);
    }

    protected JComboBox _packs;
}
