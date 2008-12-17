package flashmob.net {

import flash.utils.ByteArray;

public interface Message
{
    function fromBytes (bytes :ByteArray) :void;
    function toBytes (bytes :ByteArray = null) :ByteArray;
}

}
