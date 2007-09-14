package com.threerings.benchmark.display {

import flash.events.Event;
import flash.system.System;

import flash.utils.getTimer; // function import

import mx.container.Canvas;

import com.threerings.util.EmbeddedSwfLoader;

public class Controller
{
    public const setcount :int = 10; 
    public const iterations :int = 1000000; 

    [Embed(source="../../../../../rsrc/placeholder.png")]
    public static const TESTPNG :Class;
    [Embed(source="../../../../../rsrc/levels/Level01.swf", mimeType="application/octet-stream")]
    public static const TESTSWF :Class;

    public static const swfStaticObject :String = "tower_sandbox_rest";
    public static const swfAnimatedObject :String = "tower_sandbox_fire_up";
    public static const swfBigObject :String = "FullBG";

    public static const COUNTS :Array = [ 1, 5, 10 ];
    public static const ITERATIONS :int = 100;
    
    public var objStatic :Class; // to be filled in later
    public var objAnimated :Class;
    public var objBig :Class;

    public var container :DispBench;
    public var bg :Canvas;
        
    public var tests :Array = new Array();

    public var currentTestDef :Object = null;
    public var currentTestIndex :int = 0;
    public var currentCountIndex :int = 0;
    public var currentIteration :int = 0;
    
    public function init (c :DispBench) :void
    {
        this.container = c;
        this.bg = c.bg;

        // wait for the swf loader to initialize, and then continue init
        swfLoader.addEventListener(Event.COMPLETE, handleSwfLoaded);
        swfLoader.load(new TESTSWF());
    }

    public function handleSwfLoaded (event :Event) :void
    {
        // we have the loader - continue initialization
        swfLoader.removeEventListener(Event.COMPLETE, handleSwfLoaded);
        objStatic = swfLoader.getClass(swfStaticObject);
        objAnimated = swfLoader.getClass(swfAnimatedObject);
        objBig = swfLoader.getClass(swfBigObject);
        
        definetests();

//        calibrate();
        container.addEventListener(Event.ENTER_FRAME, handleframe);
    }

    public function shutdown () :void
    {
        container.thelabel.text = "Done.";
        container.removeEventListener(Event.ENTER_FRAME, handleframe);
        printresults();
    }

    public function handleframe (event :Event) :void
    {
        if (currentIteration > 0) {
            storeFrameDelta(delta);
            currentIteration--;
            for each (var o :DisplayObject in bg.children) {
                    currentTestDef.update(o);
                }
        } else {
            store
            resetTest();
        }
    }

    public function resetTest () :void
    {
        // advance to next 
        currentTestIndex++; // let's try the next one
        trace("TRYING TEST: " + currentTestIndex);
        
        // are we done with all tests?
        if (currentTestIndex >= tests.length) {
            trace("DONE!");
            shutdown();
            return;
        }


        
        
    
    public function t (label :String, c :Class, update :Function) :void
    {
        tests.push({ label: label, c :c, update: update, results: new Array() });
    }
        

    public function definetests () :void
    {
        t("Static no op", objStatic,
          function (d :DisplayObject) :void { /* no op */ } );

        currentTestIndex = -1;
    }

    

/*
    
    // global values used in tests
    public var ix :int = 1;
    public var iy :int = 1;
    public var ux :uint = 1;
    public var uy :uint = 1;
    public var nx :Number = 1;
    public var ny :Number = 1;
    public var a3 :Array = [ "foo", "bar", "baz" ];
    public var a100 :Array; // to be filled in later
    public var oi3 :Object = { 0: "foo", 1: "bar", 2: "baz" };
    public var os3 :Object = { foo: 0, bar: 1, baz: 2 };
    public var f0 :Function = function () :void { };
    public var f1 :Function = function (i :*) :void { };
    public var f2 :Function = function (i :*, j :*) :void { };
    public var s1 :String = "foo";
    public var s2 :String = "bar";
    public var objStatic :Class; // to be filled in later
    public var objAnimated :Class;
    public var objBig :Class;
    
    // test definitions
    public var tests :Array = new Array();
    public var currentset :int = 0;
    public var currentindex :int = -1;
    public var totalstartup :Number = 0; // in ms over all iterations
    public var test :DispBench;
    public var swfLoader :EmbeddedSwfLoader = new EmbeddedSwfLoader();
   
    public function t (label :String, thunk :Function) :void
    {
        tests.push({ label: label, thunk: thunk, results: new Array() });
    }
    
    // returns elapsed time in ms for calling the thunk function
    public function time (thunk :Function) :int
    {
        var start :int = getTimer();
        for (var i :int = 0; i < iterations; i++) {
            thunk();
        }
        var end :int = getTimer();
        return end - start;
    }
    
    public function runtest (test :Object) :void
    {
        var thunk :Function = test.thunk as Function;
        var thunkms :Number = time(thunk) - totalstartup;
        var thunkns :Number = thunkms * 1000000;
        var eachns :Number = thunkns / iterations;
        (test.results as Array).push(eachns);
    }

    public function runnexttest () :void
    {
        // pick the next test
        currentindex++;
        if (currentindex >= tests.length) {
            currentset++;
            currentindex = 0;
            calibrate();
        }
        test.thelabel.text = "Set " + currentset + ", test " + currentindex +
            "/" + tests.length + " (" + tests[currentindex].label + ")";
        runtest(tests[currentindex]);
    }

    public function handleframe (event :Event) :void
    {
        if (currentset < setcount) {
            runnexttest();
        } else {
            shutdown();
        }
    }

    public function findresults (a :Array) :Object
    {
        var sum :Number = 0;
        var sum2 :Number = 0;
        // find sum of elements and sum of their squares
        a.forEach(function (value :Number, i :*, a :*) :void {
            sum += value;
            sum2 += (value * value);
        });
        // find mean and variance
        var mean :Number = sum / a.length;
        var meansquares :Number = sum2 / a.length;
        var variance :Number = meansquares - mean * mean;
        return { m: mean, s: Math.sqrt(variance) };
    }   
        
    public function printresults () :void
    {
        var data :String = "Tests: " + setcount + " sets of " +
            iterations + " iterations each.\r\n";
        for each (var test :Object in tests) {
            var results :Object = findresults(test.results as Array);
            data += (test.label + ": avg = " +
                     Number(results.m).toFixed(1) + "ns, stdev = " +
                     Number(results.s).toFixed(1) + "ns\r\n");
        }

        trace(data);
        System.setClipboard(data);
        test.text = data;
    }
    
    public function calibrate () :void
    {
        totalstartup = time(function () :void { });
        trace("Calibrated over " + iterations + " iterations");
        trace("Timer cost: " + 
              String(Number(totalstartup) * 1000000 / iterations) +
              "ns each  (" + totalstartup + "ms total).");
    }
    
*/    
}
}
