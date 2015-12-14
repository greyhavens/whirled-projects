package config {

import flash.utils.ByteArray;

public class ConfigData
{
    public var skinColor :uint = 0xD0DFFD;
    public var topColor :uint = 0x222222;
    public var pantsColor :uint = 0x203030;
    public var topNumber :int = 1;

    public function clone () :ConfigData
    {
        var theClone :ConfigData = new ConfigData();
        theClone.fromMemory(toMemory());
        return theClone;
    }

    public function toMemory () :Object
    {
        return {
            skinColor: skinColor,
            topColor: topColor,
            pantsColor: pantsColor,
            topNumber: topNumber
        };
    }

    public function fromMemory (memory :Object) :void
    {
        if (memory == null) {
            return;
        }

        if ("skinColor" in memory) {
            skinColor = memory["skinColor"];
        }
        if ("topColor" in memory) {
            topColor = memory["topColor"];
        }
        if ("pantsColor" in memory) {
            pantsColor = memory["pantsColor"];
        }
        if ("topNumber" in memory) {
            topNumber = memory["topNumber"];
        }
    }
}

}
