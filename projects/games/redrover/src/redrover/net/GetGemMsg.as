package redrover.net {

import com.threerings.util.ClassUtil;
import com.whirled.contrib.simplegame.net.Message;

import flash.utils.ByteArray;

public class GetGemMsg
    implements Message
{
    public var id :int;

    public function toBytes (ba :ByteArray = null) :ByteArray
    {
        if (ba == null) {
            ba = new ByteArray();
        }

        ba.writeInt(id);
    }

    public function fromBytes (ba :ByteArray) :void
    {
        id = ba.readInt();
    }

    public function get name () :String
    {
        ClassUtil.tinyClassName(this);
    }
}

}
