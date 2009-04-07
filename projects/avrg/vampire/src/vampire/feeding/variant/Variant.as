package vampire.feeding.variant {

public class Variant
{
    public static const INVALID :int = 0;
    public static const NORMAL :int = 1;
    public static const CORRUPTION :int = 2;

    public static function getSettings (variant :int) :Settings
    {
        var settings :Settings;
        switch (variant) {
        case NORMAL:
            settings = normal();
            break;

        case CORRUPTION:
            settings = corruption();
            break;

        default:
            throw new Error("Unrecognized variant type " + variant);
        }

        settings.variant = variant;
        return settings;
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
