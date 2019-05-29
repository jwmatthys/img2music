NRev rev => dac;
0.01 => rev.mix;

"soundfonts/1115-Afric Percussion.sf2" => string sfont;
//"soundfonts/Yamaha-C5-Salamander-JNv5.1.sf2" => string sfont;
//"soundfonts/Salamander-UltraCompact-JNv3.0.sf2" => string sfont;
if(me.args() > 0) me.arg(0) => sfont;

FluidSynth m => rev;
m => dac;
0.91 => m.gain;
m.open(sfont);

layer();

fun void layer ()
{
  30 => int note;
  while(true)
  {
    <<< "note:",note >>>;
    m.noteOn(note,80,0);
    500::ms => now;
    m.noteOff(note++,0);
  }
}
