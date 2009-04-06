package vampire.data
{
import com.threerings.util.HashMap;
import com.threerings.util.HashSet;
import com.threerings.util.Log;
import com.threerings.util.StringBuilder;
import com.whirled.contrib.simplegame.SimObject;

import flash.utils.ByteArray;



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

        //Ignore if we already have the given sire
        if (getSireId(playerId) == sireId) {
            return;
        }

        //Id the sire is our descendent, disallow, since that would create a loop.
        var oldDescendents :HashSet = getAllProgenyAndDescendents(playerId);
        if (oldDescendents.contains(sireId)) {
            log.error("setPlayerSire, sire is already a descendent. Not changing.",  "playerId", playerId, "sireId", sireId);
            return;
        }

        //If the player is new, add the new player node.
        if (!_playerId2Node.containsKey(playerId)) {
            _playerId2Node.put(playerId, new Node(playerId));
        }

        //If the sire doesn't exist, leave now.
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
        sire.childrenIds.add(player.hashCode());
    }

    protected function getNode(playerId :int) :Node
    {
        if (_playerId2Node.containsKey(playerId)) {
            return _playerId2Node.get(playerId) as Node;
        }
        return null;
    }



    /**
    * Given only sire data, recompute the progeny
    */
    public function recomputeProgeny() :void
    {
        _playerId2Node.forEach(function(playerId :int, node :Node) :void {
            node.childrenIds.clear();
        });

        _playerId2Node.forEach(function(playerId :int, node :Node) :void {
            if (node.parent != null) {
                node.parent.childrenIds.add(playerId);
            }
        });
    }

    protected function getMapOfSiresAndDescendents(playerId :int, results :HashMap = null) :HashMap
    {
        if (results == null) {
            results = new HashMap();
        }

        var descendents :HashSet = getAllProgenyAndDescendents(playerId);
        var sires :HashSet = getAllSiresAndGrandSires(playerId);

        addHashData(descendents, results);
        addHashData(sires, results);

        results.put(playerId, [getPlayerName(playerId), getSireId(playerId)]);

        function addHashData(playerData :HashSet, results :HashMap) :void
        {
            if (playerData == null || results == null) {
                return;
            }
            playerData.forEach(function(playerIdForSubTree :int) :void {
                if (!results.containsKey(playerIdForSubTree)) {
                    results.put(playerIdForSubTree, [getPlayerName(playerIdForSubTree), getSireId(playerIdForSubTree)]);
                }
            });
        }


        return results;
    }

    public function getAllProgenyAndDescendents(playerId :int, descendents :HashSet = null) :HashSet
    {
        if (descendents == null) {
            descendents = new HashSet();
        }

        var player :Node = _playerId2Node.get(playerId) as Node;

        if (player == null) {
            return descendents;
        }

        var descendentSet :HashSet = player.childrenIds;
        if (descendentSet != null) {
            descendentSet.forEach(function(descendentId :int) :void
                {
                    if (!descendents.contains(descendentId)) {
                        descendents.add(descendentId);
                        getAllProgenyAndDescendents(descendentId, descendents);
                    }
                });
        }

        return descendents;
    }

    public function getSireId(playerId :int) :int
    {
        var player :Node = _playerId2Node.get(playerId) as Node;
        if (player != null && player.parent != null) {
            return player.parent.hashCode();
        }
        return 0;
    }

    public function getProgenyIds(playerId :int) :HashSet
    {
        var player :Node = _playerId2Node.get(playerId) as Node;
        if (player != null) {
            return player.childrenIds;
        }
        return new HashSet();
    }

    public function getProgenyCount(playerId :int) :int
    {
        var player :Node = _playerId2Node.get(playerId) as Node;
        if (player != null) {
            return player.childrenIds.size();
        }
        return 0;
    }

    public function getSireProgressionCount(playerId :int) :int
    {
        return getAllSiresAndGrandSires(playerId).size();
    }

    /**
    * Not returned in any particular order.
    */
    public function getAllSiresAndGrandSires(playerId :int) :HashSet
    {
        var sires :HashSet = new HashSet();

        var parentId :int = getSireId(playerId);
        while(parentId > 0) {
            sires.add(parentId);
            parentId = getSireId(parentId);
            if (sires.contains(parentId)) {
                log.error("getAllSiresAndGrandSires, circle found.");
                break;
            }
        }
        return sires;
    }

    public function isSireExisting(playerId :int) :Boolean
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

    public function isPossessingProgeny(playerId :int) :Boolean
    {
        var player :Node = _playerId2Node.get(playerId) as Node;
        if (player != null) {
            return player.childrenIds.size() > 0;
        }
        return false;
    }

    /**
    * Checks if ubervamp is a grandsire
    *
    */
    public function isMemberOfLineage(playerId :int) :Boolean
    {
        if (VConstants.LOCAL_DEBUG_MODE) {
            trace("here, playerid=" + playerId);
            if (playerId == 2) {
                return true;
            }
            return getAllSiresAndGrandSires(playerId).contains(2);
        }

        if (Logic.isProgenitor(playerId)) {
            return true;
        }
        return getAllSiresAndGrandSires(playerId).contains(VConstants.UBER_VAMP_ID);
    }

    public function toStringOld() :String
    {
        log.debug(" toString(), playerIds=" + playerIds);
        var sb :StringBuilder = new StringBuilder("\n Lineage, playerIds=" + playerIds);
        for each(var playerId :int in playerIds) {
            var player :Node = _playerId2Node.get(playerId) as Node;
            sb.append("\n");
            sb.append(".      id=" + playerId + ", name= " + (isPlayerName(playerId) ? getPlayerName(playerId) : "no key"));
            sb.append("        sire=" + getSireId(playerId));
            if (isPossessingProgeny(playerId)) {
                sb.append("         progeny=" + player.childrenIds.toArray());
                sb.append("         descendents=" + getAllProgenyAndDescendents(playerId).toArray());
            }
        }
        return sb.toString();

    }

    override public function toString() :String
    {
        var sb :StringBuilder = new StringBuilder(" Lineage:");
        for each(var playerId :int in playerIds) {
            var player :Node = _playerId2Node.get(playerId) as Node;
            sb.append(" (" + playerId + ", " + (isPlayerName(playerId) ? getPlayerName(playerId) : "no name"));
            sb.append(", " + getSireId(playerId) + ")");
        }
        return sb.toString();
    }

    public function fromBytes (bytes :ByteArray) :void
    {
        _playerId2Node.clear();
        _playerId2Name.clear();

        var compressSize :Number = bytes.length;
        bytes.uncompress();

        bytes.position = 0;
        var length :int = bytes.readInt();
        for(var i :int = 0; i < length; i++) {
            var playerId :int = bytes.readInt();
            var sireid :int = bytes.readInt();
            setPlayerSire(playerId, sireid);

            var playerName :String = bytes.readUTF();
            _playerId2Name.put(playerId, playerName);
        }

        log.debug("Lineage compress", "before", bytes.length, "after", compressSize, "%", (compressSize*100/bytes.length));
    }

    public function toBytesOld () :ByteArray
    {
        var bytes :ByteArray = new ByteArray();

        var players :Array = _playerId2Node.keys();
        bytes.writeInt(players.length);

        for each(var playerid :int in players) {
            bytes.writeInt(playerid);
            bytes.writeInt(getSireId(playerid));
            bytes.writeUTF(_playerId2Name.containsKey(playerid) ?  _playerId2Name.get(playerid) :"");
        }
        bytes.compress();//Yes, compress.  Watch out on the client, that they don't uncompress it twice.
        return bytes;
    }
    public function get playerIds() :Array
    {
        return _playerId2Node.keys();
    }







