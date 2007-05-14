//
// $Id$

package com.threerings.scorch.util;

import java.awt.image.BufferedImage;
import javax.imageio.ImageIO;

import java.io.BufferedReader;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;

import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.Properties;
import java.util.logging.Level;
import java.util.zip.ZipEntry;
import java.util.zip.ZipInputStream;

import com.samskivert.io.StreamUtil;
import com.samskivert.util.StringUtil;

import static com.threerings.scorch.Log.log;

/**
 * Provides access to all the media in a content pack.
 */
public class ContentPack
{
    public static void main (String[] args)
        throws IOException
    {
        ContentPack pack;
        if (args.length > 0) {
            pack = new ContentPack(new ZipInputStream(new FileInputStream(args[0])));
        } else {
            pack = new ContentPack();
        }
    }

    /**
     * Creates a content pack that loads its contents from the classpath (which allows for one
     * stock content pack to be 'built-in' to the game).
     */
    public ContentPack ()
        throws IOException
    {
        ClassLoader loader = getClass().getClassLoader();
        String[] contents = resourceToStrings(
            loader.getResourceAsStream(DEFAULT_PACK_PREFIX + "contents.txt"));
        for (String path : contents) {
            processResource(path, loader.getResourceAsStream(DEFAULT_PACK_PREFIX + path));
        }
        init();
    }

    /**
     * Creates a content pack that loads its contents from the supplied input stream. TODO: use our
     * real content pack format when available.
     */
    public ContentPack (ZipInputStream source)
        throws IOException
    {
        ZipEntry entry;
        while ((entry = source.getNextEntry()) != null) {
            processResource(entry.getName(), source);
        }
        init();
    }

    /**
     * Returns all factions specified in this content pack.
     */
    public Collection<FactionConfig> getFactions ()
    {
        return _factions;
    }

    /**
     * Returns the configuration of all props specified in this content pack.
     */
    public Collection<PropConfig> getProps ()
    {
        return _props;
    }

    /**
     * Called after we have loaded our resources to parse the content pack metadata into our
     * configuration object model.
     */
    protected void init ()
        throws IOException
    {
        String[] factions = StringUtil.parseStringArray(_config.getProperty("factions", ""));
        for (String faction : factions) {
            _factions.add(new FactionConfig(faction, _config));
        }

        // TODO: iterate over image data and create PropConfig records for all props/*
    }

    /**
     * Loads in the data from the supplied resource, parsing it into either a {@link Properties}
     * instance or a {@link BufferedImage} depending on its file extension.
     */
    protected void processResource (String path, InputStream in)
        throws IOException
    {
        if (path.equals("pack.properties")) {
            _config.load(in);

        } else if (path.endsWith(".png")) {
            log.info("Loading image " + path + "...");
            _imap.put(path, ImageIO.read(in));

        } else {
            log.info("Skipping unknown resource '" + path + "'.");
        }
    }

    /**
     * Parses a stream's contents as an array of strings. If the data cannot be read, an error will
     * be logged and a zero length array will be returned.
     */
    protected static String[] resourceToStrings (InputStream in)
    {
        ArrayList<String> lines = new ArrayList<String>();
        BufferedReader bin = null;
        try {
            if (in != null) {
                bin = new BufferedReader(new InputStreamReader(in));
                String line;
                while ((line = bin.readLine()) != null) {
                    lines.add(line);
                }
            }

        } catch (Exception e) {
            log.log(Level.WARNING, "Failed to convert resource to strings.", e);

        } finally {
            StreamUtil.close(in);
        }

        return lines.toArray(new String[lines.size()]);
    }

    protected Properties _config = new Properties();
    protected ArrayList<FactionConfig> _factions = new ArrayList<FactionConfig>();
    protected ArrayList<PropConfig> _props = new ArrayList<PropConfig>();
    protected HashMap<String,BufferedImage> _imap = new HashMap<String,BufferedImage>();

    protected static final String DEFAULT_PACK_PREFIX = "rsrc/packs/default/";
}
