package popcraft.data {

import popcraft.util.*;

public class ComputerPlayerData
{
    public var baseHealth :int;

    public var team :uint;

    // go through these units waves first
    public var initialWaves :Array = [];

    // then repeat these
    public var repeatingWaves :Array = [];

    public static function fromXml (xmlData :XML) :ComputerPlayerData
    {
        var computerPlayer :ComputerPlayerData = new ComputerPlayerData();

        computerPlayer.baseHealth = XmlReader.getAttributeAsInt(xmlData, "baseHealth");
        computerPlayer.team = XmlReader.getAttributeAsUint(xmlData, "team");

        for each (var initialWaveData :XML in xmlData.InitialWaves.Wave) {
            computerPlayer.initialWaves.push(UnitWaveData.fromXml(initialWaveData));
        }

        for each (var repeatingWaveData :XML in xmlData.RepeatingWaves.Wave) {
            computerPlayer.repeatingWaves.push(UnitWaveData.fromXml(repeatingWaveData));
        }

        return computerPlayer;
    }
}

}
