package popcraft.data {

import com.whirled.contrib.simplegame.util.NumRange;

import popcraft.util.*;

public class ComputerPlayerData
{
    public var baseHealth :int;

    // go through these units waves first
    public var initialWaves :Array = [];

    // then repeat these
    public var repeatingWaves :Array = [];

    public static function fromXml (xmlData :XML) :ComputerPlayerData
    {
        var computerPlayer :ComputerPlayerData = new ComputerPlayerData();

        computerPlayer.baseHealth = XmlReader.getAttributeAsInt(xmlData, "baseHealth");

        for each (var initialWaveData :XML in xmlData.InitialWaves.Wave) {
            computerPlayer.initialWaves.push(UnitWave.fromXml(initialWaveData));
        }

        for each (var repeatingWaveData :XML in xmlData.RepeatingWaves.Wave) {
            computerPlayer.repeatingWaves.push(UnitWave.fromXml(repeatingWaveData));
        }

        return computerPlayer;
    }
}

}
