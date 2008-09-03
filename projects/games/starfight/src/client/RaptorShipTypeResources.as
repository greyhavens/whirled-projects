package client {

import flash.media.Sound;

public class RaptorShipTypeResources extends ShipTypeResources
{
    public var secondarySound :Sound;

    override protected function secondaryShotMessageSent (ship :Ship) :void
    {
        ClientContext.game.playSoundAt(secondarySound, ship.boardX, ship.boardY);
    }

    override protected function get swfAsset () :Class
    {
        return SHIP;
    }

    override protected function successHandler () :void
    {
        super.successHandler();
        secondarySound = Sound(new (getLoadedClass("shield.wav"))());
    }

    [Embed(source="../../rsrc/ships/raptor.swf", mimeType="application/octet-stream")]
    protected static const SHIP :Class;

}

}
