//
// $Id$

package locksmith.view {

import flash.display.Sprite;
import flash.geom.Point;

import com.threerings.util.Log;

import locksmith.events.EventManagerFactory;
import locksmith.model.LocksmithModel;
import locksmith.model.RingManager;

public class LocksmithView extends LocksmithSprite
{
    public function LocksmithView (model :LocksmithModel, eventMgrFactory :EventManagerFactory)
    {
        super(eventMgrFactory.createEventManager());
        _model = model;
        _eventMgrFactory = eventMgrFactory;

        addChild(_leftBackground = new BACKGROUND() as Sprite);
        addChild(_rightBackground = new BACKGROUND() as Sprite);
        addChild(_board = new Board());
        conditionalCall(ringsCreated, _model.ringMgr.smallestRing != null, 
            RingManager.RINGS_CREATED, _model.ringMgr);
    }

    public function updateSize (viewSize :Point) :void
    {
        _leftBackground.width = _rightBackground.width = 
            Math.max(0, (viewSize.x - DISPLAY_WIDTH) / 2) + 1;
        _rightBackground.x = viewSize.x - _rightBackground.width;
        _board.x = DISPLAY_WIDTH / 2 + _leftBackground.width - 0.5;
        _board.y = DISPLAY_HEIGHT/ 2;
    }

    protected function ringsCreated () :void
    {
    }

    [Embed(source="../../../rsrc/fill_image.png",
        scaleGridTop="28", scaleGridBottom="470", scaleGridLeft="28", scaleGridRight="285")]
    protected static const BACKGROUND :Class;

    // the sizes of the game display not including the background image that's used to fill up the
    // extra
    protected static const DISPLAY_WIDTH :int = 700;
    protected static const DISPLAY_HEIGHT :int = 500;

    protected var _model :LocksmithModel;
    protected var _eventMgrFactory :EventManagerFactory;
    protected var _leftBackground :Sprite;
    protected var _rightBackground :Sprite;
    protected var _board :Board;

    private static const log :Log = Log.getLog(LocksmithView);
}
}
