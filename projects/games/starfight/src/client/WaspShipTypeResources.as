package client {

import flash.media.Sound;

import net.ShipShotMessage;
import net.TorpedoShotMessage;

public class WaspShipTypeResources extends ShipTypeResources
{
    public var secondaryExplode :Class;
    public var secondarySound :Sound;
    public var secondaryExplodeSound :Sound;

    override protected function secondaryShotCreated (ship :Ship, message :ShipShotMessage) :void
    {
        var msg :TorpedoShotMessage = TorpedoShotMessage(message);
        ClientContext.game.playSoundAt(secondarySound, msg.x, msg.y);
    }

    override protected function get swfAsset () :Class
    {
        return SHIP;
    }

    override protected function successHandler () :void
    {
        super.successHandler();
        secondaryAnim = getLoadedClass("torpedo");
        secondaryExplode = getLoadedClass("torpedo_explosion");
        secondarySound = Sound(new (getLoadedClass("torpedo_shot.wav"))());
        secondaryExplodeSound = Sound(new (getLoadedClass("torpedo_explode.wav"))());
    }

    [Embed(source="../../rsrc/ships/wasp.swf", mimeType="application/octet-stream")]
    protected static const SHIP :Class;
}

}
