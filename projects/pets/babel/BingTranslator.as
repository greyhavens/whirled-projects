package {

import flash.net.*;
import flash.events.Event;

import com.threerings.util.Command;

public class BingTranslator extends Translator
{
    override public function translate (text :String) :void
    {
        var loader :URLLoader = new URLLoader();
        var request :URLRequest = new URLRequest();

        var query :URLVariables = new URLVariables();
        // Don't reuse this API key please
        query.appId = "E0E780E638ECC269BD12E89D8E7176C3787E3A83";
        query.text = text;
        query.to = toLang;

        request.url = "http://api.microsofttranslator.com/V2/Http.svc/Translate";
        request.data = query;

        Command.bind(loader, Event.COMPLETE, function () :void {
            var xml :XML = new XML(loader.data);

            // TODO(bruno): How to handle errors?
            // if (json.responseStatus != 200) {
            //     return;
            // }

            var translatedText :String = String(xml.children());
            if (text != translatedText) {
                dispatchEvent(new TranslationEvent(TRANSLATE, text,
                    translatedText, null, toLang));
            }
        });

        loader.load(request);
    }
}
}
