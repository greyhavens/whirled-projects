package popcraft.data {

import popcraft.util.XmlReader;

public class IntroOutroData
{
    public var introVerses :Array = [];
    public var outroVerses :Array = [];

    public static function fromXml (xml :XML) :IntroOutroData
    {
        var data :IntroOutroData = new IntroOutroData();

        for each (var introVerse :XML in xml.IntroVerses.Verse) {
            data.introVerses.push(String(introVerse));
        }

        for each (var outroVerse :XML in xml.OutroVerses.Verse) {
            data.outroVerses.push(String(outroVerse));
        }

        return data;
    }

}

}
