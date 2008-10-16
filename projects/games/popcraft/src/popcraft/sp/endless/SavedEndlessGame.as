package popcraft.sp.endless {

import com.threerings.util.Assert;

import flash.utils.ByteArray;

import popcraft.*;

public class SavedEndlessGame
{
    public var mapIndex :int;
    public var score :int;
    public var multiplier :int;
    public var health :int = 0;

    public static function create (mapIndex :int, score :int, multiplier :int, health :int)
        :SavedEndlessGame
    {
        var save :SavedEndlessGame = new SavedEndlessGame();
        save.mapIndex = mapIndex;
        save.score = score;
        save.multiplier = multiplier;
        save.health = health;
        return save;
    }

    public function isEqual (rhs :SavedEndlessGame) :Boolean
    {
        return (mapIndex == rhs.mapIndex &&
            score == rhs.score &&
            multiplier == rhs.multiplier &&
            health == rhs.health);
    }

    public function fromBytes (ba :ByteArray) :void
    {
        mapIndex = ba.readShort();
        score = ba.readInt();
        multiplier = ba.readByte();
        health = ba.readShort();
    }

    public function toBytes (ba :ByteArray) :void
    {
        ba.writeShort(mapIndex);
        ba.writeInt(score);
        ba.writeByte(multiplier);
        ba.writeShort(health);
    }

    public static function max (a :SavedEndlessGame, b :SavedEndlessGame) :SavedEndlessGame
    {
        Assert.isTrue(a.mapIndex == b.mapIndex);

        var maxGame :SavedEndlessGame = new SavedEndlessGame();
        maxGame.mapIndex = a.mapIndex;
        maxGame.score = Math.max(a.score, b.score);
        maxGame.multiplier = Math.max(a.multiplier, b.multiplier);
        maxGame.health = Math.max(a.health, b.health);
        return maxGame;
    }

}

}
