package vampire.data
{
    import com.threerings.util.HashMap;
    import com.threerings.util.StringBuilder;

    import flash.utils.IDataInput;
    import flash.utils.IDataOutput;
    import flash.utils.getDefinitionByName;

/**
 * A player centered subset of the Lineage.
 * For each grandchild, it contains the number of great-grandchild and further descendents,
 * but not the actual data on those further descendents.
 */
public class LineageSubSet extends Lineage
{
    public function LineageSubSet()
    {
    }

    public function fromLineage (fullLineage :Lineage, playerCenter :int) :LineageSubSet
    {
        var lineage :LineageSubSet = this;
        _centerPlayerId = playerCenter;

        var players2Add :Array = [playerCenter];


        players2Add = players2Add.concat(fullLineage.getAllSiresAndGrandSires(playerCenter, 2));
        players2Add = players2Add.concat(fullLineage.getAllDescendents(playerCenter, null, 2));

        for each (var id :int in players2Add) {
            lineage.setPlayerSire(id, fullLineage.getSireId(id));
            lineage.setPlayerName(id, fullLineage.getPlayerName(id));
        }

//        var fakePlayerIdInc :int = -1;
        //Add special children nodes showing the number of grandchildren
        for each (var f1 :int in fullLineage.getProgenyIds(playerCenter)) {
            for each (var f2 :int in fullLineage.getProgenyIds(f1)) {

                var greatGRandChildrenCount :int = fullLineage.getAllDescendentsCount(f2);

                _playerTotalDescendents.put(f2, greatGRandChildrenCount);
//                if (greatGRandChildrenCount > 0) {
//                    lineage.setPlayerSire(fakePlayerIdInc, f2);
//                    lineage.setPlayerName(fakePlayerIdInc, greatGRandChildrenCount + " descendents");
//                }
//                --fakePlayerIdInc;
            }
        }

        return lineage;
    }

    override public function getAllDescendentsCount (playerId :int, steps :int = -1) :int
    {
        if (_playerTotalDescendents.containsKey(playerId)) {
            return _playerTotalDescendents.get(playerId);
        }
        return super.getAllDescendentsCount(playerId, steps);
    }

    override public function readExternal (input:IDataInput) :void
    {
        super.readExternal(input);
        var length :int = input.readInt();
        _playerTotalDescendents.clear();
        for (var ii :int = 0; ii < length; ++ii) {
            var id :int = input.readInt();
            var childrenCount :int = input.readInt();
            _playerTotalDescendents.put(id, childrenCount);
        }
    }

    override public function writeExternal (output:IDataOutput) :void
    {
        super.writeExternal(output);
        var keys :Array = _playerTotalDescendents.keys();
        output.writeInt(keys.length);
        for each (var id :int in keys) {
            output.writeInt(id);
            output.writeInt(_playerTotalDescendents.get(id));
        }
    }

//    override public function toString () :String
//    {
//        var sb :StringBuilder = new StringBuilder("Center on: " + _centerPlayerId);
//        sb.append("\nChildren and grand children:");
//        var children :Array = getProgenyIds(_centerPlayerId);
//        for each (var childId :int in children) {
//            sb.append("\n" + childId + " ---");
//            var grandchildren :Array = getProgenyIds(childId);
//            for each (var grandChildId :int in grandchildren) {
//                sb.append(" " + grandChildId + " (" + getAllDescendentsCount(grandChildId) + ")");
//            }
//
//        }
//        return sb.toString();
//    }

    protected var _playerTotalDescendents :HashMap = new HashMap();
    protected var _centerPlayerId :int;

}
}