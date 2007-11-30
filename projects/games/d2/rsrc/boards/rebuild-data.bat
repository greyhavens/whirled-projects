del *.data
for %%p in (default ep1) do zip -0 -j %%p.data %%p\*.swf %%p\*.xml
