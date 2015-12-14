package {

import com.threerings.ui.SimpleTextButton;
import com.whirled.contrib.CheatDetector;

import flash.display.Sprite;
import flash.text.TextField;

import vampire.combat.debug.Debug;


[SWF(width="1000", height="600")]
public class VampireAVRG extends Sprite
{
    public function VampireAVRG()
    {
        new MovieClipBody(null, null, 0, 0);
//        var a :int = 3;
//        var b :int = 3;//int(a);
////        b++;
////        b--;
////
////        trace("a == b: " + (a == b));
////        trace("a === b: " + (a === b));
////        return;
//
//
//        function cheater (key :String) :void {
//            trace("Cheat on " + key);
//        }
//        ch = new CheatDetector(cheater);
////
//////        var k :String = "aaa";
//        ch.set("aaa", 3);
//        trace(ch.get("aaa"));
//        return;
////
////        trace(ch.get("aaa"));
////        ch.update(1);
////        ch._detection1["aaa"][0] = 2;
////        ch.update(1);
//
//
//        addEventListener(Event.ENTER_FRAME, enterFrame);
//
//        text = new TextField();
//        addChild(text);
//        text.x = 10;
//        text.y = 10;
//
//        button = new SimpleTextButton("increment");
//        addChild(button);
//        button.x = 10;
//        button.y = 30;
//        function addScore (...ignored) :void {
////            score += 10;
//            ch.set("score", ch.get("score") + 10);
//        }
//        button.addEventListener(MouseEvent.CLICK, addScore);
////        score = 666666
//        ch.set("score", 666666);

//        ch._detection1["score"][1] = 666666;
//        ch._detection1["score"][2] = 666666;


        addChild(new Debug());
//        VConstants.LOCAL_DEBUG_MODE = true;
//        ServerContext.server = new GameServer();
//        ClientContext.init(new AVRGameControlFake(this));
//        addChild(new VampireMain());
//        graphics.lineStyle(2,0);
//        graphics.drawRect(0, 0, ClientContext.ctrl.local.getRoomBounds()[0] - 2,ClientContext.ctrl.local.getRoomBounds()[1] - 2);
//        graphics.lineStyle(2,0);
//        graphics.drawRect(0, 0, ClientContext.ctrl.local.getPaintableArea().width - 2,ClientContext.ctrl.local.getPaintableArea().height - 2);

    }
    protected function enterFrame (...ignored) :void
    {
        ch.update(1);
        text.text = "" + ch.get("score");

//        trace(ch);
    }

    protected var ch :CheatDetector;
    protected var text :TextField;
    protected var button :SimpleTextButton;
//    public var score :int;
}
}
