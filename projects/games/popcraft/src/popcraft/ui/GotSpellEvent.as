package popcraft.ui {

import flash.events.Event;

public class GotSpellEvent extends Event
{
    public static const GOT_SPELL :String = "GotSpell";

    public var spellType :uint;

    public function GotSpellEvent(spellType :uint)
    {
        super(GOT_SPELL, false, false);
        this.spellType = spellType;
    }

}

}
