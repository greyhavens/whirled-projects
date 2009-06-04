package vampire.feeding.variant {

import com.whirled.contrib.simplegame.util.IntRange;
import com.whirled.contrib.simplegame.util.NumRange;
import com.whirled.contrib.simplegame.util.Rand;

import vampire.feeding.*;

public class Variant
{
    public static const CUSTOM_ACTIVITY :int = -1;
    public static const INVALID :int = 0;
    public static const NORMAL :int = 1;
    public static const CORRUPTION :int = 2;

    public static function getSettings (variant :int) :VariantSettings
    {
        var settings :VariantSettings;
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

        return settings;
    }

    public static function normal () :VariantSettings
    {
        var settings :VariantSettings = new VariantSettings();

        settings.gameTime =
            (Constants.DEBUG_SHORT_FEEDING_GAME ? Constants.DEBUG_SHORT_FEEDING_LENGTH : 60 * 2);
        settings.heartbeatTime = 4;
        settings.cursorSpeed = 70;
        settings.boardCreatesWhiteCells = true;
        settings.boardWhiteCellCreationTime = new NumRange(7, 9, Rand.STREAM_GAME);
        settings.boardWhiteCellCreationCount = new IntRange(1, 2, Rand.STREAM_GAME);
        settings.playerCreatesWhiteCells = false;
        settings.playerWhiteCellCreationTime = 0;
        settings.playerCarriesWhiteCells = true;
        settings.canDropWhiteCells = false;
        settings.scoreCorruption = false;
        settings.normalCellBirthTime = 0.5;
        settings.whiteCellBirthTime = 0.5;
        settings.whiteCellNormalTime = 8;
        settings.whiteCellExplodeTime = 7;
        settings.normalCellSpeed = 5;
        settings.whiteCellSpeed = 5;

        return settings;
    }

    public static function corruption () :VariantSettings
    {
        var settings :VariantSettings = new VariantSettings();

        settings.gameTime =
            (Constants.DEBUG_SHORT_FEEDING_GAME ? Constants.DEBUG_SHORT_FEEDING_LENGTH : 60 * 2);
        settings.heartbeatTime = 4;
        settings.cursorSpeed = 70;
        settings.boardCreatesWhiteCells = false;
        settings.boardWhiteCellCreationTime = new NumRange(7, 9, Rand.STREAM_GAME);
        settings.boardWhiteCellCreationCount = new IntRange(1, 2, Rand.STREAM_GAME);
        settings.playerCreatesWhiteCells = true;
        settings.playerWhiteCellCreationTime = 2;
        settings.playerCarriesWhiteCells = false;
        settings.canDropWhiteCells = true;
        settings.scoreCorruption = true;
        settings.normalCellBirthTime = 0.5;
        settings.whiteCellBirthTime = 0;
        settings.whiteCellNormalTime = 0;
        settings.whiteCellExplodeTime = 2;
        settings.normalCellSpeed = 8;
        settings.whiteCellSpeed = 0;

        return settings;
    }
}

}
