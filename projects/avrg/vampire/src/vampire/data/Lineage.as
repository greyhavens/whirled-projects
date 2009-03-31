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
 * players in the room and all their sires+minions.  This is essentially a list of player-sire
 * connections (and player names).
 *
 * The hierachy is stored as a map of playerid -> [sireid, name]
 */


public class Lineage extends SimObject
{
    public function setPlayerSire(playerId :int, sireId :int) :void
    {
//        log.debug(Constants.DEBUG_MINION + " setPlayerSire(" + playerId + ", sireId=" + sireId + ")");

        if(playerId == sireId) {
            log.error("setPlayerSire(" + playerId + ", sireId=" + sireId + "), same!!!");
            return;
        }

        if(playerId < 1) {
            log.error("setPlayerSire(), playerId < 1",  "playerId", playerId, "sireId", sireId);
            return;
        }

        //Id the sire is our minion, disallow, since that would create a loop.
        var oldMinions :HashSet = getAllMinionsAndSubminions(playerId);
        if(oldMinions.contains(sireId)) {
            log.error("setPlayerSire, sire is already a minion. Not changing.",  "playerId", playerId, "sireId", sireId);
            return;
        }


        if(!_playerId2Node.containsKey(playerId)) {
            _playerId2Node.put(playerId, new Node(playerId));
        }

        if(sireId > 0 && !_playerId2Node.containsKey(sireId)) {
            _playerId2Node.put(sireId, new Node(sireId));
        }

        var player :Node = _playerId2Node.get(playerId) as Node;



//        log.debug(Constants.DEBUG_MINION + " setPlayerSire(" + playerId + ", sireId=" + sireId + "), _playerId2Node.keys=" + _playerId2Node.keys());

        var sire :Node = getNode(sireId);
        player.parent = sire;

        recomputeMinions();

        var sires :HashSet = getAllSiresAndGrandSires(sireId);

        if(sires.contains(playerId)) {
            log.warning(VConstants.DEBUG_MINION + " setPlayerSire(" + playerId + ", sireId=" + sireId + "), circle found, removeing all children");
            //Break the children
            player.childrenIds.forEach(function(minionId :int) :void {
                var child :Node = _playerId2Node.get(minionId) as Node;
                if(child != null) {
                    child.parent = null;

                }
            });

            sires = getAllSiresAndGrandSires(sireId);
            if(sires.contains(playerId)) {
                log.error(VConstants.DEBUG_MINION + " DAMMIT, found a loop, removed children, but loop remains WTF, hierarchy=" + toString());
            }

        }



    }

    protected function getNode(playerId :int) :Node
    {
        if(_playerId2Node.containsKey(playerId)) {
            return _playerId2Node.get(playerId) as Node;
        }
        return null;
    }



    /**
    * Given only sire data, recompute the minions
    */
    public function recomputeMinions() :void
    {
        _playerId2Node.forEach(function(playerId :int, node :Node) :void {
            node.childrenIds.clear();
        });

        _playerId2Node.forEach(function(playerId :int, node :Node) :void {
            if(node.parent != null) {
                node.parent.childrenIds.add(playerId);
            }
        });
    }

    protected function getMapOfSiresAndMinions(playerId :int, results :HashMap = null) :HashMap
    {
        if(results == null) {
            results = new HashMap();
        }

        var minions :HashSet = getAllMinionsAndSubminions(playerId);
        var sires :HashSet = getAllSiresAndGrandSires(playerId);

        addHashData(minions, results);
        addHashData(sires, results);

        results.put(playerId, [getPlayerName(playerId), getSireId(playerId)]);

        function addHashData(playerData :HashSet, results :HashMap) :void
        {
            if(playerData == null || results == null) {
                return;
            }
            playerData.forEach(function(playerIdForSubTree :int) :void {
                if(!results.containsKey(playerIdForSubTree)) {
                    results.put(playerIdForSubTree, [getPlayerName(playerIdForSubTree), getSireId(playerIdForSubTree)]);
                }
            });
        }


        return results;
    }

