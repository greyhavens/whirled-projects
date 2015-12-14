package flashmob.party {

public class NameUtil
{
    public function NameUtil (partyId :int)
    {
        _partyId = partyId;
        _prefix = String(partyId) + SEPARATOR;
    }

    public function encodeName (name :String) :String
    {
        return _prefix + name;
    }

    public function decodeName (name :String) :String
    {
        return name.substr(_prefix.length);
    }

    public function isPartyName (name :String) :Boolean
    {
        return (name.substr(0, _prefix.length) == _prefix);
    }

    protected var _partyId :int;
    protected var _prefix :String;

    protected static const SEPARATOR :String = ":";
}

}
