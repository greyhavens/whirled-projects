package {

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.MovieClip;
import flash.display.Sprite;

import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.ProgressEvent;
import flash.events.TimerEvent;

import flash.geom.Point;

import flash.filters.GlowFilter;

import flash.text.TextField;
import flash.text.TextFieldType;

import flash.utils.ByteArray;
import flash.utils.Timer;

import fl.core.UIComponent;
import fl.containers.ScrollPane;
import fl.controls.Button;
import fl.controls.CheckBox;
import fl.controls.TextInput;

import com.threerings.util.EmbeddedSwfLoader;

import com.threerings.ezgame.SizeChangedEvent;

import com.whirled.WhirledGameControl;

/**
 * TODO:
 * - save captioned images.
 * - be able to view the flickr page of an image.
 */
[SWF(width="700", height="500")]
public class LOL extends Sprite
{
    public static const DEBUG :Boolean = false;

    public function LOL () 
    {
        _ctrl = new WhirledGameControl(this);
        if (!_ctrl.isConnected()) {
            var oops :TextField = new TextField();
            oops.width = 700;
            oops.height = 500;
            //oops.setStyle("fontSize", 36);
            oops.htmlText = "<P align=\"center\"><font size=\"+2\">LOLcaptions</font><br><br>" +
                "The fun flickr captioning game.<br><br>" +
                "This game is multiplayer and must be played inside Whirled.</P>";
            addChild(oops);
            return;
        }

        _ctrl.addEventListener(SizeChangedEvent.TYPE, handleSizeChanged);

        _loader = new EmbeddedSwfLoader();
        _loader.addEventListener(Event.COMPLETE, handleUILoaded);
        _loader.load(new UI() as ByteArray);

        this.root.loaderInfo.addEventListener(Event.UNLOAD, handleUnload);

        _game = new CaptionGame(_ctrl);
        _game.addEventListener(CaptionGame.TICK_EVENT, updateClock);
        _game.addEventListener(CaptionGame.PHASE_CHANGED_EVENT, checkPhase);

        _timer = new Timer(500);
        _timer.addEventListener(TimerEvent.TIMER, handleSubmitCaption);

        // get us rolling
        if (showPhoto()) {
            updateClock();
            checkPhase();
        }
    }

    protected function referenceClasses () :void
    {
        CheckBox;
        UIComponent;
        ScrollPane;
    }

    protected function handleUILoaded (event :Event) :void
    {
        _ui = _loader.getContent() as MovieClip;
        addChild(_ui);
        _loader = null;

        // scrape for children
        findNamedChildren(_ui);

        // and now do a bit of debuggery on _animations
        for each (var s :Object in _ui.scenes) {
            trace("Scene: " + s.name + " contains " + s.numFrames + " frames.");
            for each (var f :Object in s.labels) {
                trace("Frame: " + f.name);
            }
        }

//        // and now do a bit of debuggery on _animations
//        for each (var s :Object in _animations.scenes) {
//            for each (var f :Object in s.labels) {
//                var frameId :int = f.frame;
//                if (frameId > 2) {
//                    frameId -= 2;
////                    trace("Registering handler on frame " + frameId + ".");
//                    _animations.addFrameScript(frameId, handleFrameScript);
//                }
//            }
//        }
////        trace("Registering handler on frame " + (_animations.totalFrames - 2) + ".");
//        _animations.addFrameScript(_animations.totalFrames - 2, handleFrameScript);

//        skipToFrame();
    }

    protected function initCaptioning (skipAnimations :Boolean = false) :void
    {
        trace("---initCaptioning(" + skipAnimations + ")");
        _ui.gotoAndPlay(1, "Caption");
        _image = findDeepChild("image", _ui) as ScrollPane;
        var skip :CheckBox = findDeepChild(_themePrefix + "skip", _ui) as CheckBox;
        //_input = findDeepChild(_themePrefix + "input", _ui) as TextField;
        _input = findDeepChild(_themePrefix + "input", _ui) as TextInput;
        _clock = findDeepChild(_themePrefix + "clock", _ui) as TextField;
        _doneButton = findDeepChild("__id0_", _ui) as Button;

        // clean up UI bits
        skip.selected = false;

        updateClock();
        showPhoto();
        skip.addEventListener(Event.CHANGE, handleVoteToSkip);
        _doneButton.addEventListener(MouseEvent.CLICK, handleSubmitButton);
        _timer.start();
    }

    protected function findDeepChild (name :String, container :DisplayObjectContainer)
        :DisplayObject
    {
        var ii :int;
        var child :DisplayObject;
        for (ii = 0; ii < container.numChildren; ii++) {
            try {
                child = container.getChildAt(ii);
                if (child is DisplayObjectContainer) {
                    var result :DisplayObject = findDeepChild(name,
                            child as DisplayObjectContainer);
                    if (result != null) {
                        return result;
                    }
                }
            } catch (err :SecurityError) {
                // skip this child (probably a flickr image)
            }
        }

        for (ii = 0; ii < container.numChildren; ii++) {
            child = container.getChildAt(ii);
            if (child != null && child.name == name) {
                return child;
            }
        }

        return null;
    }

    /** For debugging. */
    protected function findNamedChildren (
        container :DisplayObjectContainer, spaces :String = "") :void
    {
        for (var ii :int = 0; ii < container.numChildren; ii++) {
            try {
                var child :DisplayObject = container.getChildAt(ii);
                if (child != null) {
                    trace(spaces + child.name);
                    if (child is DisplayObjectContainer) {
                        findNamedChildren(child as DisplayObjectContainer, spaces + "  ");
                    }
                }
            } catch (err :SecurityError) {
                // skip inaccessible children
            }
        }
    }

    protected function updateClock (... ignored) :void
    {
        var remaining :int = _game.getSecondsRemaining();

        var minStr :String = String(int(remaining / 60));
        var secStr :String = String(remaining % 60);
        if (secStr.length == 1) {
            secStr = "0" + secStr;
        }

        if (_clock != null) {
            _clock.text = minStr + ":" + secStr;
        }

        if (remaining == 0 && _game.getCurrentPhase() == CaptionGame.CAPTIONING_PHASE) {
            if (_input != null) {
                // TODO
                //_input.type = TextFieldType.DYNAMIC;
            }
        }
    }

    protected function checkPhase (arg :Object = null) :void
    {
        var skipAnimations :Boolean = (arg == null);

        switch (_game.getCurrentPhase()) {
        case CaptionGame.CAPTIONING_PHASE:
            initCaptioning(skipAnimations);
            break;

        case CaptionGame.VOTING_PHASE:
            initVoting(skipAnimations);
            break;

        case CaptionGame.RESULTS_PHASE:
            initResults(skipAnimations);
            break;
        }
    }

    protected function showPhoto () :Boolean
    {
        var url :String = _game.getPhoto();
        if (url != null) {
            if (_image != null) {
                _image.source = url;
            }
            return true;
        }

        return false;
    }

    protected function handleSubmitButton (event :Event) :void
    {
        trace("Submit button pressed.");
//        var nowEditing :Boolean = !_capInput.editable;
//
//        _capInput.editable = nowEditing;
//        _capPanel.setStyle("backgroundAlpha", nowEditing ? .2 : 0);
//
//        _capPanel.enterButton.label = nowEditing ? "Done" : "Edit";
//
//        if (!nowEditing) {
//            handleSubmitCaption(event);
//
//        } else {
//            // Because we're in a button's event handler, it apparently grabs focus after
//            // this, so we need to re-set the focus a frame later.
//            _capInput.callLater(_capInput.setFocus);
//        }
    }

    /**
     * Called both by the Timer event and when the user presses the (largely unneeded)
     * enter button.
     */
    protected function handleSubmitCaption (event :Event) :void
    {
        if (_input != null) {
            _game.submitCaption(_input.text);
        }
    }

    protected function handleVoteToSkip (event :Event) :void
    {
        var skipBox :CheckBox = (event.currentTarget as CheckBox);
        _game.voteToSkipPhoto(skipBox.selected);
    }

    protected function handleCaptionVote (event :Event) :void
    {
//        var box :CheckBox = (event.currentTarget as CheckBox);
//        var value :int = int(box.data);
//        _game.setCaptionVote(value, box.selected);
    }

    protected function handlePreviewVote (event :Event) :void
    {
//        var box :CheckBox = (event.currentTarget as CheckBox);
//        var value :int = int(box.data);
//        _game.setPreviewVote(value, box.selected);
    }

//    protected function initCaptioning (skipAnimations :Boolean) :void
//    {
//        if (_capPanel != null) {
//            _ui.removeChild(_capPanel);
//            _capPanel = null;
//        }
//        if (_capInput != null) {
//            _ui.removeChild(_capInput);
//            _capInput = null;
//        }
//        if (_grid != null) {
//            _ui.removeChild(_grid);
//            _grid = null;
//        }
//        if (_nextPanel != null) {
//            _ui.removeChild(_nextPanel);
//            _nextPanel = null;
//        }
//
//        if (skipAnimations) {
//            skipToFrame();
//            _image.alpha = 1;
//            showPhoto();
//            setupCaptioningUI();
//
//        } else {
//            _phasePhase = 0;
//            _image.alpha = 0;
//            showPhoto();
//            doFade(_image, 0, 1);
//            animateToFrame(setupCaptioningUI);
//        }
//    }

    protected function setupCaptioningUI () :void
    {
//        _phasePhase = 1;
//        _captionOnBottom = true;
//        _timer.start();
//
//        _capPanel = new CaptionPanel();
//        _capPanel.includeInLayout = false;
//        _ui.addChild(_capPanel);
//
//        _capInput = new CaptionTextArea();
//        _capInput.includeInLayout = false;
//
//        _ui.addChild(_capInput);
//        _capInput.calculateHeight();
//
//        _capPanel.enterButton.addEventListener(FlexEvent.BUTTON_DOWN, handleSubmitButton);
//        _capPanel.skip.addEventListener(Event.CHANGE, handleVoteToSkip);
//
//        // validate the panel now so that we know the _capPanel.height in updateLayout()
//        _ui.validateNow();
//
//        doFade(_capPanel, 0, 1, 2000);
//
//        updateLayout();
    }

    /**
     * Configure layout stuff for the voting or results phases.
     */
    protected function initNonCaption () :void
    {
//        if (_capPanel != null) {
//            _ui.removeChild(_capPanel);
//            _capPanel = null;
//        }
//
//        if (_capInput != null) {
//            _ui.removeChild(_capInput);
//            _capInput = null;
//        }
//
//        if (_grid != null) {
//            _ui.removeChild(_grid);
//            _grid = null;
//        }
    }

    protected function initVoting (skipAnimations :Boolean) :void
    {
        trace("---initVoting(" + skipAnimations + ")");
        _ui.gotoAndPlay(1, "Voting");

        findNamedChildren(_ui);


//        initNonCaption();
//
//        if (skipAnimations) {
//            _image.alpha = 1;
//            _gradientBackground.alpha = 1;
//            skipToFrame();
//            setupVotingUI();
//
//        } else {
//            _phasePhase = 0;
//            doFade(_image, 1, 0);
//            _gradientBackground.alpha = 0;
//            updateLayout();
//            animateToFrame(setupVotingUI);
//        }
    }

    protected function setupVotingUI () :void
    {
//        _phasePhase = 1;
//        _grid = new Grid();
//        _ui.addChild(_grid);
//        doFade(_gradientBackground, 0, 1, 2000);
//
//        if (_image.alpha != 1) {
//            doFade(_image, 0, 1);
//        }
//
//        var caps :Array = _game.getVotableCaptions();
//        var ourIdx :int = _game.getOurCaptionIndex();
//
//for (var jj :int = 0; jj < (DEBUG ? 20 : 1); jj++) {
//        for (var ii :int = 0; ii < caps.length; ii++) {
//            var row :VotingRow = new VotingRow();
//            _grid.addChild(row);
//            row.captionText.htmlText = deHTML(String(caps[ii]));
//            row.voteButton.data = ii;
//            row.voteButton.addEventListener(Event.CHANGE, handleCaptionVote);
//            if (ii == ourIdx) {
//                row.voteButton.enabled = false;
//            }
//        }
//}
//
//        updateLayout();
    }

    protected function initResults (skipAnimations :Boolean) :void
    {
        findNamedChildren(_ui);
        trace("---initResults(" + skipAnimations + ")");
        _ui.gotoAndPlay(0, "Winner");
//        initNonCaption();
//        _grid = new Grid();
//        computeResults(skipAnimations);
//
//        if (skipAnimations) {
//            _image.alpha = 1;
//            _gradientBackground.alpha = 1;
//            skipToFrame();
//            setupResultsUI();
//
//        } else {
//            _capInput.alpha = 0;
//            _phasePhase = 0;
//            doFade(_image, 1, 0);
//            doFade(_gradientBackground, 1, 0);
//            _gradientBackground.alpha = 0;
//            updateLayout();
//            animateToFrame(setupWinnerUI, "Winner");
//        }
    }

    protected function setupWinnerUI () :void
    {
//        _phasePhase = 1;
//        doFade(_image, 0, 1);
//        doFade(_capInput, 0, 1);
//        doFade(_winnerLabel, 0, 1);
//        updateLayout();
//
//        _winnerTimer.reset();
//        _winnerTimer.start();
    }

    protected function handleWinnerTimer (event :TimerEvent) :void
    {
//        _phasePhase = 2;
//        doFade(_image, 1, 0);
//        doFade(_capInput, 1, 0);
//        doFade(_winnerLabel, 1, 0);
//        animateToFrame(setupResultsUI);
    }

    protected function computeResults (skipAnimations :Boolean) :void
    {
//        _capInput = new CaptionTextArea();
//        _captionOnBottom = true;
//        _capInput.includeInLayout = false;
//        _capInput.editable = false;
//        _ui.addChild(_capInput);
//        _capInput.calculateHeight();
//
//        if (!skipAnimations) {
//            _winnerLabel = new Label();
//            _winnerLabel.alpha = 0;
//            _winnerLabel.includeInLayout = false;
//            _winnerLabel.setStyle("fontSize", 36);
//            _winnerLabel.setStyle("textAlign", "center");
//            // if I don't put the glowfilter on, it doesn't respect the setting to alpha
//            _winnerLabel.filters = [ new GlowFilter(0x000000, 1, 1, 1, 1) ];
//            _ui.addChild(_winnerLabel);
//        }
//
//        var results :Array = _game.getResults();
//
//for (var jj :int = 0; jj < (DEBUG ? 20 : 1); jj++) {
//        for (var ii :int = 0; ii < results.length; ii++) {
//
////            if (ii > 0) {
////                _grid.addChild(new HSeparator());
////            }
//
//            var result :Object = results[ii];
//
//            var row :ResultRow = new ResultRow();
//            _grid.addChild(row);
//            row.captionText.htmlText = deHTML(String(result.caption));
//            row.nameAndVotesLabel.text = "- " + result.playerName + ", " + result.votes;
//
//            if (ii == 0) {
//                _capInput.text = String(result.caption);
//                if (_winnerLabel != null) {
//                    _winnerLabel.text = result.playerName + " wins!";
//                }
//            }
//
//            if (result.winner) {
//                row.statusIcon.source = WINNER_ICON;
//
//            } else if (result.disqual) {
//                row.statusIcon.source = DISQUAL_ICON;
//            }
//        }
//}
    }

    protected function setupResultsUI () :void
    {
//        _phasePhase = 3;
//
//        if (_winnerLabel != null) {
//            _ui.removeChild(_winnerLabel);
//            _winnerLabel = null;
//        }
//
//        _ui.addChild(_grid);
//        doFade(_gradientBackground, 0, 1, 2000);
//
//        if (_image.alpha != 1) {
//            doFade(_capInput, 0, 1);
//            doFade(_image, 0, 1);
//        }
//
//        _nextPanel = new Canvas();
//        _ui.addChild(_nextPanel);
//
//        // see if there are any preview pics to vote on...
//        var previews :Array = _game.getPreviews();
//        for (var ii :int = 0; ii < previews.length; ii++) {
//            addPreviewPhoto(_nextPanel, ii, previews[ii]);
//        }
//
//        updateLayout();
    }

//    protected function addPreviewPhoto (panel :Canvas, number :int, url :String) :void
//    {
//        if (url == null) {
//            return;
//        }
//        // once again, it's easier for me to hard-code this layout
//        // than to fight with flex layout to accomplish the same thing.
//        // (Part of the reason for this is that the checkbox takes up retarded
//        // amounts of space, even when the label is blank)
//        var img :Image = new Image();
//        var cb :CheckBox = new CheckBox();
//        cb.label = " "; // prevent buggage
//        cb.data = number;
//        cb.addEventListener(Event.CHANGE, handlePreviewVote);
//
//        img.addEventListener(MouseEvent.CLICK, function (evt :MouseEvent) :void {
//            cb.selected = !cb.selected;
//        });
//        
//        cb.includeInLayout = false;
//
//        img.x = ((number % 2) == 0) ? 14 : 140;
//        img.y = (int(number / 2) == 0) ? 1 : 111;
//        cb.x = ((number % 2) == 0) ? 0 : 126;
//        cb.y = (int(number / 2) == 0) ? 0 : 110;
//        panel.addChild(img);
//        panel.addChild(cb);
//        img.load(url);
//    }

    protected function deHTML (s :String) :String
    {
        s = s.replace("&", "&amp;");
        s = s.replace("<", "&lt;");
        s = s.replace(">", "&gt;");

        return s;
    }

    /**
     * Handle image loading.
     */
    protected function handleImageProgress (event :ProgressEvent) :void
    {
//        updateLayout();
    }

    /**
     * Handle image loading.
     */
    protected function handleImageComplete (event :Event) :void
    {
//        updateLayout();
    }

    /**
     * Handle toggling the position of the caption input area from the top of the image
     * to the bottom.
     */
    protected function handlePositionToggle (event :Event) :void
    {

    // TODO: this is kinda annoying?
//        _captionOnBottom = !_captionOnBottom;
//
//        recheckInputBounds();
    }

    protected function handleFrameScript () :void
    {
//        trace("+=== ah-ha, I reached frame # " + _animations.currentFrame);

        // TODO: stopping the goddamn thing shouldn't be needed
        _ui.gotoAndStop(_ui.currentFrame);

        // possibly call the callback
        var fn :Function = _frameReachedCallback;
        if (fn != null) {
            _frameReachedCallback = null;
            fn();
        }
    }

    /**
     * Get the _animations sequence for the current phase.
     */
    protected function getFrameForPhase () :String
    {
        switch (_game.getCurrentPhase()) {
        default:
            return "Caption";

        case CaptionGame.VOTING_PHASE:
            return "Voting";

        case CaptionGame.RESULTS_PHASE:
            return "Results";
        }
    }

    protected function animateToFrame (frameReachedCallback :Function, frame :String = null) :void
    {
        if (_ui != null) {
            _frameReachedCallback = frameReachedCallback;
            if (frame == null) {
                frame = getFrameForPhase();
            }
//            trace("animating to frame: " + frame);
            _ui.gotoAndPlay(frame);

        } else {
            // better just go straight there, and we'll do the skipToFrame when it loads
            frameReachedCallback();
        }
    }

    protected function skipToFrame () :void
    {
        if (_ui == null) {
            return;
        }

        var frame :String = getFrameForPhase();
        var found :Boolean = false;
        for each (var s :Object in _ui.scenes) {
            for each (var f :Object in s.labels) {
                if (found) {
                    _ui.gotoAndPlay(f.frame - 1);
                    return;
                }
                if (f.name == frame) {
                    found = true;
                    // so that we go to the NEXT one...
                }
            }
        }

        if (found) {
            _ui.gotoAndPlay(_ui.totalFrames - 1);
        }
    }

    protected function handleSizeChanged (event :SizeChangedEvent) :void
    {
        // TODO
    }

    protected function updateSize (size :Point) :void
    {
//        _ui.width = size.x;
//        _ui.height = size.y;
//
//        updateLayout();
    }

//    protected function imageWidth () :int
//    {
//        var width :int = _image.contentWidth;
//        return (width != 0) ? width : 500;
//    }
//
//    protected function imageHeight () :int
//    {
//        var height :int = _image.contentHeight;
//        return (height != 0) ? height : 500;
//    }
//
//    protected function centerImage (scale :Number = 1) :void
//    {
//        _image.scaleX = scale;
//        _image.scaleY = scale;
//        _image.x = (_ui.width - (imageWidth() * scale)) / 2;
//        _image.y = (_ui.height - (imageHeight() * scale)) / 2;
//    }
//
//    protected function sidebarImage () :void
//    {
//        _image.scaleX = .5;
//        _image.scaleY = .5;
//        _image.y = PAD;
//        _image.x = (SIDE_BAR_WIDTH - (.5 * imageWidth())) / 2;
//    }

    protected function handleUnload (... ignored) :void
    {
        _timer.reset();
    }

    [Embed(source="rsrc/winner_icon.png")]
    protected static const WINNER_ICON :Class;

    [Embed(source="rsrc/dq_icon.png")]
    protected static const DISQUAL_ICON :Class;

    [Embed(source="rsrc/ui.swf", mimeType="application/octet-stream")]
    protected static const UI :Class;

    protected static const PAD :int = 6;

    protected static const IDEAL_WIDTH :int = 700;

    protected static const TOP_BAR_HEIGHT :int = 66;

    protected static const SIDE_BAR_WIDTH :int = 250 + (PAD * 2);

    protected var _ctrl :WhirledGameControl;

    protected var _game :CaptionGame;

    protected var _ui :MovieClip;

    protected var _loader :EmbeddedSwfLoader;

    protected var _frameReachedCallback :Function;

    protected var _themePrefix :String = "lol_";

    protected var _image :ScrollPane;

//    protected var _input :TextField;
    protected var _input :TextInput;

    protected var _clock :TextField;

    protected var _doneButton :Button;

    /** Which phase of animating the current phase are we in? */
    protected var _phasePhase :int;

    /** Whether the caption is on the bottom or top. */
    protected var _captionOnBottom :Boolean;

    protected var _timer :Timer;
}
}
