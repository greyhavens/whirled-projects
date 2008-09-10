package {

import flash.net.*;
import flash.events.Event;

import com.adobe.serialization.json.JSON;

import com.threerings.util.Command;

public class GoogleTranslator extends Translator
{
    override public function translate (text :String) :void
    {
        var loader :URLLoader = new URLLoader();
        var request :URLRequest = new URLRequest();

        var query :URLVariables = new URLVariables();
        query.v = "1.0";
        query.q = text;
        query.langpair = "|en";

        request.url = "http://ajax.googleapis.com/ajax/services/language/translate";
        request.data = query;

        Command.bind(loader, Event.COMPLETE, function () :void {
            var json :Object = JSON.decode(loader.data);

            trace(loader.data);
            dispatchEvent(new TranslationEvent(TRANSLATE, text,
                json.responseData.translatedText,
                json.responseData.detectedSourceLanguage));
        });

        loader.load(request);
    }
}

}
