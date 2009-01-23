package redrover {

import com.threerings.util.ArrayUtil;
import com.whirled.contrib.simplegame.AppMode;
import com.whirled.contrib.simplegame.resource.ImageResource;

import flash.display.Bitmap;
import flash.display.SimpleButton;
import flash.display.Sprite;
import flash.events.MouseEvent;

import redrover.ui.UIBits;
import redrover.util.SpriteUtil;

public class InstructionsMode extends AppMode
{
    override protected function setup () :void
    {
        if (_bitmaps == null) {
            _bitmaps = ArrayUtil.create(IMAGE_NAMES.length, null);
        }

        _pageParent = SpriteUtil.createSprite();
        _modeSprite.addChild(_pageParent);

        _nextButton = UIBits.createButton("Next", 1.5);
        registerListener(_nextButton, MouseEvent.CLICK,
            function (...ignored) :void {
                if (_index < IMAGE_NAMES.length - 1) {
                    setPageIndex(_index + 1);
                }
            });
        _nextButton.x = Constants.SCREEN_SIZE.x - _nextButton.width - 10;
        _nextButton.y = Constants.SCREEN_SIZE.y - _nextButton.height - 10;
        _modeSprite.addChild(_nextButton);

        _prevButton = UIBits.createButton("Back", 1.5);
        registerListener(_prevButton, MouseEvent.CLICK,
            function (...ignored) :void {
                if (_index > 0) {
                    setPageIndex(_index - 1);
                }
            });
        _prevButton.x = _nextButton.x;
        _prevButton.y = _nextButton.y - _prevButton.height - 5;
        _modeSprite.addChild(_prevButton);

        _playButton = UIBits.createButton("Play!", 1.5);
        registerListener(_playButton, MouseEvent.CLICK,
            function (...ignored) :void {
                AppContext.mainLoop.popMode();
            });
        _playButton.x = Constants.SCREEN_SIZE.x - _playButton.width - 10;
        _playButton.y = Constants.SCREEN_SIZE.y - _playButton.height - 10;
        _modeSprite.addChild(_playButton);

        setPageIndex(0);
    }

    protected function setPageIndex (val :int) :void
    {
        _index = val;

        if (_bitmaps[_index] == null) {
            _bitmaps[_index] =
                ImageResource.instantiateBitmap(AppContext.rsrcs, IMAGE_NAMES[_index]);
        }

        if (_curPage != null) {
            _curPage.parent.removeChild(_curPage);
        }

        _curPage = _bitmaps[_index];
        _pageParent.addChild(_curPage);

        _prevButton.visible = (_index > 0);
        _nextButton.visible = (_index < IMAGE_NAMES.length - 1);
        _playButton.visible = (_index == IMAGE_NAMES.length - 1);
    }

    protected var _index :int;
    protected var _pageParent :Sprite;
    protected var _curPage :Bitmap;
    protected var _nextButton :SimpleButton;
    protected var _prevButton :SimpleButton;
    protected var _playButton :SimpleButton;

    protected static var _bitmaps :Array;

    protected static const IMAGE_NAMES :Array = [
        "instructions_1", "instructions_2", "instructions_3"
    ];

}

}
