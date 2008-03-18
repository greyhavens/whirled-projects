import os

def removeChars(inString, chars):
	out = "";
	for char in inString:
		if chars.find(char) < 0:
			out += char
	
	return out
	
baseDir = "items"

files = os.listdir(baseDir)

for filename in files:
	fullname = os.path.join(baseDir, filename)
	if os.path.isfile(fullname):
		root, ext = os.path.splitext(filename)
		
		if ext == ".png":
			prefix = "IMG_";
		elif ext == ".swf":
			prefix = "SWF_";
		else:
			continue;
			
		print '[Embed(source="../../rsrc/items/' + filename + '", mimeType="application/octet-stream")]'
		print "public static const " + prefix + removeChars(root, "_").upper() + " :Class;\n"


