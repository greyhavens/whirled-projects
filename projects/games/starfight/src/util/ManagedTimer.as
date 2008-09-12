package util {

public interface ManagedTimer
{
    function get currentCount () :int;
    function get delay () :Number;
    function set delay (val :Number) :void;
    function get repeatCount () :int;
    //function set repeatCount (val :int) :void // Thane doesn't support this right now
    function get running () :Boolean;

    function reset () :void;
    function start () :void;
    function stop () :void;

    /**
     *  Removes the ManagedTimer from its TimerManager.
     *  It is an error to call any function on a timer that has been canceled.
     */
    function cancel () :void;
}

}
