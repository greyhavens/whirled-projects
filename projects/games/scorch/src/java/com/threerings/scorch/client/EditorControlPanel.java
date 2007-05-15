//
// $Id$

package com.threerings.scorch.client;

import java.awt.BorderLayout;
import java.awt.event.ActionEvent;

import javax.swing.AbstractAction;
import javax.swing.AbstractListModel;
import javax.swing.JButton;
import javax.swing.JList;
import javax.swing.JPanel;

import java.util.ArrayList;

import com.samskivert.swing.GroupLayout;

import com.whirled.util.WhirledContext;

import com.threerings.scorch.data.ScorchBoard;
import com.threerings.scorch.util.ContentPack;
import com.threerings.scorch.util.PropConfig;

import static com.threerings.scorch.Log.log;

/**
 * Contains and manages editor controls.
 */
public class EditorControlPanel extends JPanel
{
    public EditorControlPanel (WhirledContext ctx, EditorBoardView view)
    {
        super(new BorderLayout(5, 5));

        _ctx = ctx;
        _view = view;
        _view.init(this);

        JPanel buttons = GroupLayout.makeButtonBox(GroupLayout.LEFT);
        buttons.add(new JButton(_newBoard));
        buttons.add(new JButton(_import));
        buttons.add(new JButton(_export));
        add(buttons, BorderLayout.NORTH);

        add(_props = new JList(), BorderLayout.CENTER);

        // export is not available until we have some board data
        _export.setEnabled(false);
    }

    public String getPackId ()
    {
        return _packId;
    }

    public PropConfig getSelectedProp ()
    {
        return (PropConfig)_props.getSelectedValue();
    }

    protected void createNewBoard (ContentPack pack)
    {
        _packId = pack.getIdent();
        _view.clearSprites();

        final ArrayList<PropConfig> props = new ArrayList<PropConfig>();
        props.addAll(pack.getProps());
        if (!pack.getIdent().equals(ContentPack.DEFAULT_PACK_ID)) {
            ContentPack defpack = ContentPack.packs.get(ContentPack.DEFAULT_PACK_ID);
            props.addAll(defpack.getProps());
        }

        _props.setModel(new AbstractListModel() {
            public int getSize () {
                return props.size();
            }
            public Object getElementAt (int index) {
                return props.get(index);
            }
        });

        // we have a board, so now we can export
        _export.setEnabled(true);
    }

    protected AbstractAction _newBoard = new AbstractAction("New...") {
        public void actionPerformed (ActionEvent event) {
            // TODO: allow the selection of a particular content pack
            createNewBoard(ContentPack.packs.get(ContentPack.DEFAULT_PACK_ID));
        }
    };

    protected AbstractAction _import = new AbstractAction("Import") {
        public void actionPerformed (ActionEvent event) {
            // TODO: pop up a dialog where they can paste encoded test
        }
    };

    protected AbstractAction _export = new AbstractAction("Export") {
        public void actionPerformed (ActionEvent event) {
            // TODO: display the encoded text in a cut-and-paste friendly dialog
            log.info("Board data: " + _view.exportBoard().toEncodedString());
        }
    };

    protected WhirledContext _ctx;
    protected EditorBoardView _view;

    protected String _packId;
    protected JList _props;
}
