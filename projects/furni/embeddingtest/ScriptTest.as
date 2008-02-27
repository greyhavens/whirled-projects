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
 * Demonstrates a bug in the flash player.
 *
 * How to use:
 *
 * Load this SWF up into a flash player.
 * In the white textfield, paste in the location of the jacobsladder_tester.swf.
 * Note that the location must be on a different server from that which served this file,
 * if you need to you can change the hostname to the IP address and that'll work.
 * Clicking the green button will load up the SWF at the specified URL, placing it at
 * a random location with scale=50%. Clicking again will load a second and third one, and then
 * older ones are re-used.
 *
 * What the bug shows:
 * The Jacob's Ladder SWF is constructed so that it has a sub-movieclip called arc_flare.
 * This clip has some script in it on frame 1: gotoAndPlay(10). Frame 10 contains the word
 * "Pass", Frames 2-9 contain "Fail".
 * The word "Fail" should never appear because the script should cause it to be jumped.
 * But, as you should see, when a second instance of the Jacob's Ladder is loaded, the first
 * one starts failing. Same with the third: the first two fail.
 *
 * What should happen:
 * Each instance of the Jacob's ladder should always say "Pass".
 * Each one is loaded into its own ApplicationDomain, so there should be no conflict
 * between them.
 *
 * This is a bug we've been seeing since last summer. Previous to today, we haven't been able
 * to track it down to such a concise test case, so we were never sure exactly what was
 * going on. I believe that the bug is not strictly related to loading multiple instances of
 * the same SWF: I'm pretty sure it can spontaneously happen, but loading multiple instances
 * tickles the bug every time.
 *
 * The bug happens in 9.0.115.0 and other relatively new players.
 * The bug does not happen in older players, for example 9.0.31.0.
 * The bug also does not happen if the media is loaded from the same server as this
 * harness SWF, as that causes them to be placed in the same security domain.
 *
 * Hopefully this code is simple enough that it demonstrates the bug and helps you fix it.
 *
 * @author Ray Greenwell <ray@threerings.net>
 */
[SWF(width="600", height="400")]
public class ScriptTest extends Sprite
{
    public function ScriptTest ()
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
        _loaders[_idx] = reload(Loader(_loaders[_idx]));
        _idx = (_idx + 1) % _loaders.length;
    }

    protected function reload (loader :Loader) :Loader
    {
        // if we already had something loaded, unload it
        if (loader != null) {
            try {
                loader.close();
            } catch (err :Error) {
                // ignore
            }
            loader.unload();
            removeChild(loader);
        }

        loader = new Loader();
        loader.scaleX = .5;
        loader.scaleY = .5;
        loader.y = 50;
        loader.x = Math.random() * 300;
        addChild(loader);

        // load the URL specified, putting it into its own
        // ApplicationDomain and SecurityDomain
        loader.load(new URLRequest(_text.text),
            new LoaderContext(false, new ApplicationDomain(null)));
        return loader;
    }

    protected var _text :TextField;

    protected var _idx :int = 0;

    protected var _loaders :Array = [ null, null, null ];
}
}
