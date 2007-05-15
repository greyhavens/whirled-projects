//
// $Id$

package com.threerings.scorch.client;

import java.awt.BorderLayout;
import java.awt.Color;
import java.awt.Font;

import javax.swing.BorderFactory;
import javax.swing.JButton;
import javax.swing.JLabel;
import javax.swing.JPanel;

import java.util.logging.Level;

import com.samskivert.swing.GroupLayout;

import com.threerings.crowd.client.PlacePanel;
import com.threerings.util.MessageBundle;

import com.whirled.util.WhirledContext;

import com.threerings.scorch.util.ContentPack;

import static com.threerings.scorch.Log.log;

/**
 * Contains the primary client interface for the game.
 */
public class ScorchPanel extends PlacePanel
{
    /**
     * Creates a Scorch panel and its associated interface components.
     */
    public ScorchPanel (WhirledContext ctx, ScorchController ctrl)
    {
        super(ctrl);
        _ctx = ctx;

        // TODO: do this somewhere else? provide feedback?
        try {
            ContentPack.init();
        } catch (Exception e) {
            log.log(Level.WARNING, "Failed to initialize content packs.", e);
            // TODO: display error
        }

        // this is used to look up localized strings
        MessageBundle msgs = _ctx.getMessageManager().getBundle("scorch");

        // give ourselves a wee bit of a border
	setBorder(BorderFactory.createEmptyBorder(5, 5, 5, 5));
        setLayout(new BorderLayout(5, 5));

        // create and add our board view
        EditorBoardView bview = new EditorBoardView(ctx);
        add(bview, BorderLayout.CENTER);

        // create a side panel to hold our chat and other extra interfaces
        JPanel sidePanel = GroupLayout.makeVStretchBox(5);

        // add a big fat label
        JLabel vlabel = new JLabel(msgs.get("m.title"));
        vlabel.setFont(new Font("Helvetica", Font.BOLD, 16));
        vlabel.setForeground(Color.black);
        sidePanel.add(vlabel, GroupLayout.FIXED);

        // TEMP: display our editor control panel
        sidePanel.add(new EditorControlPanel(ctx, bview));

//         // add a chat box
//         sidePanel.add(new ChatPanel(ctx));

        // add a "back to lobby" button
        JButton back = ScorchController.createActionButton(
            msgs.get("m.back_to_lobby"), "backToLobby");
        sidePanel.add(back, GroupLayout.FIXED);

        // add our side panel to the main display
        add(sidePanel, BorderLayout.EAST);
    }

    /** Provides access to various client services. */
    protected WhirledContext _ctx;
}
