package vampire.quest.activity {

import vampire.feeding.variant.VariantSettings;

public class BloodBloomActivityParams extends ActivityParams
{
    public var preyName :String;
    public var preyBloodStrain :int;
    public var minScore :int;

    public var awardedPropName :String;
    public var awardedPropIncrement :int;

    public var variantSettings :VariantSettings;

    public function BloodBloomActivityParams (minPlayers :int, maxPlayers :int, preyName :String,
        preyBloodStrain :int, minScore :int, variantSettings :VariantSettings,
        awardedPropName :String = null, awardedPropIncrement :int = 0)
    {
        super(minPlayers, maxPlayers);

        this.preyName = preyName;
        this.preyBloodStrain = preyBloodStrain;
        this.minScore = minScore;
        this.variantSettings = variantSettings;
        this.awardedPropName = awardedPropName;
        this.awardedPropIncrement = awardedPropIncrement;
    }
}

}
