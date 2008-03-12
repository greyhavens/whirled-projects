package {

import flash.display.Loader;
import flash.display.SimpleButton;
import flash.display.Sprite;

import flash.events.MouseEvent;

import flash.net.URLRequest;

import flash.system.ApplicationDomain;
import flash.system.LoaderContext;

import flash.text.TextField;
import flash.text.TextFieldType;

/**
 */
[SWF(width="600", height="400")]
public class SecurityTest extends Sprite
{
    public function SecurityTest ()
    {
        var text :TextField = new TextField();
        text.type = TextFieldType.INPUT;
        text.background = true;
        text.width = 350;
        text.height = 50;
        addChild(text);

        var up :Sprite = new Sprite();
        up.graphics.beginFill(0x00FF00);
        up.graphics.drawCircle(25, 25, 25);
        up.graphics.endFill();

        var down :Sprite = new Sprite();
        down.graphics.beginFill(0x009900);
        down.graphics.drawCircle(25, 25, 25);
        down.graphics.endFill();

        var button :SimpleButton = new SimpleButton(up, up, down, down);
        button.addEventListener(MouseEvent.CLICK, handleClick);
        button.x = 350;
        addChild(button);
    }

    protected function handleClick (event :MouseEvent) :void
    {
        load(URLS[_idx++]);
        if (_idx == URLS.length) {
            SimpleButton(event.target).removeEventListener(MouseEvent.CLICK, handleClick);
        }
    }

    protected function load (url :String) :void
    {
        var loader :Loader = new Loader();
        loader.scaleX = .5;
        loader.scaleY = .5;
        loader.y = 50;
        loader.x = Math.random() * 300;
        addChild(loader);

        // load the URL specified, putting it into its own
        // ApplicationDomain and SecurityDomain
        loader.load(new URLRequest(url));
    }

    protected var _text :TextField;

    protected var _idx :int = 0;

    protected const URLS :Array = [ "http://192.168.54.34:8080/media/A.swf",
        "http://192.168.54.34:8080/media/B.swf" ];
}
}
