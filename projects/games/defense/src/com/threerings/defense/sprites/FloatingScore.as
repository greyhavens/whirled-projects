package com.threerings.defense.sprites {

import mx.controls.Label;
import mx.effects.Blur;
import mx.effects.Move;
import mx.effects.easing.Quadratic;
import mx.events.EffectEvent;

public class FloatingScore extends Label
{
    public function FloatingScore (
        value :String, x :Number, y :Number, styleName :String = "floatingScore")
    {
        this.text = value;
        this.x = x;
        this.y = y;
        this.styleName = styleName;
    }

    override protected function createChildren () :void
    {
        super.createChildren();
        
        _move = new Move(this);
        _move.yFrom = y;
        _move.yBy = -100;
        _move.easingFunction = Quadratic.easeIn;
        _move.duration = 2000;
        _move.addEventListener(EffectEvent.EFFECT_END, handleEffectEnd);

        _blur = new Blur(this);
        _blur.blurXFrom = 0;
        _blur.blurXTo = 0;
        _blur.blurYFrom = 0;
        _blur.blurYTo = 20;
        _blur.easingFunction = Quadratic.easeIn;
        _blur.startDelay = 1000;
        _blur.duration = 1000;        
    }

    override protected function childrenCreated () :void
    {
        super.childrenCreated();

        _move.play();
        _blur.play();
    }

    protected function handleEffectEnd (event :EffectEvent) :void
    {
        // get rid of the effects, remove self from display list

        _move.removeEventListener(EffectEvent.EFFECT_END, handleEffectEnd);
        _move.end();
        _move = null;

        _blur.end();
        _blur = null;

        this.parent.removeChild(this);        
    }

    protected var _move :Move;
    protected var _blur :Blur;
}
}
