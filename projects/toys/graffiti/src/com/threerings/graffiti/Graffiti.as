// $Id$

package com.threerings.graffiti {

import flash.display.DisplayObject;
import flash.display.SimpleButton;
import flash.display.Sprite;

import flash.events.Event;
import flash.events.MouseEvent;

import flash.utils.ByteArray;

import com.threerings.util.Log;

import com.whirled.ControlEvent;
import com.whirled.FurniControl;

import com.threerings.graffiti.model.Model;
import com.threerings.graffiti.model.OfflineModel;
import com.threerings.graffiti.model.OnlineModel;

import com.threerings.graffiti.throttle.Throttle;
import com.threerings.graffiti.throttle.ThrottleEvent;

import com.threerings.graffiti.tools.ToolBox;
import com.threerings.graffiti.tools.ToolEvent;
import com.threerings.graffiti.tools.ToggleButton;

[SWF(width="600", height="486")]
public class Graffiti extends Sprite
{
    public function Graffiti () 
    {
        _control = new FurniControl(this);
        if (!_control.isConnected()) {
            displayPreviewImage();
            return;
        }

        _throttle = new Throttle(_control);
        // each instance maintains a Manager.  The inControl() instance's Manager is in effect.
        _manager = new Manager(_throttle);
        _model = new OnlineModel(_throttle);
        _control.addEventListener(ControlEvent.MEMORY_CHANGED, memoryChanged);
        addChild(_displayCanvas = new Canvas(_model));

        _editBtn = new EDIT_BUTTON() as SimpleButton;
        _editBtn.x = Canvas.CANVAS_WIDTH - _editBtn.width / 2 - 1;
        _editBtn.addEventListener(MouseEvent.CLICK, displayEditPopup);

        _managerBtn = new MANAGER_BUTTON() as Sprite;
        _managerBtn.x = _managerBtn.width / 2 + 5;
        (_managerBtn as Object).reset_button.addEventListener(MouseEvent.CLICK, resetCanvas);
        (_managerBtn as Object).lockbutton.addEventListener(MouseEvent.CLICK, toggleLock);
        _lockBtn = new ToggleButton((_managerBtn as Object).lockbutton, null);
        _lockBtn.selected = _control.isConnected() && 
            _control.getMemory(CANVAS_LOCK, false) as Boolean;

        addEventListener(MouseEvent.MOUSE_OVER, mouseOver);
        addEventListener(MouseEvent.MOUSE_OUT, mouseOut);
        addEventListener(Event.ENTER_FRAME, enterFrame);
        _control.addEventListener(Event.UNLOAD, unload);
    }

    protected function displayPreviewImage () :void
    {
        addChild(_previewImage = new PREVIEW_IMAGE() as DisplayObject);
        _previewImage.x = (600 - _previewImage.width) / 2;
        _previewImage.y = (486 - _previewImage.height) / 2;
    }

    protected function displayEditPopup (event :MouseEvent) :void
    {
        if (_control.isConnected() && _control.getMemory(CANVAS_LOCK, false) as Boolean) {
            return;
        }

        var canvas :Canvas = new Canvas(_model);
        canvas.toolbox.addEventListener(ToolEvent.DONE_EDITING, function (event :ToolEvent) :void {
            _control.clearPopup();
        });
        canvas.toolbox.addEventListener(ToolEvent.HIDE_FURNI, function(event :ToolEvent) :void {
            hideFurni(event.value as Boolean);
        });
        canvas.toolbox.addEventListener(Event.REMOVED_FROM_STAGE, function (event :Event) :void {
            _throttle.removeEventListener(ThrottleEvent.MANAGER_MESSAGE, 
                                          canvas.toolbox.managerMessageReceived);
            hideFurni(false);
        });
        // the furni is hidden by default
        hideFurni(true);
        _control.showPopup(
            "Sketching", canvas.toolbox, ToolBox.POPUP_WIDTH, ToolBox.POPUP_HEIGHT, 0, 0);
        _throttle.addEventListener(ThrottleEvent.MANAGER_MESSAGE,
                                   canvas.toolbox.managerMessageReceived);
    }

    protected function hideFurni (hide :Boolean) :void
    {
        _displayCanvas.visible = !hide;
    }
    
    protected function memoryChanged (event :ControlEvent) :void
    {
        if (event.name == CANVAS_LOCK) {
            if (_lockBtn != null) {
                _lockBtn.selected = event.value as Boolean;
            }
            if (event.value as Boolean) {
                _control.clearPopup();
            }
        }
    }

    protected function resetCanvas (event :MouseEvent) :void
    {
        if (canEdit()) {
            _control.showPopup(
                "Clear Canvas?",
                new ClearCanvasDialog(
                    function () :void {
                        _control.setMemory(Manager.MEMORY_MODEL, null);
                        _control.clearPopup();
                    },
                    function () :void {
                        _control.clearPopup();
                    }), 
                ClearCanvasDialog.POPUP_WIDTH, 
                ClearCanvasDialog.POPUP_HEIGHT, 
                0, 
                0);
        }
    }

    protected function toggleLock (event :MouseEvent) :void
    {
        _lockBtn.selected = !_lockBtn.selected;
        if (canEdit()) {
            _control.setMemory(CANVAS_LOCK, _lockBtn.selected);
        }
    }

    protected function enterFrame (event :Event) :void
    {
        if (_mouseOver) {
            if (_control.isConnected() && (_control.getMemory(CANVAS_LOCK, false) as Boolean)) {
                animateUp(_editBtn);
            } else {
                animateDown(_editBtn);
            }

            if (canEdit()) {
                animateDown(_managerBtn);
            }
        } else {
            animateUp(_editBtn);
            animateUp(_managerBtn);
        }
    }

    protected function animateDown (button :DisplayObject) :void
    {
        if (!_displayCanvas.visible) {
            animateUp(button);
            return;
        }

        if (button.parent != this) {
            addChildAt(button, 0);
            button.y = Canvas.CANVAS_HEIGHT - button.height / 2;
        }

        button.y = Math.min(button.y + 5, Canvas.CANVAS_HEIGHT + button.height / 2 - 2);
    }

    protected function animateUp (button :DisplayObject) :void
    {
        if (button.parent != this) {
            return;
        }

        button.y -= 5;
        if (button.y < Canvas.CANVAS_HEIGHT - button.height / 2) {
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

    protected function canEdit () :Boolean
    {
       return _control.isConnected() && (_allCanEdit || _control.canEditRoom());
    }

    private static const log :Log = Log.getLog(Graffiti);

    [Embed(source="../../../../rsrc/edit_manager_buttons.swf#editbutton")]
    protected static const EDIT_BUTTON :Class;
    [Embed(source="../../../../rsrc/edit_manager_buttons.swf#manager")]
    protected static const MANAGER_BUTTON :Class;
    [Embed(source="../../../../rsrc/preview_image.png")]
    protected static const PREVIEW_IMAGE :Class;

    protected static const CANVAS_LOCK :String = "canvasLock";

    protected var _control :FurniControl;
    /** Hardcoded to true for now for a special request from the Artists.  This needs to be 
     * configured in the room editor thingy, but I don't have time to work that up at the
     * moment. */
    protected var _allCanEdit :Boolean = true;
    protected var _manager :Manager;
    protected var _model :Model;
    protected var _throttle :Throttle;
    protected var _editBtn :SimpleButton;
    protected var _managerBtn :Sprite;
    protected var _mouseOver :Boolean; 
    protected var _lockBtn :ToggleButton;
    protected var _displayCanvas :Canvas;
    protected var _previewImage :DisplayObject;
}
}
