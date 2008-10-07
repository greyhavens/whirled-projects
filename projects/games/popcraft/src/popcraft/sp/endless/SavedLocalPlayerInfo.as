package popcraft.sp.endless {

import popcraft.LocalPlayerInfo;

public class SavedLocalPlayerInfo extends SavedPlayerInfo
{
    public var resources :Array;
    public var spells :Array;
    public var fourPlusPieceClearRunLength :int;

    public function SavedLocalPlayerInfo (playerInfo :LocalPlayerInfo)
    {
        super(playerInfo);
        resources = playerInfo.resourcesCopy;
        spells = playerInfo.spellsCopy;
        fourPlusPieceClearRunLength = playerInfo.fourPlusPieceClearRunLength;
    }

}

}
