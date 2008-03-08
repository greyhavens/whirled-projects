// $Id$

package com.threerings.graffiti {

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

import com.threerings.graffiti.tools.ToolBox;
import com.threerings.graffiti.tools.ToolEvent;

[SWF(width="405", height="486")]
public class Graffiti extends Sprite
{
    public function Graffiti () 
    {
        _control = new FurniControl(this);
        if (_control.isConnected()) {
            var throttle :Throttle = new Throttle(_control);
            // each instance maintains a Manager.  The inControl() instance's Manager is in effect.
            _manager = new Manager(throttle);
            _model = new OnlineModel(throttle);
        } else {
            _model = new OfflineModel();
        }
        var canvas :Canvas = new Canvas(_model);
        addChild(canvas);

        _editBtn = new EDIT_BUTTON() as SimpleButton;
        _editBtn.x = Canvas.CANVAS_WIDTH - _editBtn.width / 2;
        _editBtn.y = Canvas.CANVAS_HEIGHT + _editBtn.height / 2 - 1;
        _editBtn.addEventListener(MouseEvent.CLICK, displayEditPopup);

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
        _control.showPopup(
            "Editing Graffiti", canvas.toolbox, ToolBox.POPUP_WIDTH, ToolBox.POPUP_HEIGHT, 0, 0);
    }

    protected function enterFrame (event :Event) :void
    {
        if (_mouseOver) {
            if (_editBtn.parent != this) {
                addChildAt(_editBtn, 0);
                _editBtn.x = Canvas.CANVAS_WIDTH - _editBtn.width / 2 - 3;
                _editBtn.y = Canvas.CANVAS_HEIGHT - _editBtn.height / 2;
            }

            _editBtn.y = Math.min(_editBtn.y + 5, Canvas.CANVAS_HEIGHT + _editBtn.height / 2 - 2);
        } else if (_editBtn.parent == this) {
            _editBtn.y -= 5;
            if (_editBtn.y < Canvas.CANVAS_HEIGHT - _editBtn.height / 2) {
                removeChild(_editBtn);
            }
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

    protected var _control :FurniControl;
    protected var _manager :Manager;
    protected var _model :Model;
    protected var _editBtn :SimpleButton;
    protected var _mouseOver :Boolean; 
}
}
