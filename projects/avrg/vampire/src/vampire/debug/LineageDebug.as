package vampire.debug
{
    import com.whirled.contrib.simplegame.SimObject;
    import com.whirled.contrib.simplegame.util.Rand;

    import vampire.client.ClientContext;
    import vampire.client.events.LineageUpdatedEvent;
    import vampire.data.Lineage;
    import vampire.server.GameServer;
    import vampire.server.LineageServer;

public class LineageDebug extends SimObject
{

    protected var _localdt :Number = 0;

    override protected function update (dt:Number) :void
    {
        _localdt += dt;

        if (_localdt >= GameServer.SERVER_TICK_UPDATE_MILLISECONDS/1000.0) {
            _localdt = 0;
            trace("adding random players");
            addRandomPlayersToLineage(ClientContext.model.lineage, LineageServer.MAX_LINEAGE_NODES_WRITTEN_TO_A_ROOM_PROPS_PER_UPDATE);

            var msg :LineageUpdatedEvent = new LineageUpdatedEvent(ClientContext.model.lineage, ClientContext.ourPlayerId);
            ClientContext.model.dispatchEvent(msg);
        }
    }

    public static function addRandomPlayersToLineage (lineage :Lineage, additions :int) :void
    {
        var ii :int;

        var meanChildrenPerSire :Number = 6;

        //Create the array of players
        var playerIds :Array = [];
        for (ii = lineage.playerIds.length + 1; ii <= lineage.playerIds.length + 1 + additions; ii++) {
            playerIds.push(ii);
        }
        var playersRemaining :Array = playerIds.slice();

        var toAddChildren :Array = [1];
        lineage.setPlayerName(1, "" + 1);

        while (playersRemaining.length > 0) {
            var newAdditions :Array = [];

            for each (var newParent :int in toAddChildren) {
                for (ii = 0; ii < meanChildrenPerSire; ii++) {
                    if (playersRemaining.length > 0) {
                        var newChild :int = playersRemaining.shift()
                        newAdditions.push(newChild);

                        if (lineage.playerIds.length > 10 && Rand.nextNumber(0) < 0.2) {
                            var randomSire :int = Rand.nextIntRange(1, lineage.playerIds.length, 0);
                            lineage.setPlayerSire(newChild, randomSire);
                            lineage.setPlayerName(newChild, "" + newChild);
                        }
                        else {
                            lineage.setPlayerSire(newChild, newParent);
                            lineage.setPlayerName(newChild, "" + newChild);
                        }
                    }
                }
            }
            toAddChildren = newAdditions;
        }
    }

}
}