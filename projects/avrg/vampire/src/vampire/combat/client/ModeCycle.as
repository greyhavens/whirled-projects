package vampire.combat.client
{
    import com.threerings.util.ArrayUtil;
    import com.threerings.util.Log;
    import com.whirled.contrib.GameMode;
    import com.whirled.contrib.GameModeStack;

/**
 * Cycles repeatedly thorugh a sequence of GameModes
 *
 */
public class ModeCycle
{
    public function ModeCycle(stack :GameModeStack)
    {
        _stack = stack;
    }

    public function modeChangedCallback (oldMode :GameMode, newMode :GameMode) :void
    {
        if (newMode == null) {
            var index :int = ArrayUtil.indexOf(_modeSequence, oldMode);
            if (index >= 0 && index < _modeSequence.length) {
                if (index != _modeSequence.length - 1) {
                    _stack.push(_modeSequence[index + 1]);
                }
                else {
                    _stack.push(_modeSequence[0]);
                }
            }
            else {
                log.warning("popCallback, oldMode unknown", "oldMode", oldMode);
            }
        }
    }



    public function addMode (mode :GameMode) :GameMode
    {
        _modeSequence.push(mode);
        return mode;
    }

    protected var _stack :GameModeStack;
    protected var _modeSequence :Array = [];
    protected static const log :Log = Log.getLog(ModeCycle);
}
}