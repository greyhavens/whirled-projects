#!/bin/bash

for PACK in default ep1; do 
  echo "Packing $PACK..."
  rm $PACK.data
  zip -0 -j $PACK.data $PACK/*.swf $PACK/*.xml
done
