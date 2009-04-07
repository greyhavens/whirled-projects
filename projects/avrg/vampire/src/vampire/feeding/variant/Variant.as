package vampire.feeding.variant {

public class Variant
{
    public static const INVALID :int = 0;
    public static const NORMAL :int = 1;
    public static const CORRUPTION :int = 2;

    public static function getSettings (variant :int) :Settings
    {
        switch (variant) {
        case NORMAL:
            return normal();
        case CORRUPTION:
            return corruption();

        default:
            throw new Error("Unrecognized variant type " + variant);
        }
    }

    protected static function normal () :Settings
    {
        var settings :Settings = new Settings();

        settings.canDropWhiteCells = false;
        settings.scoreCorruption = false;

        return settings;
    }

    protected static function corruption () :Settings
    {
        var settings :Settings = new Settings();

        settings.canDropWhiteCells = true;
        settings.scoreCorruption = true;

        return settings;
    }
}

}
