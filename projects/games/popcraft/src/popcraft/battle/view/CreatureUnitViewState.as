package popcraft.battle.view {

public class CreatureUnitViewState
{
    public var facing :int;
    public var moving :Boolean;
    public var attacking :Boolean;

    public function get idle () :Boolean
    {
        return (!moving && !attacking);
    }

    public function equals (rhs :CreatureUnitViewState) :Boolean
    {
        return (
            facing == rhs.facing &&
            moving == rhs.moving &&
            attacking == rhs.attacking
            );
    }

    public function equalsExceptFacing (rhs :CreatureUnitViewState) :Boolean
    {
        return (moving == rhs.moving && attacking == rhs.attacking);
    }
}

}
