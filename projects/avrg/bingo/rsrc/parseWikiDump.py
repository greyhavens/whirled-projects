import os
import re

def removeChars(inString, chars):
	out = "";
	for char in inString:
		if chars.find(char) < 0:
			out += char
	
	return out
	
def createItemString(itemName, tags, imageName):
	itemString = '\t\tnew BingoItem("' + itemName + '", [';
	
	for tag in tags.split(','):
		itemString += '"' + tag.strip() + '", ';
		
	itemString += '], Resources.IMG_' + removeChars(imageName, " _").upper() + "),\n"
	
	return itemString

itemsRequiringTint = []

re_line = re.compile(r'^.*\[\[Image:(.*?)\.png\]\].*?\|\|(.*?)\|\|(.*?)\|\|(.*?)\|\|.*$')
re_itemName = re.compile(r'(")')

f = open("wikidump.txt", 'r')

# generate the ITEMS = [...] string

bingoString = "\tpublic static const ITEMS :Array = [\n\n"

for line in f:
	m = re_line.match(line)
	if m:
		#print m.group(1, 2, 3)
		
		imageName = m.group(1)
		itemName = m.group(2)
		tags = m.group(3)
		tintString = m.group(4).strip()
		
		if tintString[0] == "y":
			itemsRequiringTint.append([itemName, tags, imageName])
			continue
		
		# " -> '
		itemName = re_itemName.sub("'", itemName)
		
		bingoString += createItemString(itemName, tags, imageName)
		
bingoString += "\n\t];"
		
print bingoString

# note items that require recoloring

print "** The following items all require recoloring:"

for recolorItem in itemsRequiringTint:
	itemName = recolorItem[0]
	tags = recolorItem[1]
	imageName = recolorItem[2]
	
	print createItemString(itemName, tags, imageName)
		
		
		
		