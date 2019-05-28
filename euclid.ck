Impulse imp => dac;
75 => float bpm;
8 => int steps;
3 => int ones;
0 => int n;
euclidean P1; // create a new object called "P1"
0 => P1.offset;
P1.set( steps, ones );
fun dur BPM( float tempo ){
return (60.0/tempo)*1000::ms;
}
while( true ){
if( n==steps ){
// change the pattern at the end of the loop
Math.random2(1, 16) => steps;
Math.random2(1, Math.max(steps-1, 1)$ int) => ones;
P1.set( steps, ones );
0 => n;
// read the pattern (array) and send the MIDI msg
if( P1.play(n) != 0 ){
imp.next(1);
}
<<< "STEPS:", steps, "ONES:", ones >>>;
}
else{
// read the pattern (array) and send the MIDI msg before the end of the loop
if( P1.play(n) != 0 ){
imp.next(1);
}
}
<<< "EUCL:",P1.play(n), "--------", "STEPS NR:", steps,"--------", "COUNTER:", n >>>;
n++;

(BPM(bpm)/steps) => now;
}

//------------------------CLASS-------------------------

private class euclidean{
float steps;
float ones;
0 => int offset;
int pattern[32];
fun void set( float steps, float ones ){
// set steps and ones and fill the array
steps => this.steps;
ones => this.ones;

// create the Euclidean Rhythm
if( this.steps < this.ones ){
<<< "ATTENTION: (ones > steps)" >>>;
this.steps => this.ones;
}
[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ] @=> pattern;

for(0 => int c; c<=this.ones; c++){
Math.round( c*(this.steps/this.ones) ) $ int => int onesIndex;
1 => this.pattern[ ( ( onesIndex ) % this.steps ) $ int ];
}
// arrayPrint();
}

fun void arrayPrint(){
// print the Euclidean Pattern
<<< "------------------------NEW PATTERN-----------------------" >>>;
for( 0 => int c; c < this.steps; c++ ){
<<< c+":", this.pattern[c] >>>;
}
}

fun int play( int c ){
// read the pattern
return pattern[ ( ( c+this.offset )% this.steps ) $ int];
}
}
