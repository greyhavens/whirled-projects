//
// $Id$

package ghostbusters.data {

import com.threerings.util.HashMap;

/**
 * This shared class maps ghost-types to clip metadata; the client uses it to figure out how to
 * visualize the ghost and the server uses it to figure out how long the transition scenes are
 * for each clip.
 */
public class GhostDefinition
{
    public static const GHOST_PINCHER :String = "pinchy";
    public static const GHOST_DUCHESS :String = "duchess";
    public static const GHOST_WIDOW :String = "widow";
    public static const GHOST_DEMON :String = "demon";

    public static function getGhostIds () :Array
    {
        if (_definitions == null) {
            defineGhosts();
        }
        return _definitions.keys();
    }

    public static function getDefinition (id :String) :GhostDefinition
    {
        if (_definitions == null) {
            defineGhosts();
        }
        var def :GhostDefinition = _definitions.get(id);
        if (def == null) {
            throw new Error("Unknown ghost definition requested [id=" + id + "]");
        }
        return def;
    }

    public function GhostDefinition (id :String, appear :int, defeat :int, triumph :int)
    {
        _id = id;
        _appear = appear;
        _defeat = defeat;
        _triumph = triumph;
    }

    public function get id () :String
    {
        return _id;
    }

    public function get appearFrames () :int
    {
        return _appear;
    }

    public function get defeatFrames () :int
    {
        return _defeat;
    }

    public function get triumphFrames () :int
    {
        return _triumph;
    }

    protected var _id :String;
    protected var _appear :int;
    protected var _defeat :int;
    protected var _triumph :int;

    protected static function defineGhosts () :void
    {
        _definitions = new HashMap();

        addGhost(new GhostDefinition(GHOST_PINCHER, 72, 145, 80));
        addGhost(new GhostDefinition(GHOST_DUCHESS, 391, 114, 37));
        addGhost(new GhostDefinition(GHOST_WIDOW, 391, 114, 37));
        addGhost(new GhostDefinition(GHOST_DEMON, 108, 220, 55));
    }

    protected static function addGhost (def :GhostDefinition) :void
    {
        if (_definitions.containsKey(def.id)) {
            throw new Error("Redefinition of ghost [id=" + def.id + "]");
        }
        _definitions.put(def.id, def);
    }

    protected static var _definitions :HashMap = null;
}
}

