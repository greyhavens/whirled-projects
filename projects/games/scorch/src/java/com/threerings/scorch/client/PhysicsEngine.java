//
// $Id$

package com.threerings.scorch.client;

import java.awt.Graphics2D;
import java.awt.image.BufferedImage;

import java.util.ArrayList;
import java.util.logging.Level;

import com.threerings.scorch.data.ScorchBoard;
import com.threerings.scorch.util.PropConfig;

import static com.threerings.scorch.Log.log;

/**
 * Implements a simple physics engine that moves our sprites around the screen in a cartoony but
 * believable way and handles collision detection with other units and the terrain.
 */
public class PhysicsEngine
{
    /**
     * Implemented by entities which are to be managed by the physics engine.
     */
    public static interface Entity
    {
        /** Moves this entity to the specified screen coordinates. */
        public void setLocation (int x, int y);

        /** Returns the x screen coordinate of this entity. */
        public int getX ();

        /** Returns the y screen coordinate of this entity. */
        public int getY ();

        /** Provides the entity with access to its physical state. Changes to the state will be
         * reflected on the next tick of the physics engine. */
        public void setEntityData (EntityData data);
    }

    /** Tracks physical state for a particular entity. */
    public static class EntityData
    {
        public Entity entity;

        public float curx, cury;
        public float velx, vely;
        public float accx, accy;

        public EntityData (Entity entity) {
            this.entity = entity;
            entity.setEntityData(this);
            curx = entity.getX();
            cury = entity.getY();
        }

        public void tick (PhysicsEngine engine, float dt) {
            // nothing doing if we're not moving'
            if (velx == 0 && vely == 0 && accx == 0 && accy == 0) {
                return;
            }

            float newx = curx + velx * dt, newy = cury + vely * dt;
            velx += accx * dt;
            vely += accy * dt;

            // step through the locations we will traverse from our starting position to our
            // new position and see if we collide with anything along the way
            int pixx = Math.round(curx), pixy = Math.round(cury);
            int steps = (int)Math.ceil(Math.max(Math.abs(newx - curx), Math.abs(newy - cury)));
            float dx = (newx - curx)/steps, dy = (newy - cury)/steps;
            System.err.println("Moving from " + cury + " to " + newy + " in " + steps + " steps.");
            for (int ii = 0; ii < steps; ii++) {
                pixx = Math.round(curx + dx);
                pixy = Math.round(cury + dy);

                // if we didn't hit anything, keep going
                if (!engine.collides(this, pixx, pixy)) {
                    curx += dx;
                    cury += dy;
                    continue;
                }

                System.err.println("Collided at " + pixx + " " + pixy + ".");

                // if our velocity is small, just stop at our previous position
                if (steps < 4) {
                    pixx = Math.round(curx);
                    pixy = Math.round(cury);
                    accx = accy = 0;
                    velx = vely = 0;

                } else {
                    // if we're moving fast, stop at our current position and bounce back the other
                    // direction a bit, but set our acceleration such that we'll return in this
                    // direction more slowly and settle into the right spot
                    accx = velx;
                    accy = vely;
                    velx *= -0.25;
                    vely *= -0.25;
                }
                break; // TODO: tell entity about collision
            }

            entity.setLocation(pixx, pixy);
        }
    }

    /**
     * Configures our terrain representation with the supplied props.
     */
    public void setBoard (ScorchBoard board)
    {
        // create a 1-bit-per-pixel bitmap
        _terrain = new BufferedImage(
            board.getWidth(), board.getHeight(), BufferedImage.TYPE_BYTE_BINARY);

        // paint our props onto the terrain
        Graphics2D gfx = _terrain.createGraphics();
        for (int ii = 0, ll = board.getPropCount(); ii < ll; ii++) {
            PropConfig prop = board.getPropConfig(ii);
            int px = board.getPropX(ii), py = board.getPropY(ii);
            if (prop.mask != null) {
                gfx.drawImage(prop.mask, px, py, null);
            } else {
                // TODO: set OP_OVER?
                gfx.drawImage(prop.image, px, py, null);
            }
            System.err.println("Stamped " + prop.image.getWidth() + "x" + prop.image.getHeight() +
                               "+" + px + "+" + py);
        }
        gfx.dispose();
    }

    /**
     * Registers an entity with the engine. If we are in the middle of a tick, the entity will be
     * added after the tick completes.
     */
    public void addEntity (Entity entity)
    {
        if (_tickStamp == 0L) {
            actuallyAddEntity(entity, 0);
        } else {
            _pending.add(entity);
        }
    }

    /**
     * Removes an entity from the engine.
     */
    public void removeEntity (Entity entity)
    {
        for (int ii = 0; ii < _entities.length; ii++) {
            if (_entities[ii] != null && _entities[ii].entity == entity) {
                _entities[ii] = null;
            }
        }
    }

    /**
     * Called once per frame to update the state of all physical entities.
     */
    public void tick (long tickStamp)
    {
        // determine how long it has been since we were last ticked
        _tickStamp = tickStamp;
        float dt = (tickStamp - _lastTickStamp) / 1000f;

        // tick all registered entities
        for (int ii = 0; ii < _entities.length; ii++) {
            EntityData entity = _entities[ii];
            if (entity != null) {
                try {
                    entity.tick(this, dt);
                } catch (Exception e) {
                    log.log(Level.WARNING, "Entity choked in tick '" + entity.entity + "'.", e);
                }
            }
        }
        _tickStamp = 0L;
        _lastTickStamp = tickStamp;

        // add any pending entities
        int startidx = 0;
        for (int ii = 0, ll = _pending.size(); ii < ll; ii++) {
            startidx = actuallyAddEntity(_pending.get(ii), startidx);
        }
        _pending.clear();
    }

    protected int actuallyAddEntity (Entity entity, int startidx)
    {
        // look for an empty slot to stick this entity
        for (int ii = startidx; ii < _entities.length; ii++) {
            if (_entities[ii] == null) {
                _entities[ii] = new EntityData(entity);
                return ii;
            }
        }

        // expand the array and tack it onto the end
        int curlength = _entities.length;
        EntityData[] entities = new EntityData[curlength*2];
        System.arraycopy(_entities, 0, entities, 0, curlength);
        _entities = entities;
        entities[curlength] = new EntityData(entity);
        return curlength;
    }

    protected boolean collides (EntityData edata, int curx, int cury)
    {
        if (curx < 0 || curx >= _terrain.getWidth() ||
            cury < 0 || cury >= _terrain.getHeight()) {
            return false;
        }
        int color = _terrain.getRGB(curx, cury) & 0xFFFFFF;
        // System.err.println("Collides at +" + curx + "+" + cury + ": " + color);
        return color != 0;
    }

    /** Tracks physical state for our managed entities. */
    protected EntityData[] _entities = new EntityData[32];

    /** Entities waiting to be registered with the engine. */
    protected ArrayList<Entity> _pending = new ArrayList<Entity>();

    /** When ticking, our current tick stamp. */
    protected long _tickStamp;

    /** The time at which we were last ticked. */
    protected long _lastTickStamp;

    /** Contains our terrain bitmap. */
    protected BufferedImage _terrain;
}
