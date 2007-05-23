//
// $Id$

package com.threerings.scorch.client;

import java.awt.AlphaComposite;
import java.awt.Graphics2D;
import java.awt.image.BufferedImage;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.logging.Level;

import com.samskivert.util.StringUtil;

import net.phys2d.math.Vector2f;

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

        /** Displays debugging information about this entity. */
        public void setDebug (float ax, float ay, float vx, float vy);
    }

    /** Tracks physical state for a particular entity. */
    public class EntityData
    {
        public Entity entity;

        public Vector2f pos = new Vector2f();
        public Vector2f vel = new Vector2f();
        public Vector2f acc = new Vector2f();

        public boolean inContact;

        public float convelx;

        public EntityData (Entity entity)
        {
            this.entity = entity;
            entity.setEntityData(this);
            pos.x = entity.getX();
            pos.y = entity.getY();
        }

        public void tick (float dt)
        {
            if (inContact && vel.y == 0) {
                contactDynamics(dt);
            } else {
                inContact = false;
                freeDynamics(dt);
            }
            entity.setLocation((int)pos.x, (int)pos.y);
        }

        protected void contactDynamics (float dt)
        {
            // if we have contact velocity, use that
            float velx;
            if (convelx != 0) {
                velx = convelx;
                vel.x = 0;

            } else {
                // we're in contact with the ground, so apply friction
                if (vel.x > 0) {
                    vel.x = Math.max(vel.x - _fricaccx * dt, 0);
                } else {
                    vel.x = Math.min(vel.x + _fricaccx * dt, 0);
                }
                velx = vel.x;
            }

            // now step through and follow the terrain (or stop) at each pixel position
            int pixx = (int)pos.x, pixy = (int)pos.y;
            int pixels = (int)Math.ceil(Math.abs(velx * dt));
            float stepdt = dt/pixels, nposx = pos.x;
            for (int ii = 0; ii < pixels; ii++) {
                nposx += velx * stepdt;
                int oldx = pixx, oldy = pixy;
                pixx = (int)nposx;

                // if we have terrain at our next pixel, see if we should climb or stop
                if (haveTerrain(pixx, pixy)) {
                    int freey = 0;
                    for (int uu = 0; uu < MAX_CLIMB_PIXELS; uu++) {
                        freey = pixy - uu - 1;
                        if (!haveTerrain(pixx, freey)) {
                            break;
                        }
                    }

                    // TODO: variable climbing capability
                    if (pixy - freey >= 7) {
                        log.info("Wall! " + pixx + " " + pixy + " (up: " + freey + ").");
                        vel.x = 0; // TODO: bounce?
                        break;
                    }

                    pos.y += (freey - pixy);
                    pixy = freey;

                } else {
                    // search downward for solid ground
                    int groundy = _height;
                    for (int uu = 0; uu < MAX_CLIMB_PIXELS; uu++) {
                        groundy = pixy + uu + 1;
                        if (haveTerrain(pixx, groundy)) {
                            break;
                        }
                    }

                    // TODO: variable climbing to falling threshold
                    if (groundy - pixy >= 7) {
                        log.info("Falling +" + pixx + "+" + pixy + " (down: " + groundy + ").");
                        inContact = false;
                        pos.x = nposx;
                        break;
                    }

                    pos.y += (groundy - pixy - 1);
                    pixy = groundy - 1;
                }

                pos.x = nposx;
            }
        }

        protected void freeDynamics (float dt)
        {
            // compute our total acceleration
            _racc.set(acc);
            _racc.add(_gravacc);

            // update our velocity
            vel.addScaled(_racc, dt);

            // display debugging information
            entity.setDebug(_racc.x, _racc.y, vel.x, vel.y);

            // compute our potential new position
            _npos.set(pos);
            _npos.addScaled(vel, dt);

            // determine how many pixels we would travel in both directions and adjust our
            // timeslice such that we step no more than one pixel at a time
            int steps = (int)Math.ceil(
                Math.max(Math.abs(_npos.x - pos.x), Math.abs(_npos.y - pos.y)));
            float stepdt = dt/steps;

            // log.info("Moving from " + pos + " to " + _npos + " in " + steps + " steps.");
             int pixx = (int)pos.x, pixy = (int)pos.y;
            _npos.set(pos);
            for (int ii = 0; ii < steps; ii++) {
                _npos.addScaled(vel, stepdt);
                int oldx = pixx, oldy = pixy;
                pixx = (int)_npos.x;
                pixy = (int)_npos.y;

                // if we didn't move a fill pixel from our previous location, or if we didn't hit
                // anything, keep going
                if ((pixx == oldx && pixy == oldy) || !haveTerrain(pixx, pixy)) {
                    pos.set(_npos);
                    continue;
                }

                // compute the normal to the line approximation at the collision point
                slope(pixx, pixy, oldx, oldy, _snorm);

                // if our velocity is small enough and we're going down (not up) and there is
                // ground beneath us, make contact
                boolean contact = haveTerrain(oldx, oldy+1);
                if (contact && vel.y > 0 && Math.abs(vel.y) < MIN_FREE_Y_VEL) {
                    inContact = true;
                    System.err.println("Contacting at p" + _npos + " (+" + pixx + "+" + pixy +
                                       ") v" + vel + " n" + _snorm + ".");
                    vel.y = 0;
                    break;
                }

                System.err.println("Collision at p" + _npos + " (+" + pixx + "+" + pixy + ") " +
                                   "v" + vel + " n" + _snorm + ".");

                // reflect the velocity vector around said line approximation:
                // Vr = V - 2(V dot N)N
                vel.addScaled(_snorm, -2 * vel.dot(_snorm));

                // if we're in contact with the ground, apply friction
                if (contact) {
                    if (vel.x > 0) {
                        vel.x = Math.max(vel.x - _fricaccx * stepdt, 0);
                    } else {
                        vel.x = Math.min(vel.x + _fricaccx * stepdt, 0);
                    }
                }

                // then scale the whole dang thing down for energy lost to "other sources"
                vel.scale(0.75f);
            }
        }

        protected Vector2f _racc = new Vector2f();
        protected Vector2f _npos = new Vector2f();
        protected Vector2f _snorm = new Vector2f();
    }

    /**
     * Configures our terrain representation with the supplied props.
     */
    public void setBoard (ScorchBoard board)
    {
        // create a 1-bit-per-pixel bitmap
        _terrain = new BufferedImage(
            _width = board.getWidth(), _height = board.getHeight(), BufferedImage.TYPE_BYTE_BINARY);

        // paint our props onto the terrain
        Graphics2D gfx = _terrain.createGraphics();
        for (int ii = 0, ll = board.getPropCount(); ii < ll; ii++) {
            PropConfig prop = board.getPropConfig(ii);
            int px = board.getPropX(ii), py = board.getPropY(ii);
            gfx.drawImage(prop.mask, px, py, null);
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
     * Clears out all entities.
     */
    public void clearEntities ()
    {
        Arrays.fill(_entities, null);
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
                    entity.tick(dt);
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

    // TODO: once we're ready to benchmark, try making this final
    protected boolean haveTerrain (int x, int y)
    {
        if (x < 0 || x >= _width || y < 0 || y >= _height) {
            return true;
        }
        return (_terrain.getRGB(x, y) & 0xFFFFFF) != 0;
    }

    /**
     * Computes the slope at the supplied collision x and y position using the supplied previous x
     * and y position to properly effect the search.
     */
    protected void slope (int cx, int cy, int px, int py, Vector2f norm)
    {
        // depending on which direction our previous point is relative to our collision point, we
        // start at the specified coordinates in the context "ring" around our collision point; you
        // really need a diagram to understand this, alas
        int sidx = PREV_TO_SLOPE[py-cy+1][px-cx+1];

        // now search clockwise for the "left" slope intersection
        int leftx = 0, lefty = 0;
        for (int ii = 1; ii <= SLOPE_SEARCH; ii++) {
            int lidx = (sidx + ii) % SLOPE_CONTEXT_X.length;
            leftx = cx + SLOPE_CONTEXT_X[lidx];
            lefty = cy + SLOPE_CONTEXT_Y[lidx];
            if (haveTerrain(leftx, lefty)) {
                break;
            }
        }
        // if we found no terrain, we'll use the last searched point

        // now search counter clockwise for the "right" slope intersection
        int rightx = 0, righty = 0;
        for (int ii = 1; ii < SLOPE_SEARCH; ii++) {
            int lidx = (sidx + SLOPE_CONTEXT_X.length - ii) % SLOPE_CONTEXT_X.length;
            rightx = cx + SLOPE_CONTEXT_X[lidx];
            righty = cy + SLOPE_CONTEXT_Y[lidx];
            if (haveTerrain(rightx, righty)) {
                break;
            }
        }
        // if we found no terrain, we'll use the last searched point

        norm.set(-(righty-lefty), (rightx-leftx));
        norm.normalize();
    }

    /** Tracks physical state for our managed entities. */
    protected EntityData[] _entities = new EntityData[32];

    /** Entities waiting to be registered with the engine. */
    protected ArrayList<Entity> _pending = new ArrayList<Entity>();

    /** When ticking, our current tick stamp. */
    protected long _tickStamp;

    /** The time at which we were last ticked. */
    protected long _lastTickStamp;

    /** Acceleration from gravity. */
    protected Vector2f _gravacc = new Vector2f(0, 500);

    /** Velocity attenuation from friction (TODO: get this from the material?). */
    protected float _fricaccx = 250;

    /** The dimensions of the board. */
    protected int _width, _height;

    /** Contains our terrain bitmap. */
    protected BufferedImage _terrain;

    /** If we exceed this horizontal velocity we switch to free dynamics. */
    protected static final float MAX_CONTACT_X_VEL = 200f;

    /** PREV_TO_SLOPE[py-cy+1)][px-cx+1] = starting index in slope context. */
    protected static final int[][] PREV_TO_SLOPE = {
        { 0, 2, 4 }, { 14, -1, 6 }, { 12, 10, 8 } };

    /** Defines the coordinates around which we search for slope intersection points. */
    protected static final int[] SLOPE_CONTEXT_X = {
        -2, -1,  0,  1,  2,  2, 2, 2, 2, 1, 0, -1, -2, -2, -2, -2 };

    /** Defines the coordinates around which we search for slope intersection points. */
    protected static final int[] SLOPE_CONTEXT_Y = {
        -2, -2, -2, -2, -2, -1, 0, 1, 2, 2, 2,  2,  2,  1,  0, -1 };

    /** The number of slots around the context to search for our slope intersection. */
    protected static final int SLOPE_SEARCH = 6;

    /** Higher than the highest any unit could ever climb in a single step. */
    protected static final int MAX_CLIMB_PIXELS = 10;

    /** If the magnitude of our y velocity drops below this value, we switch from free to contact
     * dynamics. */
    protected static final float MIN_FREE_Y_VEL = 200;
}
