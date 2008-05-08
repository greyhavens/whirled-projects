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

        var totalWaveDelay :Number = 0;
        for each (var initialWaveData :XML in xmlData.InitialWaves.Wave) {
            var uwd :UnitWaveData = UnitWaveData.fromXml(initialWaveData, totalWaveDelay);
            totalWaveDelay += uwd.delayBefore;
            computerPlayer.initialWaves.push(uwd);
        }

        totalWaveDelay = 0;
        for each (var repeatingWaveData :XML in xmlData.RepeatingWaves.Wave) {
            uwd = UnitWaveData.fromXml(repeatingWaveData, totalWaveDelay);
            totalWaveDelay += uwd.delayBefore;
            computerPlayer.repeatingWaves.push(uwd);
        }

        return computerPlayer;
    }
}

}
