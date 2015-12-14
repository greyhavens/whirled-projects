#!/usr/bin/python

import re, fileinput

'''
This is a simple script to pair up lines from a spades log file and report requests for the 
deck.swf movie that failed to complete. The script was created to help debug a problem with 
MultiLoader (now fixed) and may be deleted or salvaged for a similar analysis.

Input to the script can be piped via stdin or as file arguments.
'''

req = re.compile('''Requesting movie for (?P<card>\w+), id (?P<id>\d+)''')
got = re.compile('''Got movie for (?P<card>\w+), id (?P<id>\d+), parent is (?P<parent>.*)''')

requests = {}
count = 0

for line in fileinput.input():
    m = req.search(line)
    if m != None:
        count += 1
        if requests.has_key(m.group('id')):
            raise Exception("Duplicate id " + m.group('id'))
        requests[m.group('id')] = (m, fileinput.lineno())
        continue

    m = got.search(line)
    if m != None:
        if not requests.has_key(m.group('id')):
            raise Exception("Spurious id " + m.group('id'))
        del requests[m.group('id')]
        continue

failures = requests.values()
failures.sort(lambda a, b: cmp(a[1], b[1]))

print "%d card requests were made" % count
print "%d card requests failed" % len(failures)
if count > 0:
    print "%.2f%% of requests failed" % (float(len(failures)) / count * 100,)
if len(failures) > 0:
    print "Failed cards requested on lines " + ",".join(map(lambda p: str(p[1]), failures))

