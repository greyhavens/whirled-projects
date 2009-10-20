package vampire.feeding.variant {

import com.threerings.flashbang.util.IntRange;
import com.threerings.flashbang.util.NumRange;

// Settings that can be modified by game variants
public class VariantSettings
{
    public var gameTime :Number;
    public var heartbeatTime :Number;

    public var cursorSpeed :Number;

    public var boardCreatesWhiteCells :Boolean;
    public var boardWhiteCellCreationTime :NumRange;
    public var boardWhiteCellCreationCount :IntRange;
    public var playerCreatesWhiteCells :Boolean;
    public var playerWhiteCellCreationTime :Number;
    public var playerCarriesWhiteCells :Boolean;
    public var canDropWhiteCells :Boolean;
    public var scoreCorruption :Boolean;
    public var normalCellBirthTime :Number;
    public var whiteCellBirthTime :Number;
    public var whiteCellNormalTime :Number;
    public var whiteCellExplodeTime :Number;
    public var normalCellSpeed :Number;
    public var whiteCellSpeed :Number;

    public var customInstructionsName :String;
}

}
