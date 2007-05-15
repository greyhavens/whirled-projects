//
// $Id$

package com.threerings.scorch.client;

import java.awt.BorderLayout;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;

import javax.swing.AbstractListModel;
import javax.swing.JComboBox;
import javax.swing.JList;
import javax.swing.JPanel;

import java.util.ArrayList;

import com.whirled.util.WhirledContext;

import com.threerings.scorch.util.ContentPack;
import com.threerings.scorch.util.PropConfig;

/**
 * Displays a scrolling list of all props available from all registered content packs.
 */
public class PropList extends JPanel
{
    public PropList (WhirledContext ctx)
    {
        super(new BorderLayout(5, 5));

        add(_packs = new JComboBox(ContentPack.packs.toArray()), BorderLayout.NORTH);
        add(_props = new JList());
        _packs.addActionListener(new ActionListener() {
            public void actionPerformed (ActionEvent e) {
                selectContentPack((ContentPack)_packs.getSelectedItem());
            }
        });

        // TODO: set up a ListCellRenderer that renders the prop images

        // start with the zeroth pack selected
        if (ContentPack.packs.size() > 0) {
            selectContentPack(ContentPack.packs.get(0));
        }
    }

    protected void selectContentPack (ContentPack pack)
    {
        final ArrayList<PropConfig> props = pack.getProps();
        _props.setModel(new AbstractListModel() {
            public int getSize () {
                return props.size();
            }
            public Object getElementAt (int index) {
                return props.get(index);
            }
        });
    }

    protected JComboBox _packs;
    protected JList _props;
}
