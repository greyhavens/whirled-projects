package vampire.debug
{
    import com.whirled.contrib.simplegame.SimObject;
    import com.whirled.contrib.simplegame.util.Rand;

    import vampire.client.ClientContext;
    import vampire.client.events.LineageUpdatedEvent;
    import vampire.data.Lineage;
    import vampire.server.GameServer;

public class LineageDebug extends SimObject
{

    protected var _localdt :Number = 0;

    override protected function update (dt:Number) :void
    {
        _localdt += dt;

        if (_localdt >= GameServer.SERVER_TICK_UPDATE_MILLISECONDS/1000.0) {
            _localdt = 0;
            trace("adding random players");
            addRandomPlayersToLineage(ClientContext.model.lineage, MAX_LINEAGE_NODES_WRITTEN_TO_A_ROOM_PROPS_PER_UPDATE);

            var msg :LineageUpdatedEvent = new LineageUpdatedEvent(ClientContext.model.lineage, ClientContext.ourPlayerId);
            ClientContext.model.dispatchEvent(msg);
        }
    }

    public static function addRandomPlayersToLineage (lineage :Lineage, additions :int) :void
    {
        var ii :int;

        var meanChildrenPerSire :Number = 6;

        if (lineage.size() == 0) {
//            trace("Adding player 1 since the linage is empty");
            lineage.setPlayerSire(1, 0);
            lineage.setPlayerName(1, "" + 1);
//            trace("lineage.playerIds=" + lineage.playerIds);
        }

        //Create the array of players
        var playerIds :Array = [];
        for (ii = lineage.playerIds.length + 1; ii <= lineage.playerIds.length + 1 + additions; ii++) {
            playerIds.push(ii);
        }
        var playersRemaining :Array = playerIds.slice();

        var toAddChildren :Array = lineage.playerIds.slice();
//        trace("toAddChildren=" + toAddChildren);
        if (toAddChildren.length == 0) {
            trace("WTF");
            return;
        }

        while (playersRemaining.length > 0) {
            var newAdditions :Array = [];

            for each (var newParent :int in toAddChildren) {
//                trace("Adding children to " + newParent);
                for (ii = 0; ii < meanChildrenPerSire; ii++) {
                    if (playersRemaining.length > 0) {
                        var newChild :int = playersRemaining.shift()
                        newAdditions.push(newChild);

                        var newSire :int = 0;
                        if (lineage.playerIds.length > 10 && Rand.nextNumber(0) < 0.2) {
                            var randomSire :int = Rand.nextIntRange(1, lineage.playerIds.length, 0);
                            newSire = randomSire;
                        }
                        else {
                            newSire = newParent;
                        }
//                        trace("Debug, setting " + newChild + " sire=" + newSire);
                        lineage.setPlayerSire(newChild, newSire);
                        lineage.setPlayerName(newChild, "" + newChild);


                    }
                }
            }
            toAddChildren = newAdditions;
        }
    }

    public static function testLineage () :void
    {
        var lineage :Lineage = createBasicLineage(4, 6);

//        if (lineage.getAllDescendentsCount(lineage.getProgenyIds(1)[0])
        trace(lineage);
        trace("Descendents of 2: " + lineage.getAllDescendents(2) + ", length=" + lineage.getAllDescendents(2).length);
        trace("Descendents count of 2: " + lineage.getAllDescendentsCount(2));
        trace(lineage.getAllDescendents(2).length);

        trace("Descendents of 8: " + lineage.getAllDescendents(8));
        trace("Descendents count of 8: " + lineage.getAllDescendentsCount(8));
    }

    public static function createBasicLineage (levels :int, childrenPerNode :int, maxNodes :int = 2000) :Lineage
    {
        var lineage :Lineage = new Lineage();

        var currentPlayerId :int = 1;
        lineage.setPlayerSire(currentPlayerId, 0);
        lineage.setPlayerName(currentPlayerId, "" + currentPlayerId);

        var currentParents :Array = [currentPlayerId];

        for (var level :int = 1; level < levels; ++level) {
            var parentsForThisInteration :Array = currentParents.slice();
            currentParents.splice(0);
            for each (var parent :int in parentsForThisInteration) {
                for (var child :int = 0; child < childrenPerNode; ++child) {
                    if (currentPlayerId < maxNodes) {
                        currentPlayerId++;
                        currentParents.push(currentPlayerId);
                        lineage.setPlayerSire(currentPlayerId, parent);
                        lineage.setPlayerName(currentPlayerId, generateRandomString(10));
//                        lineage.setPlayerName(currentPlayerId, "" + currentPlayerId);
                    }
                }
            }
        }

        return lineage;
    }

    protected static function generateRandomString(newLength:uint = 1, userAlphabet:String = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"):String
    {
        var alphabet:Array = userAlphabet.split("");
        var alphabetLength:int = alphabet.length;
        var randomLetters:String = "";
        for (var i:uint = 0; i < newLength; i++){
            randomLetters += alphabet[int(Math.floor(Math.random() * alphabetLength))];
        }
        return randomLetters;
    }
    public static const MAX_LINEAGE_NODES_WRITTEN_TO_A_ROOM_PROPS_PER_UPDATE :int = 40;
}
}