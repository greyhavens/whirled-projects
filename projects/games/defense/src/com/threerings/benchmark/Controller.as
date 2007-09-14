package com.threerings.benchmark {

import flash.events.Event;
import flash.system.System;

import flash.utils.getTimer; // function import

public class Controller
{
    public const setcount :int = 4; 
    public const iterations :int = 10000; 

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
    
    // test definitions
    public var tests :Array = new Array();
    public var currentset :int = 0;
    public var currentindex :int = -1;
    public var totalstartup :Number = 0; // in ms over all iterations
    public var test :Bench;
    
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
            data += (test.label + ": " +
                     Number(results.m).toFixed(1) + "ns      s = " +
                     Number(results.s).toFixed(1) + "\r\n");
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
    
    public function init (test :Bench) :void
    {
        this.test = test;

        this.a100 = new Array(100);
        for (var i :int = 0; i < 100; i++) {
            this.a100[i] = 0;
        }
        
        definetests();
        calibrate();
        test.addEventListener(Event.ENTER_FRAME, handleframe);
    }

    public function shutdown () :void
    {
        test.thelabel.text = "Done.";
        test.removeEventListener(Event.ENTER_FRAME, handleframe);
        printresults();
    }    
    
    public function definetests () :void
    {
        t("No op",
          function () :void { });
        t("Scalar variable declaration",
          function () :void { var r :int; });
        t("Scalar variable assignment from constant",
          function () :void { var r :int = 1; });
        t("Scalar variable assignment from variable",
          function () :void { var r :int = ix; });
        t("Untyped variable declaration",
          function () :void { var r :*; });
        t("Untyped variable assignment from constant",
          function () :void { var r :* = 1; });
        t("Untyped variable assignment from variable",
          function () :void { var r :* = ix; });
        
        t("Signed integer addition",
          function () :void { var r :int = ix + iy; });
        t("Signed integer multiplication",
          function () :void { var r :int = ix * iy; });
        t("Signed integer division",
          function () :void { var r :int = ix / iy; });

        t("Unsigned integer addition",
          function () :void { var r :uint = ux + uy; });
        t("Unsigned integer multiplication",
          function () :void { var r :uint = ux * uy; });
        t("Unsigned integer division",
          function () :void { var r :uint = ux / uy; });
    
        t("Double addition",
          function () :void { var r :Number = nx + ny; });
        t("Double multiplication",
          function () :void { var r :Number = nx * ny; });
        t("Double division",
          function () :void { var r :Number = nx / ny; });

        t("Integer -> Number conversion",
          function () :void { var r :Number = ix; });
        t("Number -> integer conversion",
          function () :void { var r :int = nx; });
        
        t("Anonymous function declaration",
          function () :void { var r: Function = function () :void { }; });
        t("Function call (no arguments)",
          function () :void { f0(); });
        t("Function call (unary)",
          function () :void { f1(f0); });
        t("Function call (binary)",
          function () :void { f2(f0, f1); });
        
        t("Math.sqrt",
          function () :void { var r: Number = Math.sqrt(nx); });
        t("Math.sin",
          function () :void { var r: Number = Math.sin(nx); });
        t("Math.round",
          function () :void { var r: Number = Math.round(nx); });
        t("Math.floor",
          function () :void { var r: Number = Math.floor(nx); });

        t("String assignment from literal",
          function () :void { var s :String = "foo"; });
        t("String assignment from variable",
          function () :void { var s :String = s1; });
        t("String concatenation from literals",
          function () :void { var s :String = "foo" + "bar"; });
        t("String concatenation from variables",
          function () :void { var s :String = s1 + s2; });
          
        t("Array creation: a = new Array()",
          function () :void { var a :Array = new Array(); });
        t("Array creation via literal",
          function () :void { var a :Array = [ ]; });
        t("Reading from array to variable",
          function () :void { ix = a3[1]; });
        t("Writing from variable to array",
          function () :void { a3[1] = ix; });

        t("Object creation via new",
          function () :void { var o :Object = new Object(); });
        t("Object creation via literal",
          function () :void { var o :Object = { }; });
        t("Reading from object with integer keys",
          function () :void { var r :* = oi3[1]; });
        t("Reading from object with string keys",
          function () :void { var r :* = os3["bar"]; });

        t("Unrolled array access",
          function () :void {
            var r :Number = 0;
            r += a100[0];
            r += a100[1];
            r += a100[2];
            r += a100[3];
            r += a100[4];
            r += a100[5];
            r += a100[6];
            r += a100[7];
            r += a100[8];
            r += a100[9];
            r += a100[10];
            r += a100[11];
            r += a100[12];
            r += a100[13];
            r += a100[14];
            r += a100[15];
            r += a100[16];
            r += a100[17];
            r += a100[18];
            r += a100[19];
            r += a100[20];
            r += a100[21];
            r += a100[22];
            r += a100[23];
            r += a100[24];
            r += a100[25];
            r += a100[26];
            r += a100[27];
            r += a100[28];
            r += a100[29];
            r += a100[30];
            r += a100[31];
            r += a100[32];
            r += a100[33];
            r += a100[34];
            r += a100[35];
            r += a100[36];
            r += a100[37];
            r += a100[38];
            r += a100[39];
            r += a100[40];
            r += a100[41];
            r += a100[42];
            r += a100[43];
            r += a100[44];
            r += a100[45];
            r += a100[46];
            r += a100[47];
            r += a100[48];
            r += a100[49];
            r += a100[50];
            r += a100[51];
            r += a100[52];
            r += a100[53];
            r += a100[54];
            r += a100[55];
            r += a100[56];
            r += a100[57];
            r += a100[58];
            r += a100[59];
            r += a100[60];
            r += a100[61];
            r += a100[62];
            r += a100[63];
            r += a100[64];
            r += a100[65];
            r += a100[66];
            r += a100[67];
            r += a100[68];
            r += a100[69];
            r += a100[70];
            r += a100[71];
            r += a100[72];
            r += a100[73];
            r += a100[74];
            r += a100[75];
            r += a100[76];
            r += a100[77];
            r += a100[78];
            r += a100[79];
            r += a100[80];
            r += a100[81];
            r += a100[82];
            r += a100[83];
            r += a100[84];
            r += a100[85];
            r += a100[86];
            r += a100[87];
            r += a100[88];
            r += a100[89];
            r += a100[90];
            r += a100[91];
            r += a100[92];
            r += a100[93];
            r += a100[94];
            r += a100[95];
            r += a100[96];
            r += a100[97];
            r += a100[98];
            r += a100[99];
        });
        
        t("Array iteration using an int-indexed for loop",
          function () :void {
            var r :Number = 0;
            for (var i :int = 0; i < 100; i++) {
                r += a100[i];
            }
        });
        t("Array iteration using forEach and an anonymous function",
          function () :void {
            var r :Number = 0;
            var fn :Function = function (elt :Number, i :*, a :*) :void {
                r += elt;
            };
            a100.forEach(fn);
        });
        t("Array iteration using 'for each' special syntax",
          function () :void {
            var r :Number = 0;
            for each (var elt :Number in a100) {
                r += elt;
            }
        });

    }
}
}
