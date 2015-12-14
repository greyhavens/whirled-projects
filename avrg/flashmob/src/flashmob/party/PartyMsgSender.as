package flashmob.party {

import com.whirled.net.MessageSubControl;

public class PartyMsgSender
    implements MessageSubControl
{
    public function PartyMsgSender (partyId :int, msgCtrl :MessageSubControl)
    {
        _partyId = partyId;
        _nameUtil = new NameUtil(_partyId);
        _msgCtrl = msgCtrl;
    }

    public function sendMessage (name :String, value :Object = null) :void
    {
        _msgCtrl.sendMessage(_nameUtil.encodeName(name), value);
    }

    protected var _partyId :int;
    protected var _nameUtil :NameUtil;
    protected var _msgCtrl :MessageSubControl;
}

}
