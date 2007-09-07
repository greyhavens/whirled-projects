package com.threerings.defense {

import com.threerings.defense.sprites.TowerSprite;
import com.threerings.defense.units.Tower;

/**
 * Encapsulates global definitions, asset references, and tuning parameters.
 * Eventually we may load this from a data pack, but for now, it's built-in.
 */
public class Definitions
{
    public static const TOWER_ASSET_TYPES :Array =
        [ { key: Tower.TYPE_SIMPLE, value: "sandbox" },
          { key: Tower.TYPE_2,      value: "wagon" } ];
    
    
    public static const TOWER_ASSET_STATES :Array =
        [ { key: TowerSprite.STATE_REST, value: null },
          { key: TowerSprite.STATE_FIRE, value: "fire" } ];


    
    public static function getTowerAssetNames (type :int) :Array // of String
    {
        // todo: memoize; there's no sense recomputing these
        return TowerSprite.ALL_STATES.map(function (state :int, i :*, a :*) :* {
                return getTowerAssetName(type, state);
            });
    }
                
    protected static function getTowerAssetName (type :int, state :int) :String
    {
        var assetname :String = getValue(TOWER_ASSET_TYPES, type);
        var statename :String = getValue(TOWER_ASSET_STATES, state);

        var suffix :String = (statename != null) ? "_" + statename : "";

        return "tower_" + assetname + suffix;
    }

    protected static function getValue (table :Array, key :*) :*
    {
        for each (var def :Object in table) {
                if (def.key == key) {
                    return def.value;
                }
            }

        return undefined;
    }
}
}
