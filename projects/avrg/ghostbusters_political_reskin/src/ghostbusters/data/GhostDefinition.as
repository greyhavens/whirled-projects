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
    //SKIN
//    public static const GHOST_PINCHER :String = "pinchy";
    public static const GHOST_MCCAIN :String = "mccain";
    public static const GHOST_PALIN :String = "palin";
    public static const GHOST_MUTANT :String = "mutant";

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
        //SKIN this is where the ghosts are defined.
        _definitions = new HashMap();
        //SKIN
//        addGhost(new GhostDefinition(GHOST_PINCHER, 72, 145, 80));
        addGhost(new GhostDefinition(GHOST_MCCAIN, 90, 85, 36));
        addGhost(new GhostDefinition(GHOST_PALIN, 68, 96, 33));//+1 sec (30 frames);
        addGhost(new GhostDefinition(GHOST_MUTANT, 76, 160, 61));
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

