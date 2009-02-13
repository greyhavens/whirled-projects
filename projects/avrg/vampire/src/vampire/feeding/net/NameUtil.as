package vampire.feeding.net {

public class NameUtil
{
    public function NameUtil (gameId :int)
    {
        _gameId = gameId;
        _prefix = String(gameId) + SEPARATOR;
    }

    public function encodeName (name :String) :String
    {
        return _prefix + name;
    }

    public function decodeName (name :String) :String
    {
        return name.substr(_prefix.length);
    }

    public function isForGame (name :String) :Boolean
    {
        return (name.substr(0, _prefix.length) == _prefix);
    }

    protected var _gameId :int;
    protected var _prefix :String;

    protected static const SEPARATOR :String = ":";

}

}
