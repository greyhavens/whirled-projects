package flashmob.party {

import com.whirled.net.MessageSubControl;

import mx.utils.NameUtil;

public class PartyMessageControl
    implements MessageSubControl
{
    public function PartyMessageControl (partyId :int, msgCtrl :MessageSubControl)
    {
        _partyId = partyId;
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
