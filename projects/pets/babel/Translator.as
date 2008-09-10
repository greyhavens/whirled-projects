package {
// bob: hola mundo
// BOT: bob: "hello world" (Spanish)

/** Dispatched when a translation has been made. */
[Event(name="translate", type="TranslationEvent")]

import flash.events.EventDispatcher;

public class Translator extends EventDispatcher
{
    public static const TRANSLATE :String = "translate";

    public function translate (text :String) :void
    {
        throw new Error("Abstract");
    }
}

}
