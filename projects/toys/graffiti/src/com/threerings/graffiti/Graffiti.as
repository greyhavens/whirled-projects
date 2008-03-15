// $Id$

package com.threerings.graffiti {

import flash.display.DisplayObject;
import flash.display.SimpleButton;
import flash.display.Sprite;

import flash.events.Event;
import flash.events.MouseEvent;

import com.threerings.util.Log;

import com.whirled.FurniControl;

import com.threerings.graffiti.model.Model;
import com.threerings.graffiti.model.OfflineModel;
import com.threerings.graffiti.model.OnlineModel;

import com.threerings.graffiti.throttle.Throttle;
import com.threerings.graffiti.throttle.ThrottleEvent;

import com.threerings.graffiti.tools.ToolBox;
import com.threerings.graffiti.tools.ToolEvent;

[SWF(width="600", height="486")]
public class Graffiti extends Sprite
{
    public function Graffiti () 
    {
        _control = new FurniControl(this);
        if (_control.isConnected()) {
            _throttle = new Throttle(_control);
            // each instance maintains a Manager.  The inControl() instance's Manager is in effect.
            _manager = new Manager(_throttle);
            _model = new OnlineModel(_throttle);
        } else {
            _model = new OfflineModel();
        }
        var canvas :Canvas = new Canvas(_model);
        addChild(canvas);

        _editBtn = new EDIT_BUTTON() as SimpleButton;
        _editBtn.x = Canvas.CANVAS_WIDTH - _editBtn.width / 2 - 1;
        _editBtn.addEventListener(MouseEvent.CLICK, displayEditPopup);

        _managerBtn = new MANAGER_BUTTON() as Sprite;
        _managerBtn.x = _managerBtn.width / 2 + 5;
        (_managerBtn as Object).reset_button.addEventListener(MouseEvent.CLICK, resetCanvas);
        (_managerBtn as Object).lockbutton.addEventListener(MouseEvent.CLICK, toggleLock);

        addEventListener(MouseEvent.MOUSE_OVER, mouseOver);
        addEventListener(MouseEvent.MOUSE_OUT, mouseOut);
        addEventListener(Event.ENTER_FRAME, enterFrame);
        _control.addEventListener(Event.UNLOAD, unload);
    }

    protected function displayEditPopup (event :MouseEvent) :void
    {
        var canvas :Canvas = new Canvas(_model);
        canvas.toolbox.addEventListener(ToolEvent.DONE_EDITING, function (event :ToolEvent) :void {
            _control.clearPopup();
        });
        canvas.toolbox.addEventListener(Event.REMOVED_FROM_STAGE, function (event :Event) :void {
            _throttle.removeEventListener(ThrottleEvent.MANAGER_MESSAGE, 
                                          canvas.toolbox.managerMessageReceived);
        });
        _control.showPopup(
            "Editing Graffiti", canvas.toolbox, ToolBox.POPUP_WIDTH, ToolBox.POPUP_HEIGHT, 0, 0);
        _throttle.addEventListener(ThrottleEvent.MANAGER_MESSAGE,
                                   canvas.toolbox.managerMessageReceived);

    }

    protected function resetCanvas (event :MouseEvent) :void
    {
        // TODO
        log.debug("reset canvas");
    }

    protected function toggleLock (event :MouseEvent) :void
    {
        // TODO
        log.debug("lock toggled");
    }

    protected function enterFrame (event :Event) :void
    {
        if (_mouseOver) {
            animateDown(_editBtn);
            if (_control.canEditRoom()) {
                animateDown(_managerBtn);
            }
        } else {
            animateUp(_editBtn);
            animateUp(_managerBtn);
        }
    }

    protected function animateDown (button :DisplayObject) :void
    {
        if (button.parent != this) {
            addChildAt(button, 0);
            button.y = Canvas.CANVAS_HEIGHT - button.height / 2;
        }

        button.y = Math.min(_editBtn.y + 5, Canvas.CANVAS_HEIGHT + button.height / 2 - 2);
    }

    protected function animateUp (button :DisplayObject) :void
    {
        button.y -= 5;
        if (button.y < Canvas.CANVAS_HEIGHT - button.height / 2 && button.parent == this) {
            removeChild(button);
        }
    }

    protected function mouseOver (event :MouseEvent) :void
    {
        _mouseOver = true;
    }

    protected function mouseOut (event :MouseEvent) :void
    {
        _mouseOver = false;
    }

    protected function unload (event :Event) :void
    {
        removeEventListener(Event.ENTER_FRAME, enterFrame);
    }

    private static const log :Log = Log.getLog(Graffiti);

    [Embed(source="../../../../rsrc/edit_manager_buttons.swf#editbutton")]
    protected static const EDIT_BUTTON :Class;
    [Embed(source="../../../../rsrc/edit_manager_buttons.swf#manager")]
    protected static const MANAGER_BUTTON :Class;

    protected var _control :FurniControl;
    protected var _manager :Manager;
    protected var _model :Model;
    protected var _throttle :Throttle;
    protected var _editBtn :SimpleButton;
    protected var _managerBtn :Sprite;
    protected var _mouseOver :Boolean; 
}
}
