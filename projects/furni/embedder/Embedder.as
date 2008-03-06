//
// $Id$

package {

import flash.display.DisplayObject;
import flash.display.Loader;
import flash.display.Sprite;

import flash.events.Event;
import flash.events.MouseEvent;

import flash.net.URLRequest;

import flash.text.TextField;
import flash.text.TextFieldType;

import flash.system.ApplicationDomain;
import flash.system.LoaderContext;

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

        var mem :String = _ctrl.lookupMemory(MEM_KEY) as String;
        if (!parseXML(mem)) {
            addChild(createConfigPanel());
        }
    }

    protected function handleMemoryChanged (event :ControlEvent) :void
    {
        if (event.name == MEM_KEY) {
            parseXML(event.value as String);
        }
    }

    protected function parseXML (mem :String) :Boolean
    {
        var xml :XML;
        try {
            // in case we only have an <embed>, we make it one-level-down...
            xml = Util.newXML("<xml>" + mem + "</xml>");
        } catch (err :Error) {
            return false; // this should never happen
        }

        // TODO: What I should do is find the first embed child as XML and then look in that
        // for "src" and "flashvars". The below code could find a different flashvars because
        // if two embeds are pasted in and the first doesn't have a flashvars.
        // I would have thought it would be easy to have var embed :XML = xml..embed[0], but
        // that doesn't fucking work for some fucking reason!

        var src :XML = xml..embed.@src[0];
        if (src == null) {
            return false;
        }

        var url :String = String(src);
        var vars :XML = xml..embed.@flashvars[0];
        if (vars != null && vars != "") {
            url += ((-1 == url.indexOf("?")) ? "?" : "&") + vars;
        }

        load(url);
        return true;
    }

    protected function load (url :String) :void
    {
        handleUnload(null);

        _loader = new Loader();
        addChild(_loader);
        _loader.load(new URLRequest(url), new LoaderContext(false, new ApplicationDomain(null)));
    }

    protected function handleUnload (event :Event) :void
    {
        if (_loader != null) {
            try {
                _loader.close();
            } catch (err :Error) {
            }
            _loader.unload();
            removeChild(_loader);
            _loader = null;
        }
    }

    protected function createConfigPanel () :DisplayObject
    {
        var panel :Sprite = new Sprite();

        var input :TextField = TextFieldUtil.createField(_ctrl.lookupMemory(MEM_KEY, "") as String,
            {
                background: true,
                backgroundColor: 0xFFFFFF,
                border: true,
                borderColor: 0x000000,
                multiline: true,
                type: TextFieldType.INPUT,
                wordWrap: true,
                width: 280,
                height: 160,
                y: 20
            });
        panel.addChild(input);

        var status :TextField = TextFieldUtil.createField("Enter embed HTML",
            {
                height: 20,
                width: 320
            });
        panel.addChild(status);


        var button :SimpleTextButton = new SimpleTextButton("OK", true, 0x000000,
            0xFFFFFF, 0x000099);
        button.x = 320 - button.width;
        button.y = 20;
        panel.addChild(button);

        var embedder :Embedder = this;
        button.addEventListener(MouseEvent.CLICK, function (event :MouseEvent) :void {
            var txt :String = input.text;
            if (txt == _ctrl.lookupMemory(MEM_KEY)) {
                return; // no change
            }

            if (parseXML(txt)) {
                _ctrl.updateMemory(MEM_KEY, txt);
                if (embedder.contains(panel)) {
                    embedder.removeChild(panel);
                }
            } else {
                status.text = "Unable to parse embed HTML. Please try again.";
            }
        });

        return panel;
    }

    protected var _ctrl :FurniControl;

    protected var _loader :Loader;

    private static const MEM_KEY :String = "xml";
}
}
