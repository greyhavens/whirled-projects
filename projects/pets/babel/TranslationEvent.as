package {

import flash.events.Event;

public class TranslationEvent extends Event
{
    public var originalText :String;
    public var translatedText :String;
    public var sourceLang :String;

    public function TranslationEvent (type :String, originalText :String, translatedText :String, sourceLang :String)
    {
        super(type, false, false);

        this.originalText = originalText;
        this.translatedText = translatedText;
        this.sourceLang = sourceLang;
    }
}

}
