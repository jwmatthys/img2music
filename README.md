# img2music
Convert color image to music

## OSC Messages

* incoming OSC messages (on port 53186)
* fff : hue sat br, 0-1

### /chains/all fff: master
1. mode (scale)
2. pitch range (narrow to wide)
3. tempo (slow to fast)

### /chains/band/0 - melody line
1. pitch range (narrow to wide)
2. rhythmic complexity (syncopation)
3. density (subdivision)

### /chains/band/1 - harmony
1. density
2. chord width (M2 - P15)
3. texture (shimmer, arpeggios, block chords)

### /chains/band/2 - bassline
1. rhythmic complexity (syncopation)
2. density (subdivision)
3. repetition (low = high repetition)

### /chains/band/3 - percussion
1. syncopation?
2. timbral variety (static for low sat)
3. density (sparse for dark)
