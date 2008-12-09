package redrover.data {

import com.threerings.util.StringUtil;
import com.whirled.contrib.simplegame.util.NumRange;
import com.whirled.contrib.simplegame.util.Rand;

import redrover.*;
import redrover.util.IntValueTable;
import redrover.util.XmlReadError;
import redrover.util.XmlReader;

public class LevelData
{
    public var cellSize :int;
    public var ownBoardZoom :Number;
    public var otherBoardZoom :Number;
    public var gemSpawnTime :NumRange = new NumRange(0, 0, Rand.STREAM_GAME);
    public var speedBase :Number;
    public var speedOffsetPerGem :Number;
    public var slowTerrainSpeedMultiplier :Number;
    public var maxTurnOvershoot :Number;
    public var maxCarriedGems :int;
    public var switchBoardsTime :Number;
    public var gotEatenTime :Number;
    public var returnHomeGemsMin :int;

    public var gemValues :IntValueTable;
    public var playerColors :Array = [];
    public var robotNames :Array = [];

    public var terrain :Array = [];
    public var objects :Array = [];
    public var cols :int;
    public var rows :int;

    public static function fromXml (xml :XML) :LevelData
    {
        var data :LevelData = new LevelData();

        data.cellSize = XmlReader.getUintAttr(xml, "cellSize");
        data.ownBoardZoom = XmlReader.getNumberAttr(xml, "ownBoardZoom");
        data.otherBoardZoom = XmlReader.getNumberAttr(xml, "otherBoardZoom");
        data.gemSpawnTime.min = XmlReader.getUintAttr(xml, "gemSpawnTimeMin");
        data.gemSpawnTime.max = XmlReader.getUintAttr(xml, "gemSpawnTimeMax");
        data.speedBase = XmlReader.getNumberAttr(xml, "speedBase");
        data.speedOffsetPerGem = XmlReader.getNumberAttr(xml, "speedOffsetPerGem");
        data.slowTerrainSpeedMultiplier = XmlReader.getNumberAttr(xml, "slowTerrainSpeedMultiplier");
        data.maxTurnOvershoot = XmlReader.getNumberAttr(xml, "maxTurnOvershoot");
        data.maxCarriedGems = XmlReader.getUintAttr(xml, "maxCarriedGems");
        data.switchBoardsTime = XmlReader.getNumberAttr(xml, "switchBoardsTime");
        data.gotEatenTime = XmlReader.getNumberAttr(xml, "gotEatenTime");
        data.returnHomeGemsMin = XmlReader.getUintAttr(xml, "returnHomeGemsMin");

        data.gemValues = IntValueTable.fromXml(XmlReader.getSingleChild(xml, "GemValues"));

        for each (var colorXml :XML in xml.PlayerColors.Color) {
            data.playerColors.push(XmlReader.getUintAttr(colorXml, "value"));
        }

        for each (var nameXml :XML in xml.RobotNames.Name) {
            data.robotNames.push(XmlReader.getStringAttr(nameXml, "value"));
        }

        parseTerrainString(xml.Terrain, data);
        parseObjectString(xml.Objects, data);

        return data;
    }

    protected static function parseTerrainString (str :String, data :LevelData) :void
    {
        // eat any whitespace at the beginning and end of the string
        str = StringUtil.trim(str);

        // split into lines
        var rows :Array = str.split("\n");
        if (rows.length == 0) {
            throw new XmlReadError("No Terrain!");
        }

        data.cols = getRowWidth(rows[0]);
        data.rows = rows.length;

        for each (var row :String in rows) {
            if (getRowWidth(row) != data.cols) {
                throw new XmlReadError("All Terrain rows must be the same width!");
            }

            for (var ii :int = 0; ii < row.length; ++ii) {
                var char :String = row.charAt(ii);
                if (StringUtil.isWhitespace(char)) {
                    continue;
                }

                var terrainType :int = getTerrainType(char);
                if (terrainType < 0) {
                    throw new XmlReadError("Unrecognized terrain type: " + char);
                }

                data.terrain.push(terrainType);
            }
        }
    }

    protected static function parseObjectString (str :String, data :LevelData) :void
    {
        str = StringUtil.trim(str);
        var rows :Array = str.split("\n");
        if (rows.length != data.rows) {
            throw new XmlReadError("Bad number of Objects rows (expected=" + data.rows +
                                   ", got=" + rows.length + ")");
        }

        var yy :int = 0;
        for each (var row :String in rows) {
            if (getRowWidth(row) != data.cols) {
                throw new XmlReadError("All Objects rows must be the same width!");
            }

            var xx :int = 0;
            for (var ii :int = 0; ii < row.length; ++ii) {
                var char :String = row.charAt(ii);
                if (StringUtil.isWhitespace(char)) {
                    continue;
                }

                if (char != ".") {
                    var objType :int = getObjectType(char);
                    if (objType < 0) {
                        throw new XmlReadError("Unrecognized object type: " + char);
                    }

                    data.objects.push(new LevelObjData(xx, yy, objType));
                }

                ++xx;
            }

            ++yy;
        }
    }

    protected static function getRowWidth (line :String) :int
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

    protected static function getObjectType (char :String) :int
    {
        for (var type :int = 0; type < Constants.OBJ_SYMBOLS.length; ++type) {
            if (Constants.OBJ_SYMBOLS[type] == char) {
                return type;
            }
        }

        return -1;
    }
}

}
