package vampire.data
{
import com.threerings.util.ArrayUtil;
import com.threerings.util.Equalable;
import com.threerings.util.HashMap;
import com.threerings.util.Log;
import com.threerings.util.StringBuilder;
import com.whirled.contrib.simplegame.SimObject;

import flash.utils.ByteArray;
import flash.utils.IDataInput;
import flash.utils.IDataOutput;
import flash.utils.IExternalizable;



/**
 * The hierarchy of vampires.  The server can query this to get player info.
 * Currently only returns information of online players.
 *
 * This is a simple DAG (directed acyclic graph).
 *
 * A player joins a room, or leaves, or changes sire, this computes the sub-graph containing all
 * players in the room and all their sires+progeny.  This is essentially a list of player-sire
 * connections (and player names).
 *
 * The hierachy is stored as a map of playerid -> [sireid, name]
 */


public class Lineage extends SimObject
    implements IExternalizable, Equalable
{
    public function setPlayerSire (playerId :int, sireId :int) :void
    {
        if (playerId == sireId) {
            log.error("setPlayerSire(" + playerId + ", sireId=" + sireId + "), same!!!");
            return;
        }

        if (playerId == 0) {
            log.error("setPlayerSire",  "playerId", playerId, "sireId", sireId);
            return;
        }

        //If the player is new, add the new player node.
        if (!_playerId2Node.containsKey(playerId)) {
            _playerId2Node.put(playerId, new Node(playerId));
        }

        //Ignore if we already have the given sire
        if (sireId != 0 && getSireId(playerId) == sireId) {
            trace("!!!!!");
            return;
        }

        //Id the sire is our descendent, disallow, since that would create a loop.
        var oldDescendents :Array = getAllDescendents(playerId);
        if (ArrayUtil.contains(oldDescendents, sireId)) {
            log.error("setPlayerSire, sire is already a descendent. Not changing.",  "playerId", playerId, "sireId", sireId);
            return;
        }

//        log.debug("setPlayerSire",  "playerId", playerId, "sireId", sireId);



        //If the sire is null, leave now.
        if (sireId == 0) {
            return;
        }
        //If the sire doesn't exist, add them.
        if (!_playerId2Node.containsKey(sireId)) {
            _playerId2Node.put(sireId, new Node(sireId));
        }

        var player :Node = _playerId2Node.get(playerId) as Node;

        var sire :Node = getNode(sireId);
        //Set the sire.
        player.parent = sire;
        sire.addChild(player.hashCode());
    }

    public function equals (other :Object) :Boolean
    {
        return false;
    }

    protected function getNode (playerId :int) :Node
    {
        if (_playerId2Node.containsKey(playerId)) {
            return _playerId2Node.get(playerId) as Node;
        }
        return null;
    }



    /**
    * Given only sire data, recompute the progeny
    */
    public function recomputeProgeny () :void
    {
        _playerId2Node.forEach(function(playerId :int, node :Node) :void {
            node.childrenIds.splice(0);
        });

        _playerId2Node.forEach(function(playerId :int, node :Node) :void {
            if (node.parent != null) {
                node.parent.childrenIds.push(playerId);
            }
        });
    }

    protected function getMapOfSiresAndDescendents (playerId :int, results :HashMap = null) :HashMap
    {
        if (results == null) {
            results = new HashMap();
        }

        var descendents :Array = getAllDescendents(playerId);
        var sires :Array = getAllSiresAndGrandSires(playerId);

        addHashData(descendents, results);
        addHashData(sires, results);

        results.put(playerId, [getPlayerName(playerId), getSireId(playerId)]);

        function addHashData(playerData :Array, results :HashMap) :void
        {
            if (playerData == null || results == null) {
                return;
            }
            playerData.forEach(function (playerIdForSubTree :int, ...ignored) :void {
                if (!results.containsKey(playerIdForSubTree)) {
                    results.put(playerIdForSubTree, [getPlayerName(playerIdForSubTree), getSireId(playerIdForSubTree)]);
                }
            });
        }


        return results;
    }

    public function getAllDescendents (playerId :int, descendents :Array = null, steps :int = -1) :Array
    {
//        log.debug("getAllDescendents", "playerId", playerId);
        if (descendents == null) {
            descendents = new Array();
        }


        if (steps == 0) {
            return descendents;
        }

        var player :Node = _playerId2Node.get(playerId) as Node;

        if (player == null) {
            return descendents;
        }

        var children :Array = player.childrenIds;
//        trace("getAllDescendents(" + playerId + "), children=" + children);

        if (children == null || children.length == 0) {
            return descendents;
        }

        for each (var child :int in children) {
            descendents.push(child);
        }
        steps--;
//        descendents.splice(descendents.length, 0, children);
//        trace("getAllDescendents(" + playerId + "), descendents=" + descendents);

        children.forEach(function(childId :int, ...ignored) :void {
            getAllDescendents(childId, descendents, steps);
        });
//        trace("getAllDescendents(" + playerId + "), after loop, descendents=" + descendents);

        return descendents;
    }

    public function getAllDescendentsCount (playerId :int,  steps :int = -1) :int
    {
        return getAllDescendents(playerId, null, steps).length;
    }
    public function getSireId (playerId :int) :int
    {
        var player :Node = _playerId2Node.get(playerId) as Node;
        if (player != null && player.parent != null) {
            return player.parent.hashCode();
        }
        return 0;
    }


    public function isLeaf (playerId :int) :Boolean
    {
        return getProgenyIds(playerId).length == 0;
    }

    public function getProgenyIds (playerId :int) :Array
    {
        var player :Node = _playerId2Node.get(playerId) as Node;
        if (player != null) {
            return player.childrenIds.slice();
        }
        return new Array();
    }

    public function getProgenyCount (playerId :int) :int
    {
        var player :Node = _playerId2Node.get(playerId) as Node;
        if (player != null) {
            return player.childrenIds.length;
        }
        return 0;
    }

    public function getNumberOfSiresAbove (playerId :int) :int
    {
        return getAllSiresAndGrandSires(playerId).length;
    }

    /**
    * Not returned in any particular order.
    */
    public function getAllSiresAndGrandSires (playerId :int, steps :int = -1) :Array
    {
        var sires :Array = new Array();
        var parentId :int = getSireId(playerId);
        var currentStep :int = 1;
        while (parentId > 0 && (steps <= 0 || currentStep <= steps )) {
            sires.push(parentId);
            parentId = getSireId(parentId);
            if (ArrayUtil.contains(sires, parentId)) {
                log.error("getAllSiresAndGrandSires, circle found.");
                break;
            }
            currentStep++;
        }
        return sires;
    }

    public function isSireExisting (playerId :int) :Boolean
    {
        if (playerId == VConstants.UBER_VAMP_ID) {
            return true;
        }

        var player :Node = _playerId2Node.get(playerId) as Node;
        if (player != null) {
            return player.parent != null && player.parent.hashCode() != 0;
        }
        return false;
    }

    public function isPossessingProgeny (playerId :int) :Boolean
    {
        var player :Node = _playerId2Node.get(playerId) as Node;
        if (player != null) {
            return player.childrenIds.length > 0;
        }
        return false;
    }

    /**
    * Checks if ubervamp is a grandsire
    *
    */
    public function isMemberOfLineage (playerId :int) :Boolean
    {
        if (VConstants.LOCAL_DEBUG_MODE) {
            trace("here, playerid=" + playerId);
            if (playerId == 2) {
                return true;
            }
            return ArrayUtil.contains(getAllSiresAndGrandSires(playerId), 2);
        }

        if (Logic.isProgenitor(playerId)) {
            return true;
        }
        return ArrayUtil.contains(getAllSiresAndGrandSires(playerId), VConstants.UBER_VAMP_ID);
    }

//    public function toStringOld () :String
//    {
//        log.debug(" toString(), playerIds=" + playerIds);
//        var sb :StringBuilder = new StringBuilder("\n Lineage, playerIds=" + playerIds);
//        for each(var playerId :int in playerIds) {
//            var player :Node = _playerId2Node.get(playerId) as Node;
//            sb.append("\n");
//            sb.append(".      id=" + playerId + ", name= " + (isPlayerName(playerId) ? getPlayerName(playerId) : "no key"));
//            sb.append("        sire=" + getSireId(playerId));
//            if (isPossessingProgeny(playerId)) {
//                sb.append("         progeny=" + player.childrenIds.toArray());
//                sb.append("         descendents=" + getAllDescendents(playerId).toArray());
//            }
//        }
//        return sb.toString();
//
//    }

//    override public function toStringOld2 () :String
//    {
//        var sb :StringBuilder = new StringBuilder(" Lineage:");
//        for each(var playerId :int in playerIds) {
//            var player :Node = _playerId2Node.get(playerId) as Node;
//            sb.append(" (" + playerId + ", " + (isPlayerName(playerId) ? getPlayerName(playerId) : "no name"));
//            sb.append(", " + getSireId(playerId) + ")");
//        }
//        return sb.toString();
//    }

    override public function toString () :String
    {
        var _centerPlayerId :int = 1;

        var sb :StringBuilder = new StringBuilder("Lineage, playerIds=" + playerIds);
        sb.append("\nCenter on: " + _centerPlayerId);
        sb.append("\nChildren and grand children:");
//        trace("Children ids of center " + _centerPlayerId + "=" + getProgenyIds(_centerPlayerId));
//        var children :Array = getProgenyIds(_centerPlayerId);
        var children :Array = getAllDescendents(_centerPlayerId);
        for each (var childId :int in children) {
            sb.append("\n" + childId + " -sire (" + getSireId(childId) + ")--");
            var grandchildren :Array = getProgenyIds(childId);
//            trace("Children ids of child " + childId + "=" + getProgenyIds(childId));
            for each (var grandChildId :int in grandchildren) {
                var greatGCCount :int = getAllDescendentsCount(grandChildId);
//                trace("Descendents count of " + grandChildId + "=" + getAllDescendentsCount(grandChildId));
                sb.append(" ," + grandChildId + (greatGCCount > 0 ? " (" + greatGCCount + ")" : ""));
            }

        }
        return sb.toString();
    }

    public function fromBytes (bytes :IDataInput) :void
    {

//        var compressSize :Number = bytes.length;
//        bytes.uncompress();

//        bytes.position = 0;
        readExternal(bytes);
//        log.debug("Lineage compress", "before", bytes.length, "after", compressSize, "%", (compressSize*100/bytes.length));
    }

    public function toBytes () :ByteArray
    {
        var bytes :ByteArray = new ByteArray();
        writeExternal(bytes);
//        bytes.compress();//Yes, compress.  Watch out on the client, that they don't uncompress it twice.
        return bytes;
    }
    public function get playerIds() :Array
    {
        return _playerId2Node.keys();
    }

    public function size () :int
    {
        return _playerId2Node.size();
    }

    protected function getAllPlayerIdsConnected(playerId :int) :Array
    {
        var allConnected :Array = [playerId];
        var sires :Array = getAllSiresAndGrandSires(playerId);
        var descendents :Array = getAllDescendents(playerId);

        allConnected.splice(allConnected.length, 0, sires);
        allConnected.splice(allConnected.length, 0, descendents);

        return allConnected;
    }

    public function setPlayerName(playerId :int, name :String) :Boolean
    {
        if (name != null && name != "") {
            _playerId2Name.put(playerId, name);
//            log.debug(" setPlayerName()", "playerId", playerId, "name", name);
            return true;
        }
        log.debug(" setPlayerName(), FAILED", "playerId", playerId, "name", name);
        return false;
    }

    public function getPlayerName(playerId :int) :String
    {
        return _playerId2Name.get(playerId);
    }


    public function isPlayer(playerId :int) :Boolean
    {
        return _playerId2Node.containsKey(playerId);
    }

    protected function isPlayerName(playerId :int) :Boolean
    {
        return _playerId2Name.containsKey(playerId) && _playerId2Name.get(playerId) != null && _playerId2Name.get(playerId) != "";
    }

    public function isPlayerSireOrDescendentOfPlayer(queryPlayerId :int, playerId :int) :Boolean
    {
        if (queryPlayerId == playerId) {
            log.warning("isPlayerSireOrDescendentOfPlayer(" + queryPlayerId + "==" + playerId + ")");
            return false;
        }

        return ArrayUtil.contains(getAllSiresAndGrandSires(playerId), queryPlayerId) ||
            ArrayUtil.contains(getAllDescendents(playerId), queryPlayerId);
    }

    public function isProgenyOf(maybeProgeny :int, maybeSire :int) :Boolean
    {
        var sire :Node = _playerId2Node.get(maybeSire) as Node;
        if (sire != null) {
            return ArrayUtil.contains(sire.childrenIds, maybeProgeny);
        }
        return false;
    }


    public function readExternal (input:IDataInput) :void
    {
        _playerId2Node.clear();
        _playerId2Name.clear();

        var length :int = input.readInt();
        for (var i :int = 0; i < length; i++) {
            var playerId :int = input.readInt();
            var sireid :int = input.readInt();
            setPlayerSire(playerId, sireid);

            var playerName :String = input.readUTF();
            _playerId2Name.put(playerId, playerName);
        }
    }

    public function writeExternal (output:IDataOutput) :void
    {
        var players :Array = _playerId2Node.keys();
        output.writeInt(players.length);

        for each(var playerid :int in players) {
            output.writeInt(playerid);
            output.writeInt(getSireId(playerid));
            output.writeUTF(_playerId2Name.containsKey(playerid) ?  _playerId2Name.get(playerid) :"");
        }
    }

    /**
    * Returns Lineage up to and including grandsire and grandchildren.
    */
    public function getSubLineage (playerId :int, levelsAbove :int = 1,
        levelsBelow :int = 2) :Lineage
    {
        var lineage :Lineage = new Lineage();;

        var players2Add :Array = [playerId];


        players2Add = players2Add.concat(getAllSiresAndGrandSires(playerId,
            levelsAbove));
        players2Add = players2Add.concat(getAllDescendents(playerId, null,
            levelsBelow));

        for each (var id :int in players2Add) {
            lineage.setPlayerSire(id, getSireId(id));
            lineage.setPlayerName(id, getPlayerName(id));
        }

        return lineage;
    }
    /**
    * Used for comparing the player lineages.  The player lineage should be equal to the
    * sublineage centered on the player with 2 levels down and one level up.
    *
    * @param lineageCenter The playerId in the center of the sublineage.
    */
    public function lineageEqualsInternalSubLineage (playerLineage :Lineage, playerId :int) :Boolean
    {
        if (!isPlayer(playerId)) {
            return false;
        }

        if (playerLineage.getSireId(playerId) != getSireId(playerId)) {
            return false;
        }

        var localProgeny :Array = getProgenyIds(playerId);
        var playerProgeny :Array = playerLineage.getProgenyIds(playerId);

        if (localProgeny.length != playerProgeny.length ||
            !ArrayUtil.equals(localProgeny, playerProgeny)) {
            return false;
        }

        for each (var childId :int in localProgeny) {
            var localGrandProgeny :Array = getProgenyIds(childId);
            var playerGrandProgeny :Array = playerLineage.getProgenyIds(childId);

            if (localGrandProgeny.length != playerGrandProgeny.length ||
                !ArrayUtil.equals(localGrandProgeny, playerGrandProgeny)) {
                return false;
            }
        }

        return true;
    }




    protected var _playerId2Node :HashMap = new HashMap();
    public var _playerId2Name :HashMap = new HashMap();





    protected static const log :Log = Log.getLog(Lineage);
}
}
import com.threerings.util.Hashable;
import flash.utils.getDefinitionByName;
import com.threerings.util.ArrayUtil;

class Node implements Hashable
{
    public function Node(playerid :int)
    {
        _hash = playerid;
    }

    public function hashCode () :int
    {
        return _hash;
    }

    public function equals (other :Object) :Boolean
    {
        return (other is Node) && (_hash === (other as Node)._hash);
    }

    public function toString() :String
    {
        return "Node " + hashCode() + ", sire=" + (parent != null ? parent.hashCode() : "none") + ", children=" + childrenIds;
    }

    public function addChild (playerId :int) :void
    {
        if (!ArrayUtil.contains(childrenIds, playerId)) {
            childrenIds.push(playerId);
        }
    }



    protected var _hash :int;
    public var parent :Node;
    public var childrenIds :Array = new Array();
}