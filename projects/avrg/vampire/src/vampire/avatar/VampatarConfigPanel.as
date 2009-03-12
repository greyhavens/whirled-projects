package vampire.avatar {

import com.threerings.flash.SimpleTextButton;

import flash.display.SimpleButton;
import flash.display.Sprite;
import flash.events.MouseEvent;

public class VampatarConfigPanel extends Sprite
{
    public function VampatarConfigPanel (config :VampatarConfig,
                                         showConfigCallback :Function,
                                         closePanelCallback :Function) :void
    {
        _originalConfig = config;
        _config = config.clone();
        _showConfigCallback = showConfigCallback;
        _closePanelCallback = closePanelCallback;

        var skintones :Array = [ 0xDEEFF5, 0xD0DFFD, 0xC2EDD3, 0xE1C2ED, 0xC7B4EB, 0xCCCCCC ];
        var randomize :SimpleButton = new SimpleTextButton("Randomize");
        randomize.addEventListener(MouseEvent.CLICK,
            function (...ignored) :void {
                _config.skinColor = randPick(skintones);
                _config.hairColor = rand(0xff000000, 0xffffffff);
                _config.shirtColor = rand(0xff000000, 0xffffffff);
                _config.pantsColor = rand(0xff000000, 0xffffffff);
                _config.shoesColor = rand(0xff000000, 0xffffffff);
                _config.shirtNumber = rand(1, 3);
                _config.hairNumber = rand(1, 4);
                _config.shoesNumber = rand(1, 3);
                configUpdated();
            });
        randomize.y = this.height;
        addChild(randomize);

        var reset :SimpleButton = new SimpleTextButton("Reset");
        reset.addEventListener(MouseEvent.CLICK,
            function (...ignored) :void {
                _config = _originalConfig.clone();
                configUpdated();
            });
        reset.y = this.height + 5;
        addChild(reset);

        var cancel :SimpleButton = new SimpleTextButton("Cancel");
        cancel.addEventListener(MouseEvent.CLICK,
            function (...ignored) :void {
                _closePanelCallback(null);
            });
        cancel.y = this.height + 10;
        addChild(cancel);

        var ok :SimpleButton = new SimpleTextButton("OK");
        ok.addEventListener(MouseEvent.CLICK,
            function (...ignored) :void {
                _closePanelCallback(_config);
            });
        ok.y = this.height + 5;
        addChild(ok);
    }

    protected function configUpdated () :void
    {
        _showConfigCallback(_config);
    }

    protected function randPick (arr :Array) :*
    {
        return (arr.length == 0 ? undefined : arr[rand(0, arr.length - 1)]);
    }

    protected function rand (lo :uint, hi :uint) :uint
    {
        return lo + (Math.random() * (hi - lo + 1));
    }

    protected var _originalConfig :VampatarConfig;
    protected var _config :VampatarConfig;
    protected var _showConfigCallback :Function;
    protected var _closePanelCallback :Function;
}

}
