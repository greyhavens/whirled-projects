package vampire.quest.client {

import com.threerings.flash.SimpleTextButton;
import com.whirled.contrib.simplegame.objects.SceneObject;

import flash.display.DisplayObject;
import flash.display.Graphics;
import flash.display.SimpleButton;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.text.TextField;

import vampire.quest.*;
import vampire.quest.activity.*;

public class ActivityPanel extends SceneObject
{
    public function ActivityPanel (loc :LocationDesc)
    {
        _loc = loc;

        var layout :Sprite = new Sprite();

        var tfName :TextField = TextBits.createText(loc.displayName, 2, 0, 0xff0000);
        tfName.x = -tfName.width * 0.5;
        tfName.y = layout.height;
        layout.addChild(tfName);

        if (loc.activities.length == 0) {
            var tf :TextField = TextBits.createText("Nothing to do here.", 1.2, 0, 0xffffff);
            tf.x = -tf.width * 0.5;
            tf.y = layout.height;
            layout.addChild(tf);

        } else {
            for each (var activity :ActivityDesc in loc.activities) {
                var btn :SimpleButton = makeActivityButton(activity);
                btn.x = -btn.width * 0.5;
                btn.y = layout.height;
                layout.addChild(btn);
            }
        }

        var closeBtn :SimpleButton = new SimpleTextButton("Leave");
        registerOneShotCallback(closeBtn, MouseEvent.CLICK,
            function (...ignored) :void {
                QuestClient.hideActivityPanel();
            });

        closeBtn.x = -closeBtn.width * 0.5;
        closeBtn.y = layout.height;
        layout.addChild(closeBtn);

        layout.x = layout.width * 0.5;
        layout.y = 0;
        _sprite = new Sprite();
        _sprite.addChild(layout);
        var g :Graphics = _sprite.graphics;
        g.beginFill(0);
        g.drawRect(0, 0, _sprite.width, _sprite.height);
        g.endFill();
    }

    protected function makeActivityButton (activity :ActivityDesc) :SimpleButton
    {
        var btn :SimpleButton = new SimpleTextButton(activity.displayName);
        registerListener(btn, MouseEvent.CLICK,
            function (...ignored) :void {
                QuestClient.beginActivity(activity);
            });
        return btn;
    }

    override public function get displayObject () :DisplayObject
    {
        return _sprite;
    }

    protected var _loc :LocationDesc;

    protected var _sprite :Sprite;
}
}
