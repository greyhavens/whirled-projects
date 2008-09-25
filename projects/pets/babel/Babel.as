package {

import flash.display.Bitmap;
import flash.display.Sprite;

import flash.events.*;

import com.whirled.ControlEvent;
import com.whirled.PetControl;
import com.whirled.EntityControl;

[SWF(width="60", height="60")]
public class Babel extends Sprite
{
    public function Babel ()
    {
        addChild(_image = Bitmap(new IMAGE()));

        _svc = new GoogleTranslator();
        _svc.addEventListener(Translator.TRANSLATE, onTranslate);

        _ctrl = new PetControl(this);
        _ctrl.addEventListener(ControlEvent.RECEIVED_CHAT, onChat);

        // Possible bug, if this isn't here, the pet won't get RECEIVED_CHAT events!
        _ctrl.sendChat("Usage: \"" + _ctrl.getEntityProperty(EntityControl.PROP_NAME) + ", <language>\"");
    }

    protected function onTranslate (event :TranslationEvent) :void
    {
        _ctrl.sendChat(event.translatedText + " (" + LANGUAGES[event.sourceLang] + ")");
    }

    protected function getLangCode (desc :String) :String
    {
        desc = desc.toLowerCase();
        for (var i :String in LANGUAGES) {
            if (LANGUAGES[i].toLowerCase() == desc) {
                return i;
            }
        }

        return null;
    }

    protected function onChat (event :ControlEvent) :void
    {
        if (_ctrl.getEntityProperty(EntityControl.PROP_TYPE, event.name) !=
            EntityControl.TYPE_AVATAR) {
            return;
        }

        // Say: "<petname>, lang german" to change languages
        var m :Array = event.value.match(
            new RegExp("^"+_ctrl.getEntityProperty(EntityControl.PROP_NAME) + ",? (.*)", "i"));

        if (m != null && m.length > 1) {
            var lang :String = getLangCode(m[1]);

            if (lang != null) {
                _svc.toLang = lang;
                _ctrl.sendChat("Ok, I'll translate into " + LANGUAGES[_svc.toLang]);
            } else {
                _ctrl.sendChat("I don't know the language: " + m[1]);
            }

        } else {
            trace("Translating: " + event.value);
            _svc.translate(String(event.value));
        }
    }

    protected var _ctrl :PetControl;
    protected var _svc :Translator;

    protected var _image :Bitmap;

    [Embed(source="icon.png")]
    protected static const IMAGE :Class;

    protected static const LANGUAGES :Object = {
        'af': 'Afrikaans',
        'sq': 'Albanian',
        'am': 'Amharic',
        'ar': 'Arabic',
        'hy': 'Armenian',
        'az': 'Azerbaijani',
        'eu': 'Basque',
        'be': 'Belarusian',
        'bn': 'Bengali',
        'bh': 'Bihari',
        'bg': 'Bulgarian',
        'my': 'Burmese',
        'ca': 'Catalan',
        'chr': 'Cherokee',
        'zh': 'Chinese',
        'zh-CN': 'Chinese',
        'zh-TW': 'Chinese',
        'hr': 'Croatian',
        'cs': 'Czech',
        'da': 'Danish',
        'dv': 'Dhivehi',
        'nl': 'Dutch',  
        'en': 'English',
        'eo': 'Esperanto',
        'et': 'Estonian',
        'tl': 'Filipino',
        'fi': 'Finnish',
        'fr': 'French',
        'gl': 'Galician',
        'ka': 'Georgian',
        'de': 'German',
        'el': 'Greek',
        'gn': 'Guarani',
        'gu': 'Gujarati',
        'iw': 'Hebrew',
        'hi': 'Hindi',
        'hu': 'Hungarian',
        'is': 'Icelandic',
        'id': 'Indonesian',
        'iu': 'Inuktitut',
        'it': 'Italian',
        'ja': 'Japanese',
        'kn': 'Kannada',
        'kk': 'Kazakh',
        'km': 'Khmer',
        'ko': 'Korean',
        'ku': 'Kurdish',
        'ky': 'Kyrgyz',
        'lo': 'Laothian',
        'lv': 'Latvian',
        'lt': 'Lithuanian',
        'mk': 'Macedonian',
        'ms': 'Malay',
        'ml': 'Malayalam',
        'mt': 'Maltese',
        'mr': 'Marathi',
        'mn': 'Mongolian',
        'ne': 'Nepali',
        'no': 'Norwegian',
        'or': 'Oriya',
        'ps': 'Pashto',
        'fa': 'Persian',
        'pl': 'Polish',
        'pt-PT': 'Portuguese',
        'pa': 'Punjabi',
        'ro': 'Romanian',
        'ru': 'Russian',
        'sa': 'Sanskrit',
        'sr': 'Serbian',
        'sd': 'Sindhi',
        'si': 'Sinhalese',
        'sk': 'Slovak',
        'sl': 'Slovenian',
        'es': 'Spanish',
        'sw': 'Swahili',
        'sv': 'Swedish',
        'tg': 'Tajik',
        'ta': 'Tamil',
        'tl': 'Tagalog',
        'te': 'Telugu',
        'th': 'Thai',
        'bo': 'Tibetan',
        'tr': 'Turkish',
        'uk': 'Ukrainian',
        'ur': 'Urdu',
        'uz': 'Uzbek',
        'ug': 'Uighur',
        'vi': 'Vietnamese'
    };
}

}