//    protected function loadSireIdFromDB(playerId :int) :int
//    {
//        log.debug("loadSireIdFromDB(" + playerId + ")");
//        var sireId :int = -1;
//        ServerContext.ctrl.loadOfflinePlayer(playerId,
//            function (props :OfflinePlayerPropertyControl) :void {
//                sireId = int(props.get(Codes.PLAYER_PROP_PREFIX_SIRE));
//                setPlayerSire(playerId, sireId);
//                _changedSoUpdateRooms = true;
//            },
//            function (failureCause :Object) :void {
//                log.warning("Eek! Sending message to offline player failed!", "cause", failureCause); ;
//            });
//        log.debug(" loadSireIdFromDB(" + playerId + "), sireId=" + sireId);
//        return sireId;
//    }



    protected function getAllPlayerIdsConnected(playerId :int) :HashSet
    {
        var allConnected :HashSet = new HashSet();
        var sires :HashSet = getAllSiresAndGrandSires(playerId);
        var descendents :HashSet = getAllProgenyAndDescendents(playerId);
        sires.forEach(function(sireId :int, ...ignored) :void {
            allConnected.add(sireId);
        });
        descendents.forEach(function(descendentId :int, ...ignored) :void {
            allConnected.add(descendentId);
        });
        return allConnected;
    }

    public function setPlayerName(playerId :int, name :String) :Boolean
    {
        if (name != null && name != "") {
            _playerId2Name.put(playerId, name);
            log.debug(" setPlayerName()", "playerId", playerId, "name", name);
            return true;
        }
        log.debug(" setPlayerName(), FAILED", "playerId", playerId, "name", name);
        return false;
    }

    protected function getPlayerName(playerId :int) :String
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

        return getAllSiresAndGrandSires(playerId).contains(queryPlayerId) ||
            getAllProgenyAndDescendents(playerId).contains(queryPlayerId);
    }

    public function isProgenyOf(maybeProgeny :int, maybeSire :int) :Boolean
    {
        var sire :Node = _playerId2Node.get(maybeSire) as Node;
        if (sire != null) {
            return sire.childrenIds.contains(maybeProgeny);
        }
        return false;
    }





    protected var _playerId2Node :HashMap = new HashMap();
    public var _playerId2Name :HashMap = new HashMap();





    protected static const log :Log = Log.getLog(Lineage);
}
}
    import com.threerings.util.Hashable;
    import com.threerings.util.HashSet;



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
        return "Node " + hashCode() + ", sire=" + (parent != null ? parent.hashCode() : "none") + ", children=" + childrenIds.toArray();
    }



    protected var _hash :int;
    public var parent :Node;
    public var childrenIds :HashSet = new HashSet();
}