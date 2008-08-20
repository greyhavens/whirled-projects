package popcraft.sp.story {

import flash.utils.ByteArray;

public class LevelRecord
{
    public var unlocked :Boolean;
    public var expert :Boolean;
    public var score :int;

    public function isBetterThan (rhs :LevelRecord) :Boolean
    {
        if (unlocked && !rhs.unlocked) {
            return true;
        } else if (expert && !rhs.expert) {
            return true;
        } else if (score > rhs.score) {
            return true;
        }

        return false;
    }

    public function assign (rhs :LevelRecord) :void
    {
        unlocked = rhs.unlocked;
        expert = rhs.expert;
        score = rhs.score;
    }

    public function toByteArray (ba :ByteArray) :void
    {
        ba.writeBoolean(unlocked);
        ba.writeBoolean(expert);
        ba.writeInt(score);
    }

    public static function fromByteArray (ba :ByteArray) :LevelRecord
    {
        var lr :LevelRecord = new LevelRecord();

        lr.unlocked = ba.readBoolean();
        lr.expert = ba.readBoolean();
        lr.score = ba.readInt();

        return lr;
    }

    public function toString () :String
    {
        return "unlocked: " + unlocked + " score: " + score + " expert: " + expert;
    }
}

}
