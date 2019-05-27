# img2music
Convert color image to music

## OSC Messages

* incoming OSC messages (on port 53186)
* /torch
* ifff : track (0-4), hue sat br, 0-1
* if i=-1, trigger fadeout and reset playback
* if not playing, any received data starts playback

### master (track 0)
1. mode (scale)
2. pitch range (narrow to wide)
3. tempo (slow to fast)

### melody line (track 1)
1. rhythmic complexity (syncopation)
2. disjunctness
3. density (subdivision)

### harmony (track 2)
1. chord width (7 - 24 semi)
2. texture (shimmer, arpeggios, block chords)
3. density (numPitches)

### percussion (track 3)
1. syncopation
2. timbral variety (static for low sat)
3. density (sparse for dark)

### bassline (track 4)
1. pitch range (octave)
2. rhythmic complexity (syncopation)
3. density (subdivision)
