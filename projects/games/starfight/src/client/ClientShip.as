package client {

public class ClientShip extends Ship
{
    public function set shipView (view :ShipView) :void
    {
        _shipView = view;
    }

    protected var _shipView :ShipView;
}

}