    public function getAllMinionsAndSubminions(playerId :int, minions :HashSet = null) :HashSet
    {
        if(minions == null) {
            minions = new HashSet();
        }

        var player :Node = _playerId2Node.get(playerId) as Node;

        if(player == null) {
            return minions;
        }

        var minionSet :HashSet = player.childrenIds;
        if(minionSet != null) {
            minionSet.forEach(function(minionId :int) :void
                {
                    if(!minions.contains(minionId)) {
                        minions.add(minionId);
                        getAllMinionsAndSubminions(minionId, minions);
                    }
                });
        }

        return minions;
    }

    public function getSireId(playerId :int) :int
    {
        var player :Node = _playerId2Node.get(playerId) as Node;
        if(player != null && player.parent != null) {
            return player.parent.hashCode();
        }
        return 0;
    }

    public function getMinionIds(playerId :int) :HashSet
    {
        var player :Node = _playerId2Node.get(playerId) as Node;
        if(player != null) {
            return player.childrenIds;
        }
        return new HashSet();
    }

    public function getMinionCount(playerId :int) :int
    {
        var player :Node = _playerId2Node.get(playerId) as Node;
        if(player != null) {
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
            if(sires.contains(parentId)) {
                log.error("getAllSiresAndGrandSires, circle found.");
                break;
            }
        }
        return sires;
    }

    public function isSireExisting(playerId :int) :Boolean
    {
        var player :Node = _playerId2Node.get(playerId) as Node;
        if(player != null) {
            return player.parent != null && player.parent.hashCode() != 0;
        }
        return false;
    }

    public function isHavingMinions(playerId :int) :Boolean
    {
        var player :Node = _playerId2Node.get(playerId) as Node;
        if(player != null) {
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
        log.debug(VConstants.DEBUG_MINION + " toString(), playerIds=" + playerIds);
        var sb :StringBuilder = new StringBuilder(VConstants.DEBUG_MINION + "\n MinionHierarchy, playerIds=" + playerIds);
        for each(var playerId :int in playerIds) {
            var player :Node = _playerId2Node.get(playerId) as Node;
            sb.append("\n");
            sb.append(".      id=" + playerId + ", name= " + (isPlayerName(playerId) ? getPlayerName(playerId) : "no key"));
            sb.append("        sire=" + getSireId(playerId));
            if(isHavingMinions(playerId)) {
                sb.append("         minions=" + player.childrenIds.toArray());
                sb.append("         subminions=" + getAllMinionsAndSubminions(playerId).toArray());
            }
        }
        return sb.toString();

    }

    override public function toString() :String
    {
        var sb :StringBuilder = new StringBuilder(" MinionHierarchy:");
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

        log.debug("MinionHierarchy compress", "before", bytes.length, "after", compressSize, "%", (compressSize*100/bytes.length));
    }

    public function toBytesOld () :ByteArray
    {
        var bytes :ByteArray = new ByteArray();

        var players :Array = _playerId2Node.keys();
        bytes.writeInt(players.length);

        for each(var playerid :int in players) {
            bytes.writeInt(playerid);
            bytes.writeInt(getSireId(playerid) );
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
        var minions :HashSet = getAllMinionsAndSubminions(playerId);
        sires.forEach(function(sireId :int, ...ignored) :void {
            allConnected.add(sireId);
        });
        minions.forEach(function(minionId :int, ...ignored) :void {
            allConnected.add(minionId);
        });
        return allConnected;
    }

    public function setPlayerName(playerId :int, name :String) :Boolean
    {
        if(name != null && name != "") {
            _playerId2Name.put(playerId, name);
            log.debug(VConstants.DEBUG_MINION + " setPlayerName()", "playerId", playerId, "name", name);
            return true;
        }
        log.debug(VConstants.DEBUG_MINION + " setPlayerName(), FAILED", "playerId", playerId, "name", name);
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

    public function isPlayerSireOrMinionOfPlayer(queryPlayerId :int, playerId :int) :Boolean
    {
        if(queryPlayerId == playerId) {
            log.warning("isPlayerSireOrMinionOfPlayer(" + queryPlayerId + "==" + playerId + ")");
            return false;
        }

        return getAllSiresAndGrandSires(playerId).contains(queryPlayerId) ||
            getAllMinionsAndSubminions(playerId).contains(queryPlayerId);
    }

    public function isMinionOf(maybeMinion :int, maybeSire :int) :Boolean
    {
        var sire :Node = _playerId2Node.get(maybeSire) as Node;
        if(sire != null) {
            return sire.childrenIds.contains(maybeMinion);
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