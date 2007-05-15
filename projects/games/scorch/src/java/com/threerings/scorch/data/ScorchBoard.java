//
// $Id$

package com.threerings.scorch.data;

import java.awt.Point;
import java.util.ArrayList;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.DataInputStream;
import java.io.DataOutputStream;
import java.io.IOException;

import com.samskivert.util.StringUtil;
import com.threerings.io.Streamable;

import com.threerings.scorch.util.ContentPack;
import com.threerings.scorch.util.PropConfig;

import static com.threerings.scorch.Log.log;

/**
 * Contains the data that makes up a Scorch board.
 */
public class ScorchBoard
    implements Streamable
{
    /**
     * Creates a blank board. This is used for streaming and by the editor which will subsequently
     * call {@link #setProps}.
     */
    public ScorchBoard ()
    {
    }

    /**
     * Creates a board from the supplied hex encoded representation.
     */
    public ScorchBoard (String encoded)
        throws IOException
    {
        DataInputStream din = new DataInputStream(
            new ByteArrayInputStream(StringUtil.unhexlate(encoded)));
        _packId = din.readUTF();
        _propIds = new short[din.readShort()];
        _propXs = new short[_propIds.length];
        _propYs = new short[_propIds.length];
        for (int ii = 0; ii < _propIds.length; ii++) {
            _propIds[ii] = din.readShort();
            _propXs[ii] = din.readShort();
            _propYs[ii] = din.readShort();
        }
    }

    /**
     * Configures the props on this board. The props are rendered first to last, so props at the
     * front of the list are rendered behind props at the end of the list. Note: the props must all
     * be from the default content pack or a single additional pack more than one additional
     * content pack cannot be used on a board.
     */
    public void setProps (String packId, ArrayList<PropConfig> props, ArrayList<Point> locs)
    {
        _packId = packId;
        _propIds = new short[props.size()];
        _propXs = new short[props.size()];
        _propYs = new short[props.size()];
        for (int ii = 0, ll = props.size() ; ii < ll; ii++) {
            _propIds[ii] = props.get(ii).propId;
            _propXs[ii] = (short)locs.get(ii).x;
            _propYs[ii] = (short)locs.get(ii).y;
        }
    }

    /**
     * Returns the number of props on this board.
     */
    public int getPropCount ()
    {
        return _propIds.length;
    }

    /**
     * Returns the configuration for the prop at the specified index.
     */
    public PropConfig getPropConfig (int index)
    {
        short propId = _propIds[index];
        String packId = (propId < 0) ? ContentPack.DEFAULT_PACK_ID : _packId;
        ContentPack pack = ContentPack.packs.get(packId);
        if (pack == null) {
            log.warning("Missing pack for prop [packId=" + packId + ", propId=" + propId + "].");
            return null;
        }
        return pack.getProp(propId);
    }

    /**
     * Returns the x location of the prop at the specified index.
     */
    public int getPropX (int index)
    {
        return _propXs[index];
    }

    /**
     * Returns the y location of the prop at the specified index.
     */
    public int getPropY (int index)
    {
        return _propYs[index];
    }

    /**
     * Returns a cut and pasteable string encoding for this board.
     */
    public String toEncodedString ()
    {
        try {
            ByteArrayOutputStream bout = new ByteArrayOutputStream();
            DataOutputStream dout = new DataOutputStream(bout);
            dout.writeUTF(_packId);
            dout.writeShort((short)_propIds.length);
            for (int ii = 0; ii < _propIds.length; ii++) {
                dout.writeShort(_propIds[ii]);
                dout.writeShort(_propXs[ii]);
                dout.writeShort(_propYs[ii]);
            }
            dout.close();
            return StringUtil.hexlate(bout.toByteArray());

        } catch (IOException ioe) {
            throw new RuntimeException("ZOMG!", ioe); // should never happen
        }
    }

    protected String _packId;
    protected short[] _propIds;
    protected short[] _propXs;
    protected short[] _propYs;
}
