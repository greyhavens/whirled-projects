//
// $Id$

package {

import flash.display.DisplayObject;
import flash.display.Loader;
import flash.display.Sprite;

import flash.events.ErrorEvent;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.MouseEvent;
import flash.events.StatusEvent;

import flash.net.LocalConnection;
import flash.net.URLRequest;

import flash.text.TextField;
import flash.text.TextFieldType;

import flash.system.ApplicationDomain;
import flash.system.LoaderContext;

import com.threerings.util.MethodQueue;
import com.threerings.util.StringUtil;
import com.threerings.util.Util;

import com.threerings.flash.SimpleTextButton;
import com.threerings.flash.TextFieldUtil;

import com.whirled.FurniControl;
import com.whirled.ControlEvent;

[SWF(width="320", height="180")]
public class Embedder extends Sprite
{
    public function Embedder ()
    {
        _ctrl = new FurniControl(this);
        _ctrl.addEventListener(Event.UNLOAD, handleUnload);
        _ctrl.addEventListener(ControlEvent.MEMORY_CHANGED, handleMemoryChanged);
        _ctrl.registerCustomConfig(createConfigPanel);

//        // add a little area for room editors to be able to click
//        if (_ctrl.canEditRoom()) {
//            graphics.beginFill(0x00FF00, .3);
//            graphics.drawRect(0, 0, 32, 18);
//            graphics.endFill();
//        }

        var mem :String = _ctrl.getMemory(MEM_KEY) as String;
        if (mem != null) {
            load(mem);
        } else {
            // Normal else
            //addChild(createConfigPanel());

            // TEMP: convert old key
            mem = _ctrl.getMemory("xml") as String;
            var fixed :String = null;
            try {
                fixed = parseValue(mem);
            } catch (err :Error) {
                addChild(createConfigPanel());
            }
            if (fixed != null) {
                _ctrl.setMemory("xml", null);
                _ctrl.setMemory(MEM_KEY, fixed);
            }
        }
    }

    protected function handleMemoryChanged (event :ControlEvent) :void
    {
        if (event.name == MEM_KEY) {
            load(event.value as String);
        }
    }

    /**
     * Return the parsed URL, or throw an Error.
     */
    protected function parseValue (value :String) :String
    {
        if (StringUtil.isBlank(value)) {
            throw new Error("No value");
        }
        value = StringUtil.trim(value);

        var startEmbed :int = value.toLowerCase().indexOf("<embed ");

        if (-1 == startEmbed) {
            // treat the whole thing as a URL?
            var bits :Array = StringUtil.parseURLs(value);
            if ((bits.length != 2) || (bits[0] != "")) {
                throw new Error("No <embed>, not a URL either");
            }
            // if that works, I think we're good...
            load(value);
            return value;
        }

        var endEmbed :int = value.indexOf(">", startEmbed);
        if (endEmbed == -1) {
            throw new Error("Malformed embed");
        }

        var embed :String = value.substring(startEmbed, endEmbed + 1);

        if (embed.charAt(embed.length - 2) != "/") {
            embed += "</embed>";
        }

        // in case we only have an <embed>, we make it one-level-down...
        var xml :XML = Util.newXML("<xml>" + embed + "</xml>");

        // TODO: What I should do is find the first embed child as XML and then look in that
        // for "src" and "flashvars". The below code could find a different flashvars because
        // if two embeds are pasted in and the first doesn't have a flashvars.
        // I would have thought it would be easy to have var embed :XML = xml..embed[0], but
        // that doesn't fucking work for some fucking reason!

        var src :XML = xml..embed.@src[0];
        if (src == null) {
            throw new Error("Malformed embed");
        }

        var url :String = String(src);
        var vars :XML = xml..embed.@flashvars[0];
        if (vars != null && vars != "") {
            url += ((-1 == url.indexOf("?")) ? "?" : "&") + vars;
        }

        load(url);
        return url;
    }

    protected function load (url :String) :void
    {
        handleUnload(null);

        if (url != null) {
            _loader = new Loader();
            _loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, handleError);
            addChild(_loader);
            url = checkHandleYoutube(url);
            _loader.load(new URLRequest(url), new LoaderContext(false, new ApplicationDomain(null)));
        }
    }

    protected function handleUnload (event :Event) :void
    {
        if (_loader != null) {
            removeChild(_loader);

            if (_youtubeId != null) {
                // to shut this down properly we've got to jump through some hoopery
                var lc :LocalConnection = new LocalConnection();
                lc.addEventListener(StatusEvent.STATUS, function (arg :Object) :void {
                    trace("eaten: " + arg);
                });
                lc.send("_" + _youtubeId, "killVid");

                MethodQueue.callLater(MethodQueue.callLater, [ killLoader, [ _loader ] ]);
                _youtubeId = null;

            } else {
                killLoader(_loader);
            }
            _loader = null;
        }
    }

    protected function killLoader (l :Loader) :void
    {
        try {
            l.close();
        } catch (err :Error) {
        }
        l.unload();
    }

    protected function handleError (evt :ErrorEvent) :void
    {
        trace("Error loading: " + evt.text);
    }

    protected function createConfigPanel () :DisplayObject
    {
        var panel :Sprite = new Sprite();

        var input :TextField = TextFieldUtil.createField(_ctrl.getMemory(MEM_KEY, "") as String,
            {
                background: true,
                backgroundColor: 0xFFFFFF,
                border: true,
                borderColor: 0x000000,
                multiline: true,
                type: TextFieldType.INPUT,
                wordWrap: true,
                width: 275,
                height: 160,
                y: 20
            });
        panel.addChild(input);

        var status :TextField = TextFieldUtil.createField("Enter embedding HTML code, or a URL:",
            {
                height: 20,
                width: 320
            });
        panel.addChild(status);


        var ok :SimpleTextButton = new SimpleTextButton("OK", true, 0x000000, 0xFFFFFF, 0x000099);
        ok.x = 320 - ok.width;
        ok.y = 20;
        panel.addChild(ok);

        var embedder :Embedder = this;
        ok.addEventListener(MouseEvent.CLICK, function (event :MouseEvent) :void {
            var txt :String = input.text;
            if (StringUtil.isBlank(txt)) {
                txt = null;
            }
            if (txt == _ctrl.getMemory(MEM_KEY)) {
                return; // no change
            }

            var url :String;
            if (txt != null) {
                try {
                    url = parseValue(txt);
                } catch (err :Error) {
                    status.text = "Unable to parse: " + err.message + ". Please try again.";
                    return;
                }

                // update displayed value
                input.text = url;
            }

            // yay! It works!
            _ctrl.setMemory(MEM_KEY, url);
            if (embedder.contains(panel)) {
                embedder.removeChild(panel);
            } else {
                _ctrl.clearPopup(); // in case this is up as a popup
            }
        });

        var clear :SimpleTextButton = new SimpleTextButton("Clear", true, 0x000000,
            0xFFFFFF, 0x000099);
        clear.x = 320 - clear.width;
        clear.y = 50;
        panel.addChild(clear);
        clear.addEventListener(MouseEvent.CLICK, function (event :MouseEvent) :void {
            input.text = "";
            status.text = "Press OK to save";
        });

        return panel;
    }

    protected function checkHandleYoutube (url :String) :String
    {
        if (-1 == url.indexOf("youtube.com")) {
            return url;
        }

        var chars :Array = [];
        for (var ii :int = 0; ii < 12; ii++) {
            var char :int = int(Math.random() * 26);
            var cap :Boolean =  Math.random() > .5;
            chars.push(char + (cap ? 65 : 97));
        }
        _youtubeId = String.fromCharCode.apply(null, chars);

        var args :String = "?name=" + _youtubeId + "&url=" + encodeURIComponent(url);
        return YOUTUBE_STUB_URL + args;
    }

    protected var _ctrl :FurniControl;

    protected var _loader :Loader;

    protected var _youtubeId :String;

    private static const MEM_KEY :String = "url";

    private static const YOUTUBE_STUB_URL :String =
        "http://media.whirled.com/72312fb7ad495131dc3342e999ed88f08e04e188.swf";
}
}
