package flashmob.server {

public class MobGameController
{
    public function MobGameController (partyId :int)
    {
        _partyId = partyId;
    }

    public function shutdown () :void
    {

    }

    protected var _partyId :int;

}

}
