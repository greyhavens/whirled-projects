package flashmob.party {

import com.whirled.net.MessageReceivedEvent;

import flash.events.EventDispatcher;

import flashmob.party.NameUtil;

public class PartyMessageAdapter extends EventDispatcher
{
    public function PartyMessageAdapter (partyId :int, msgDispatcher :EventDispatcher)
    {
        _partyId = partyId;
        _nameUtil = new NameUtil(_partyId);
        _msgDispatcher = msgDispatcher;
        _msgDispatcher.addEventListener(MessageReceivedEvent.MESSAGE_RECEIVED, onMsgReceived);
    }

    public function shutdown () :void
    {
        _msgDispatcher.removeEventListener(MessageReceivedEvent.MESSAGE_RECEIVED, onMsgReceived);
    }

    protected function onMsgReceived (e :MessageReceivedEvent) :void
    {
        dispatchEvent(new MessageReceivedEvent(
            _nameUtil.encodeName(e.name),
            e.value,
            e.senderId));
    }

    protected var _partyId :int;
    protected var _nameUtil :NameUtil;
    protected var _msgDispatcher :EventDispatcher;
}

}
