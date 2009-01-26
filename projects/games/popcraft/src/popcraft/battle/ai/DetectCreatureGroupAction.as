package popcraft.battle.ai
{

import com.whirled.contrib.simplegame.SimObjectRef;

import popcraft.*;
import popcraft.game.*;
import popcraft.battle.CreatureUnit;

public class DetectCreatureGroupAction extends AITask
{
    public static const MSG_GROUPDETECTED :String = "CreatureGroupDetected";

    public function DetectCreatureGroupAction (name :String, groupSize :int, creaturePredicate :Function, groupPredicate :Function)
    {
        _name = name;
        _groupSize = groupSize;
        _creaturePred = creaturePredicate;
        _groupPred = groupPredicate;
    }

    override public function get name () :String
    {
        return name;
    }

    override public function update (dt :Number, thisCreature :CreatureUnit) :int
    {
        var creatureRefs :Array = GameCtx.netObjects.getObjectRefsInGroup(CreatureUnit.GROUP_NAME);

        var validCreatures :Array = [];

        // determine all valid creatures
        for each (var ref :SimObjectRef in creatureRefs) {
            var creature :CreatureUnit = ref.object as CreatureUnit;

            if (null != creature && thisCreature != creature && _creaturePred(thisCreature, creature)) {
                var creatureGroup :Array = findCreatureGroup(creatureRefs, creature, thisCreature);
                if (null != creatureGroup) {
                    sendParentMessage(MSG_GROUPDETECTED, creatureGroup);
                    break;
                }
            }
        }


        return AITaskStatus.COMPLETE;
    }

    protected function findCreatureGroup (allCreatures :Array, testCreature :CreatureUnit, thisCreature :CreatureUnit) :Array
    {
        var group :Array = [ testCreature ];

        for each (var ref :SimObjectRef in allCreatures) {
            var creature :CreatureUnit = ref.object as CreatureUnit;

            if (null != creature && testCreature != creature && thisCreature != creature && _groupPred(thisCreature, testCreature, creature)) {
                group.push(creature);

                if (group.length >= _groupSize) {
                    return group;
                }
            }
        }

        return null;
    }

    override public function clone () :AITask
    {
        return new DetectCreatureGroupAction(_name, _groupSize, _creaturePred, _groupPred);
    }

    protected var _name :String;
    protected var _groupSize :int;
    protected var _creaturePred :Function;
    protected var _groupPred :Function;
}

}
