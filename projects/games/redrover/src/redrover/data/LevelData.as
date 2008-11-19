package redrover.data {

import com.threerings.util.StringUtil;

import redrover.*;
import redrover.util.XmlReadError;

public class LevelData
{
    public var terrain :Array = [];
    public var cols :int;
    public var rows :int;

    public static function fromXml (xml :XML) :LevelData
    {
        var data :LevelData = new LevelData();
        parseTerrainString(xml.Terrain, data);
        return data;
    }

    protected static function parseTerrainString (str :String, data :LevelData) :void
    {
        // eat any whitespace at the beginning and end of the string
        str = StringUtil.trim(str);

        // split into lines
        var rows :Array = str.split("\n");
        if (rows.length == 0) {
            throw new XmlReadError("No terrain!");
        }

        data.cols = getTerrainRowWidth(rows[0]);
        data.rows = rows.length;

        for each (var row :String in rows) {
            if (getTerrainRowWidth(row) != data.cols) {
                throw new XmlReadError("All terrain rows must be the same width!");
            }

            for (var ii :int = 0; ii < row.length; ++ii) {
                var char :String = row.charAt(ii);
                if (StringUtil.isWhitespace(char)) {
                    continue;
                }

                var terrainType :int = getTerrainType(char);
                if (terrainType < 0) {
                    throw new XmlReadError("Unrecognized terrain: " + char);
                }

                data.terrain.push(terrainType);
            }
        }
    }

    protected static function getTerrainRowWidth (line :String) :int
    {
        // Count all non-whitespace characters in the line
        var length :int;
        for (var ii :int = 0; ii < line.length; ++ii) {
            if (!StringUtil.isWhitespace(line.charAt(ii))) {
                length++;
            }
        }

        return length;
    }

    protected static function getTerrainType (char :String) :int
    {
        for (var type :int = 0; type < Constants.TERRAIN_SYMBOLS.length; ++type) {
            if (Constants.TERRAIN_SYMBOLS[type] == char) {
                return type;
            }
        }

        return -1;
    }
}

}
