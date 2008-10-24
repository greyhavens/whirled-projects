package popcraft.sp.endless {

import com.threerings.util.ArrayUtil;

import flash.utils.ByteArray;

public class SavedEndlessGameList
{
    public var saves :Array = [];

    public function addSave (newSave :SavedEndlessGame) :Boolean
    {
        var existingSaveIndex :int = ArrayUtil.indexIf(saves,
            function (save :SavedEndlessGame) :Boolean {
                return save.mapIndex == newSave.mapIndex;
            });

        if (existingSaveIndex != -1) {
            var existingSave :SavedEndlessGame = saves[existingSaveIndex];
            // combine this save with the existing save to get the max values of both
            newSave = SavedEndlessGame.max(newSave, existingSave);
            if (newSave.isEqual(existingSave)) {
                // didn't make any progress - don't save
                return false;
            }

            saves[existingSaveIndex] = newSave;

        } else {
            saves.push(newSave);
        }

        return true;
    }

    public function fromBytes (ba :ByteArray) :void
    {
        saves = [];

        var numSaves :int = ba.readShort();
        for (var ii :int = 0; ii < numSaves; ++ii) {
            var save :SavedEndlessGame = new SavedEndlessGame();
            save.fromBytes(ba);
            saves.push(save);
        }
    }

    public function toBytes (ba :ByteArray) :void
    {
        ba.writeShort(saves.length);
        for each (var save :SavedEndlessGame in saves) {
            save.toBytes(ba);
        }
    }
}

}
