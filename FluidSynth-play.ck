NRev rev => dac;
0.01 => rev.mix;

"soundfonts/Salamander_C5-v3-MR-HEDSounds.sf2" => string sfont;
//"soundfonts/Yamaha-C5-Salamander-JNv5.1.sf2" => string sfont;
//"soundfonts/Salamander-UltraCompact-JNv3.0.sf2" => string sfont;
if(me.args() > 0) me.arg(0) => sfont;

FluidSynth m => rev;
m => dac;
0.91 => m.gain;
m.open(sfont);

spork~layer();
spork~layer();
spork~layer();
minute => now;

fun void layer ()
{
  while(true)
  {
    48 + (Math.random2(0,24) * 3 / 2) => int midinote;
    //<<< midinote>>>;
    m.noteOn(midinote,80,0);
    125::ms => now;
    if (maybe) 125::ms => now;
    m.noteOff(midinote,0);
  }
}
