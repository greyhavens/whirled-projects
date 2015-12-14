#!/usr/bin/python

import re, fileinput, sys

'''
This is a simple script to parse a log file from spades. It was written to debug a problem 
with MultiLoader where card sprites (among other things) were not being loaded. The problem 
is now fixed.

It works by collecting relevant log lines into an array, then pattern matching for sequences
of lines that constitute a card that was played to complete a trick.

This script may deleted or salvaged if a new analysis is needed for something similar.

Input to the script can be piped via stdin or as file arguments.
'''

time = '''\d{4}/\d{2}/\d{2} (?P<hour>\d{2}):(?P<minute>\d{2}):(?P<second>\d{2}):(?P<millis>\d{3})'''

def logLine(pat):
    return re.compile(time + pat);

added = logLine('''.*CardArrayEvent received .*cardarray.added.*card=(?P<card>\w+)''')
req = logLine('''.*Requesting movie for (?P<card>\w+)(, id \d+)?''')
played = logLine('''.*Received \[TrickEvent.*trick.cardPlayed.*card=(?P<card>\w+)''')
complete = logLine('''.*Received \[TrickEvent.*trick.complete.*card=(?P<card>\w+)''')
got = logLine('''.*Got movie for (?P<card>\w+)(, id \d+)?, parent is (?P<parent>.*)''')
reset = logLine('''.*CardArrayEvent received .*cardarray.reset''')


class LineType:
    def __init__(self, exp, char):
        self.exp = exp
        self.char = char

lineTypes = [
    LineType(added, 'a'),
    LineType(req, 'r'),
    LineType(played, 'p'),
    LineType(complete, 'c'),
    LineType(got, 'g'),
    LineType(reset, 's')]

class Line:
    def __init__(self, type, match, line, lineno):
        self.type = type
        self.match = match
        self.line = line
        self.lineno = lineno
    def time(self):
        hr, min, sec, millis = map(lambda name: 
            int(self.match.group(name)), 
            ['hour', 'minute', 'second', 'millis'])
        return (((hr * 60 + min) * 60 + sec) * 1000) + millis

class Log:
    def __init__(self):
        self.lines = []

    def process(self, line):
        for type in lineTypes:
            match = type.exp.search(line)
            if match != None:
                self.lines.append(Line(type, match, line, fileinput.lineno()))
                break

log = Log()
for line in fileinput.input():
    log.process(line)


class Trick:
    def __init__(self, lines, match, index):
        self.lines = range(match.start(), match.end())
        self.lines = map(lambda i: lines[i], self.lines)
        self.index = index

    def isBad(self):
        return len(self.lines) < 6

    def totalTime(self):
        return self.lines[-1].time() - self.lines[0].time()

    def findLine(self, char):
        for l in self.lines:
            if l.type.char == char:
                return l
        return None

    def resetTime(self):
        return self.findLine('s').time() - self.findLine('c').time()

    def dump(self):
        for line in self.lines:
           sys.stdout.write("%d : %d : %s" % (line.lineno, line.time(), line.line))

signature = ''.join(map(lambda l: l.type.char, log.lines))
trickExp = re.compile('arpc(sg|gs|s)')

tricks = []
badTricks = []

pos = 0
while True:
    match = trickExp.search(signature, pos)
    if match == None: break
    tricks.append(Trick(log.lines, match, len(tricks)))
    if tricks[-1].isBad():
       badTricks.append(tricks[-1])
    pos = match.end()

short = 200
long = 325

print "Sig: %s" % signature[0:100]
print "%d tricks" % len(tricks)
print "%d bad tricks" % len(badTricks)
if len(tricks) > 0:
    print "%.2f%% tricks are bad" % (float(len(badTricks))/len(tricks) * 100,)
print "%d lines" % len(log.lines)
if len(tricks) > 0:
    print "Average time: %f" % (float(reduce(lambda x, y: x + y.totalTime(), tricks, 0)) / len(tricks))
if len(badTricks) > 0:
    print "Average bad trick time: %f" % (float(reduce(lambda x, y: x + y.totalTime(), badTricks, 0)) / len(badTricks))
if len(tricks) > 0:
    print "Average reset time: %f" % (float(reduce(lambda x, y: x + y.resetTime(), tricks, 0)) / len(tricks))
if len(badTricks) > 0:
    print "Average bad trick reset time: %f" % (float(reduce(lambda x, y: x + y.resetTime(), badTricks, 0)) / len(badTricks))

#print "%d short tricks" % len(filter(lambda t: t.totalTime() < short, tricks))
print "%d long tricks" % len(filter(lambda t: t.resetTime() > 280, tricks))
print
print

if False:
    completions = map(lambda t: str(t.findLine('c').lineno), tricks)
    print "Completion line numbers: %s" % ",".join(completions)

print "Bad tricks start on lines " + ",".join(map(lambda t: str(t.findLine('a').lineno), badTricks))

print
print

if len(badTricks) > 0:
    badTricks[0].dump()
