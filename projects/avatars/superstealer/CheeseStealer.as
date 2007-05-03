

// Allows attaching any kind of ridiculous wrap-through route-through functions to whirled controls


// much TODO
public class CheeseStealer
{
    public function CheeseStealer (disp :DisplayObject)
    {
        disp.loader.sharedEvents.addEventListener("ControlConnect", handleCheeseInterception);
    }

    public function registerReplacement (propName :String, upGoing :Boolean, replacer :Function) :void
    {
        if (upGoing) {
            _up[propName] = replacer;
        } else {
            _down[propName] = replacer;
        }
    }

    protected function handleCheeseInterception (cheese :Object) :void
    {
    }

    protected var _up :Object = {};
    protected var _down :Object = {};
}
