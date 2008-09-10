package {

/** Dispatched when a translation has been made. */
[Event(name="translate", type="TranslationEvent")]

import flash.events.EventDispatcher;

public class Translator extends EventDispatcher
{
    public static const TRANSLATE :String = "translate";

    public var toLang :String = "en";

    public function translate (text :String) :void
    {
        throw new Error("Abstract");
    }
}

}
