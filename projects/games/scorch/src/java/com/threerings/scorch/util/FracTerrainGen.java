//
// $Id$

package com.threerings.scorch.util;

import java.io.File;
import java.util.Arrays;

import java.awt.Color;
import java.awt.Graphics2D;
import java.awt.image.BufferedImage;

import javax.imageio.ImageIO;

/**
 * A test class for playing around with 2D terrain generation.
 */
public class FracTerrainGen
{
    /**
     * Generates a 1D height map of terrain. The terrain will be values between minus one and one
     * which can be scaled to a desired terrain height.
     *
     * @param width the width of the heightmap.
     * @param roughness a value between zero and one that dictates the roughness of the terrain,
     * one being maximum roughness.
     */
    public static double[] generateTerrain (int width, double roughness)
    {
        double rfactor = (double)Math.pow(2, roughness-1), maxdisp = 1;
        System.err.println("Roughness factor " + rfactor + ".");
        double[] terrain = new double[width]; // starts at zero, the midpoint
        displaceTerrain(terrain, maxdisp, rfactor, 0, terrain.length-1, 0, 0, 0);
        return terrain;
    }

    public static void main (String[] args)
        throws Exception
    {
        int width = 1024, height = 600;
        double[] terrain = generateTerrain(width, 0.005);
        renderTerrain(terrain, height, "terrain.png");
    }

    protected static void displaceTerrain (double[] terrain, double maxdisp, double rfactor,
                                           int lo, int hi, double loy, double hiy, int depth)
    {
        int range = (hi-lo), mid = lo + range/2;
        double midy = loy + (hiy - loy)/2;
        double offset = (depth > DEPTH_CUTOFF) ? 0 : maxdisp * (2*Math.random() - 1);
        terrain[mid] = midy + offset;
        if (range <= 0) {
            return;
        }
        maxdisp *= rfactor;
        if (lo < mid) {
            displaceTerrain(terrain, maxdisp, rfactor, lo, mid-1, loy, terrain[mid], depth+1);
        }
        if (hi > mid) {
            displaceTerrain(terrain, maxdisp, rfactor, mid+1, hi, terrain[mid], hiy, depth+1);
        }
    }

    protected static void renderTerrain (double[] terrain, int height, String filename)
        throws Exception
    {
        int width = terrain.length;
        BufferedImage image = new BufferedImage(width, height, BufferedImage.TYPE_INT_RGB);
        Graphics2D gfx = image.createGraphics();
        gfx.setColor(Color.white);
        for (int xx = 0; xx < width-1; xx++) {
            int yy = (int)Math.round((terrain[xx] + 1)/2 * height);
            gfx.drawLine(xx, yy, xx, height);
        }
        gfx.dispose();
        ImageIO.write(image, "PNG", new File(filename));
    }

    /** Prevents the terrain from becoming too finely detailed. */
    protected static int DEPTH_CUTOFF = 7;
}
