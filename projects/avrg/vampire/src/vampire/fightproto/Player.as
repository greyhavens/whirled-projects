package vampire.fightproto {

import com.threerings.util.ArrayUtil;

public class Player
{
    public var level :PlayerLevel;
    public var health :Number;
    public var xp :int;
    public var energy :Number;
    public var skills :Array = [];
    public var scenarios :Array = [];

    public function levelUp () :void
    {
        var nextLevel :PlayerLevel = this.nextLevel;
        if (nextLevel != null) {
            this.level = nextLevel;
        }
    }

    public function get nextLevelXpRequirement () :int
    {
        var nextLevel :PlayerLevel = this.nextLevel;
        return (nextLevel != null ? nextLevel.xpRequirement : -1);
    }

    public function get canLevelUp () :Boolean
    {
        var xpReq :int = this.nextLevelXpRequirement;
        return (xpReq >= 0 ? xp >= xpReq : false);
    }

    public function get maxHealth () :Number
    {
        return this.level.maxHealth;
    }

    public function get maxEnergy () :Number
    {
        return this.level.maxEnergy;
    }

    public function get energyReplenishRate () :Number
    {
        return this.level.energyReplenishRate;
    }

    public function offsetHealth (offset :Number) :void
    {
        health += offset;
        health = Math.max(health, 0);
        health = Math.min(health, maxHealth);
    }

    public function offsetEnergy (offset :Number) :void
    {
        energy += offset;
        energy = Math.max(energy, 0);
        energy = Math.min(energy, maxEnergy);
    }

    public function hasSkill (skill :PlayerSkill) :Boolean
    {
        return ArrayUtil.contains(this.skills, skill);
    }

    public function hasScenario (scenario :Scenario) :Boolean
    {
        return ArrayUtil.contains(this.scenarios, scenario);
    }

    protected function get nextLevel () :PlayerLevel
    {
        var nextLevelIdx :int = level.level + 1;
        if (nextLevelIdx >= PlayerLevel.LEVELS.length) {
            return null;
        }

        return PlayerLevel.LEVELS[nextLevelIdx];
    }
}

}
