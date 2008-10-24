//
// $Id$

package ghostbusters.client {

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.SimpleButton;
import flash.text.TextField;

import flash.events.MouseEvent;

import com.threerings.util.Command;

import com.threerings.flash.DisplayUtil;

import ghostbusters.client.Content;
import ghostbusters.data.Codes;

public class SplashWidget extends ClipHandler
{
    public static const STATE_WELCOME :String = "welcome";
    public static const STATE_HOWTO :String = "howto";
    public static const STATE_AVATARS :String = "avatars";
    public static const STATE_BEGIN :String = "begin";

    public function SplashWidget (state :String)
    {
        _state = state;

        super(new Content.SPLASH(), handleSplashLoaded);
        
       
        

    }

    public function get state () :String
    {
        return _state;
    }

    public function gotoState (state :String) :void
    {
        trace(" gotoState " + state); 
        _state = state;
        renderState();
    }

    protected function handleSplashLoaded () :void
    {
        //SKIN we go straight to the begin screen
//        setupWelcome();
        setupHowto();
//        setupAvatars();
        setupBegin();

        renderState();
    }

    protected function renderState () :void
    {
//        _welcome.visible = (_state == STATE_WELCOME);
        _howto.visible = (_state == STATE_HOWTO);
//        _avatars.visible = (_state == STATE_AVATARS);
        _begin.visible = (_state == STATE_BEGIN);
    }

//    protected function setupWelcome () :void
//    {
//        trace("setupWelcome(), should not be here");
//        _welcome = DisplayObjectContainer(findSafely(this.clip, DSP_WELCOME));
//
//        findSafely(_welcome, BTN_WELCOME_CONTINUE).addEventListener(
//            MouseEvent.CLICK, function (evt :MouseEvent) :void {
//                gotoState(STATE_AVATARS);
//        });
//
//        findSafely(_welcome, BTN_WELCOME_HOWTO).addEventListener(
//            MouseEvent.CLICK, function (evt :MouseEvent) :void {
//                gotoState(STATE_HOWTO);
//        });
//
//        Command.bind(findSafely(_welcome, BTN_WELCOME_CLOSE), MouseEvent.CLICK,
//                     GameController.CLOSE_SPLASH);
//    }

    protected function setupHowto () :void
    {
        _howto = DisplayObjectContainer(findSafely(this.clip, DSP_HOWTO));
        if( _howto != null ) {
            _howto.visible = false;
        }     
        // only show the 'back' button if we have not yet chosen an avatar
//        var button :DisplayObject = findSafely(_howto, BTN_HOWTO_BACK);
//        //SKIN changing the howto -> begin
//        if( button != null) {
//            button.visible = false;
//        }
//        if (Game.control.player.props.get(Codes.PROP_AVATAR_TYPE) == null) {
//            button.visible = true;
//            button.addEventListener(
//                MouseEvent.CLICK, function (evt :MouseEvent) :void {
//                    gotoState(STATE_WELCOME);
//            });
//
//        } else {
//            button.visible = false;
//        }

        Command.bind(findSafely(_howto, BTN_WELCOME_CONTINUE), MouseEvent.CLICK,
                     GameController.CLOSE_SPLASH);
    }

//    protected function setupAvatars () :void
//    {
//        trace("setupAvatars(), should not be here");
//        _avatars = DisplayObjectContainer(findSafely(this.clip, DSP_AVATARS));
//
//        findSafely(_avatars, BTN_AVATARS_BACK).addEventListener(
//            MouseEvent.CLICK, function (evt :MouseEvent) :void {
//                gotoState(STATE_WELCOME);
//        });
//
//        Command.bind(findSafely(_avatars, BTN_AVATARS_CLOSE), MouseEvent.CLICK,
//                     GameController.CLOSE_SPLASH);
//        Command.bind(findSafely(_avatars, BTN_AVATARS_CHOOSE_MALE), MouseEvent.CLICK,
//                     GameController.CHOOSE_AVATAR, Codes.AVT_MALE);
//        Command.bind(findSafely(_avatars, BTN_AVATARS_CHOOSE_FEMALE), MouseEvent.CLICK,
//                     GameController.CHOOSE_AVATAR, Codes.AVT_FEMALE);
//    }

//    protected function setupBegin () :void
//    {
//        _begin = DisplayObjectContainer(findSafely(this.clip, DSP_BEGIN));
//
//        Command.bind(findSafely(_begin, BTN_BEGIN_CLOSE), MouseEvent.CLICK,
//                     GameController.CLOSE_SPLASH);
//        Command.bind(findSafely(_begin, BTN_BEGIN_BEGIN), MouseEvent.CLICK,
//                     GameController.BEGIN_PLAYING);
//    }

    protected function setupBegin () :void
    {
        _begin = DisplayObjectContainer(findSafely(this.clip, DSP_WELCOME));
        if( _begin != null) {
            _begin.visible = false;
        }
//        if( _begin == null)
        //SKIN "set" an avater.  We don't use avatars, we simply use 
        //this as a switch to determine whether to show the help again.
        Command.dispatch(findSafely(_begin, DSP_WELCOME),
             GameController.CHOOSE_AVATAR, Codes.AVT_FEMALE);


//        Command.bind(findSafely(_begin, BTN_BEGIN_CLOSE), MouseEvent.CLICK,
//                     GameController.CLOSE_SPLASH);
        Command.bind(findSafely(_begin, BTN_WELCOME_CONTINUE), MouseEvent.CLICK,
                     GameController.BEGIN_PLAYING);
        Command.bind(findSafely(_begin, BTN_WELCOME_CONTINUE), MouseEvent.CLICK,
                     GameController.CLOSE_SPLASH);
    }
    
    protected function findSafely (parent :DisplayObjectContainer, name :String) :DisplayObject
    {
        var o :DisplayObject = DisplayUtil.findInHierarchy(parent, name);
        if (o == null) {
            throw new Error("Cannot find object: " + name);
        }
        return o;
    }

    protected var _state :String;

//    protected var _welcome :DisplayObjectContainer;
    protected var _howto :DisplayObjectContainer;
//    protected var _avatars :DisplayObjectContainer;
    protected var _begin :DisplayObjectContainer;


    //SKIN we don't have any of this other media, so make sure we don't accidentally include it.
    protected static const DSP_WELCOME :String = "welcomescreen";
    protected static const DSP_HOWTO :String = "HowTo";
//    protected static const DSP_AVATARS :String = "ChooseAvatar";
//    protected static const DSP_BEGIN :String = "equipavatar";

    protected static const BTN_WELCOME_CONTINUE :String = "continuebutton";
//    protected static const BTN_WELCOME_HOWTO :String = "howdoibutton";
//    protected static const BTN_WELCOME_CLOSE :String = "close";

//    protected static const BTN_AVATARS_BACK :String = "backbutton";
//    protected static const BTN_AVATARS_CLOSE :String = "close";
//    protected static const BTN_AVATARS_CHOOSE_MALE :String = "choose_male";
//    protected static const BTN_AVATARS_CHOOSE_FEMALE :String = "choose_female";

//    protected static const BTN_HOWTO_BACK :String = "backbutton";
//    protected static const BTN_HOWTO_CLOSE :String = "close";
//
//    protected static const BTN_BEGIN_CLOSE :String = "close";
//    protected static const BTN_BEGIN_BEGIN :String = "beginbutton";
}
}
