package popcraft.sp {

import flash.utils.ByteArray;

public class LevelRecord
{
    public var unlocked :Boolean;
    public var score :int;

    public function toByteArray (ba :ByteArray) :void
    {
        ba.writeBoolean(unlocked);
        ba.writeInt(score);
    }

    public static function fromByteArray (ba :ByteArray) :LevelRecord
    {
        var lr :LevelRecord = new LevelRecord();

        lr.unlocked = ba.readBoolean();
        lr.score = ba.readInt();

        return lr;
    }

    public function toString () :String
    {
        return "unlocked: " + unlocked + " score: " + score;
    }
}

}
