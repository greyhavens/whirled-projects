import os
import re

def removeChars(inString, chars):
	out = "";
	for char in inString:
		if chars.find(char) < 0:
			out += char
	
	return out

filename = "wikidump.txt"

re_line = re.compile(r'^.*\[\[Image:(.*?)\.png\]\].*?\|\|(.*?)\|\|(.*?)\|\|.*$')
re_itemName = re.compile(r'(")')

f = open(filename, 'r')

bingoString = "\tpublic static const ITEMS :Array = [\n\n"

for line in f:
	m = re_line.match(line)
	if m:
		#print m.group(1, 2, 3)
		
		imageName = m.group(1)
		itemName = m.group(2)
		tags = m.group(3)
		
		# " -> '
		itemName = re_itemName.sub("'", itemName)
		
		bingoString += '\t\tnew BingoItem("' + itemName + '", [';
		
		for tag in tags.split(','):
			bingoString += '"' + tag.strip() + '", ';
			
		bingoString += '], Resources.IMG_' + removeChars(imageName, " _").upper() + "),\n"
		
bingoString += "\n\n\t];"
		
print bingoString
		
		
		
		