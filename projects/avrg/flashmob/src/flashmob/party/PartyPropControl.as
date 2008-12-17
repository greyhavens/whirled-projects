package flashmob.party {

import com.whirled.net.PropertySubControl;

public class PartyPropControl extends PartyPropGetControl
    implements PropertySubControl
{
    public function PartyPropControl (partyId :int, propCtrl :PropertySubControl)
    {
        super(partyId, propCtrl);
        _propCtrl = propCtrl;
    }

    public function set (propName :String, value :Object, immediate :Boolean = false) :void
    {
        _propCtrl.set(_nameUtil.encodeName(propName), value, immediate);
    }

    public function setAt (propName :String, index :int, value :Object, immediate :Boolean = false)
        :void
    {
        _propCtrl.setAt(_nameUtil.encodeName(propName), index, value, immediate);
    }

    public function setIn (propName :String, key :int, value :Object, immediate :Boolean = false)
        :void
    {
        _propCtrl.setIn(_nameUtil.encodeName(propName), key, value, immediate);
    }

    protected var _propCtrl :PropertySubControl;
}

}
