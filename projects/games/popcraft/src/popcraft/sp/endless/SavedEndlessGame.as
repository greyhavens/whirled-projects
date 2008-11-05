package popcraft.sp.endless {

import com.threerings.util.ArrayUtil;
import com.threerings.util.Assert;

import flash.utils.ByteArray;

import popcraft.*;

public class SavedEndlessGame
{
    public var mapIndex :int;
    public var resourceScore :int;
    public var damageScore :int;
    public var multiplier :int = 1;
    public var health :int;
    public var spells :Array = ArrayUtil.create(NUM_SPELLS, 0);

    public function get totalScore () :int
    {
        return resourceScore + damageScore;
    }

    public static function create (mapIndex :int, resourceScore :int, damageScore :int,
        multiplier :int, health :int, spells :Array = null)
        :SavedEndlessGame
    {
        var save :SavedEndlessGame = new SavedEndlessGame();
        save.mapIndex = mapIndex;
        save.resourceScore = resourceScore;
        save.damageScore = damageScore;
        save.multiplier = multiplier;
        save.health = health;
        if (spells != null) {
            save.spells = spells.slice();
        }
        return save;
    }

    public function isEqual (rhs :SavedEndlessGame) :Boolean
    {
        return (mapIndex == rhs.mapIndex &&
            resourceScore == rhs.resourceScore &&
            damageScore == rhs.damageScore &&
            multiplier == rhs.multiplier &&
            health == rhs.health &&
            spellsEqual(rhs));
    }

    protected function spellsEqual (rhs :SavedEndlessGame) :Boolean
    {
        for (var spellType :uint = 0; spellType < NUM_SPELLS; ++spellType) {
            if (spells[spellType] != rhs.spells[spellType]) {
                return false;
            }
        }

        return true;
    }

    public function fromBytes (ba :ByteArray) :void
    {
        checkCookieValidity();

        mapIndex = ba.readShort();
        resourceScore = ba.readInt();
        damageScore = ba.readInt();
        multiplier = ba.readByte();
        health = ba.readShort();

        for (var spellType :uint = 0; spellType < NUM_SPELLS; ++spellType) {
            spells[spellType] = ba.readByte();
        }
    }

    public function toBytes (ba :ByteArray = null) :ByteArray
    {
        checkCookieValidity();

        ba = (ba != null ? ba : new ByteArray());

        ba.writeShort(mapIndex);
        ba.writeInt(resourceScore);
        ba.writeInt(damageScore);
        ba.writeByte(multiplier);
        ba.writeShort(health);

        for each (var spellCount :int in spells) {
            ba.writeByte(spellCount);
        }

        return ba;
    }

    public static function max (a :SavedEndlessGame, b :SavedEndlessGame) :SavedEndlessGame
    {
        Assert.isTrue(a.mapIndex == b.mapIndex);

        var maxGame :SavedEndlessGame = new SavedEndlessGame();
        maxGame.mapIndex = a.mapIndex;
        maxGame.resourceScore = Math.max(a.resourceScore, b.resourceScore);
        maxGame.damageScore = Math.max(a.damageScore, b.damageScore);
        maxGame.multiplier = Math.max(a.multiplier, b.multiplier);
        maxGame.health = Math.max(a.health, b.health);

        for (var spellType :int = 0; spellType < NUM_SPELLS; ++spellType) {
            maxGame.spells[spellType] = Math.max(a.spells[spellType], b.spells[spellType]);
        }

        return maxGame;
    }

    protected static function checkCookieValidity () :void
    {
        if (NUM_SPELLS != Constants.CASTABLE_SPELL_TYPE__LIMIT) {
            throw new Error("A new castable spell was added; update EndlessLevelManager's cookie logic");
        }
    }

    protected static const NUM_SPELLS :int = 3;
}

}
