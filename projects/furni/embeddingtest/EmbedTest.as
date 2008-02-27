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
 * Tests embeddable content.
 *
 * Run this in a debug version of the stand-alone flash player. There is a
 * white text field and a green circular button along the top.
 *
 * Type or paste the URL to a video into the text field and press the button.
 * The video should load (at 50% scale) somewhere below.
 *
 * Pressing the button again will unload and reload, using any newly entered
 * URL or the same one, and will pick a new X random coordinate for the video
 * so that there's a bit of visual feedback that something changed.
 *
 *
 * Youtube video: (Testing with http://www.youtube.com/v/d-qYljgyDGo&rel=1)
 *
 * + Video loads and appears to be correct size.
 * - Video player can not load a second time.
 * - Video player never appears to get the UNLOAD event and stop playing.
 *
 * Google video: (Testing with
 * http://video.google.com/googleplayer.swf?docId=25985330959572111&hl=en)
 * 
 * + Video loads and plays fine, repeatedly.
 * - Video player appears to size itself based on the stage. If you resize
 * the flash player window you should see the google video player resize
 * within it.
 * - Video player never seems to UNLOAD.
 *
 * What should happen:
 * 
 * + Players should be able to load and unload and load again.
 * + Players should not continue playing after they've been UNLOADed (I'm not
 * sure if there's something like UNLOAD in AVM1.)
 * + Players should not base their size on the stage when loaded inside
 * another SWF. They should simply be the default size.
 *
 * @author Ray Greenwell <ray@threerings.net>
 */
[SWF(width="600", height="400")]
public class EmbedTest extends Sprite
{
    public function EmbedTest ()
    {
        _text = new TextField();
        _text.type = TextFieldType.INPUT;
        _text.background = true;
        _text.width = 350;
        _text.height = 50;
        addChild(_text);

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
        // if we already had something loaded, unload it
        if (_loader != null) {
            try {
                _loader.close();
            } catch (err :Error) {
                // ignore
            }
            _loader.unload();
            removeChild(_loader);
        }

        _loader = new Loader();
        _loader.scaleX = .5;
        _loader.scaleY = .5;
        _loader.y = 50;
        _loader.x = Math.random() * 300;
        addChild(_loader);

        // load the URL specified, putting it into its own ApplicationDomain and SecurityDomain
        _loader.load(new URLRequest(_text.text),
            new LoaderContext(false, new ApplicationDomain(null)));
    }

    protected var _text :TextField;
    protected var _loader :Loader;
}
}
