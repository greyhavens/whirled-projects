package popcraft.ui {

import flash.events.Event;

public class GotSpellEvent extends Event
{
    public static const GOT_SPELL :String = "GotSpell";

    public var spellType :int;

    public function GotSpellEvent(spellType :int)
    {
        super(GOT_SPELL, false, false);
        this.spellType = spellType;
    }

}

}
