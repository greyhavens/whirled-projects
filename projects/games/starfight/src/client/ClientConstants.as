package client {

public class ClientConstants
{
    public static const SHIP_RSRC_WASP :WaspShipTypeResources = new WaspShipTypeResources();
    public static const SHIP_RSRC_RHINO :RhinoShipTypeResources = new RhinoShipTypeResources();
    public static const SHIP_RSRC_SAUCER :SaucerShipTypeResources = new SaucerShipTypeResources();
    public static const SHIP_RSRC_RAPTOR :RaptorShipTypeResources = new RaptorShipTypeResources();

    /** The different available types of ships. */
    public static const SHIP_RSRC_CLASSES :Array = [
        SHIP_RSRC_WASP,
        SHIP_RSRC_RHINO,
        SHIP_RSRC_SAUCER,
        SHIP_RSRC_RAPTOR,
    ];

    public static function getShipResources (index :int) :ShipTypeResources
    {
        return (index >= 0 && index < SHIP_RSRC_CLASSES.length ? SHIP_RSRC_CLASSES[index] : null);
    }
}

}
