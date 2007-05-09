//
// $Id$

package com.threerings.betthefarm {

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.SimpleButton;
import flash.display.Sprite;

import flash.geom.Matrix;
import flash.geom.ColorTransform;

import flash.text.TextField;

public class ImageTextButton extends Button
{
    public function ImageTextButton (
        txt :String, imgClass :Class, fontSize :int, foreground :uint, padding :Array)
    {
        var button :Sprite;

        button = makeButton(txt, imgClass, fontSize, foreground, padding);
        this.upState = button;

        button = makeButton(txt, imgClass, fontSize, foreground, padding);
        // the over state is a brightened version of the button
        button.transform.colorTransform = new ColorTransform(1.2, 1.2, 1.2);
        this.overState = button;

        button = makeButton(txt, imgClass, fontSize, foreground, padding);
        // the down state moves the button down 3 pixels on the screen
        button.transform.matrix = new Matrix(1, 0, 0, 1, 0, 3);
        this.downState = button;

        this.hitTestState = this.upState;
    }

    protected function makeButton (
        txt :String, imgClass :Class, fontSize :int, foreground :uint, padding :Array) :Sprite
    {
        var sprite :Sprite = new Sprite();
        var img :DisplayObject = new imgClass();
        sprite.addChild(img);
        var label :TextField = makeButtonLabel(
            txt, img.width - (padding[PAD_TOP] + padding[PAD_BOTTOM]),
            img.height - (padding[PAD_LEFT] + padding[PAD_RIGHT]), true, fontSize, foreground);
        label.x = padding[PAD_LEFT];
        label.y = padding[PAD_TOP];
        sprite.addChild(label);
        return sprite;
    }
}
}
