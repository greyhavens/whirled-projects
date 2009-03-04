package redrover.util {

import com.threerings.util.StringUtil;

public class GameUtil
{
    public static function isLevelDataLevelPack (levelPackName :String) :Boolean
    {
        return StringUtil.endsWith(levelPackName, "level");
    }

    public static function getLevelPackLevelIdx (levelPackName :String) :int
    {
        var idx :int = levelPackName.indexOf("_");
        if (idx <= 0) {
            return -1;
        }

        var substr :String = levelPackName.substr(0, idx);
        var intVal :int;
        try {
            intVal = StringUtil.parseUnsignedInteger(substr, 10);
        } catch (e :Error) {
            return -1;
        }

        return intVal - 1;
    }
}

}
