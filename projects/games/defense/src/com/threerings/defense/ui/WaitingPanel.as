package com.threerings.defense.ui {

import flash.events.MouseEvent;

import mx.containers.TitleWindow;
import mx.controls.Button;
import mx.controls.Text;

import com.threerings.defense.Board;
import com.threerings.defense.Controller;
import com.threerings.defense.tuning.Messages;


public class WaitingPanel extends TitleWindow
{
    public function WaitingPanel (controller :Controller)
    {
        _controller = controller;
        
        this.showCloseButton = false;
        this.x = 10;
        this.y = 350;
    }
        
    override protected function createChildren () :void
    {
        super.createChildren();

        var title :Text = new Text();
        title.width = 200;
        title.text = Messages.get("wait_desc");
        addChild(title);

        var button :Button = new Button();
        button.width = 200;
        button.label = Messages.get("wait_cancel");
        button.addEventListener(MouseEvent.CLICK, function (event :MouseEvent) :void {
                _controller.forceQuitGame();
            });
        addChild(button);
    }

    protected var _controller :Controller;
}
}

    

    
