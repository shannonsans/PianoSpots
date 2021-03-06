/******************************************************************************
 * Sound generation code from:
 * 
 * "SparkChimeJSNoSound" by Gregory Bush, licensed under Creative Commons 
 * Attribution-Share Alike 3.0 and GNU GPL license.
 *
 * Work: http://openprocessing.org/sketch/100985  
 *
 * License: 
 * http://creativecommons.org/licenses/by-sa/3.0/
 * http://creativecommons.org/licenses/GPL/2.0/
 */

/******************************************************************************
 * A Player is a simplified interface that will play a sound at a particular
 * speed and volume if possible.
 *
 * @author Gregory Bush
 */
public interface Player {
  /**
   * Play a sound at a particular speed and volume.  If it is not possible to
   * play the sound now, false will be returned.
   */
  public boolean play(float speed, float volume);
}
 
/******************************************************************************
 * A SamplePlayer is a Player that will play a single sample from an
 * AudioPlayer.  If the sample is already playing, the play method will return
 * false.
 *
 * @author Gregory Bush
 */
public class SamplePlayer implements Player {
  /*
   * The AudioPlayer that contains the loaded sample.
   */
  private final AudioPlayer player;
 
  /*
   * The time stamp when the sample last started playing.
   */
  private long startTime;
 
  /*
   * The length of this sample in milliseconds.
   */
  private float sampleLength;
 
  public SamplePlayer(AudioPlayer player, float sampleLength) {
    this.sampleLength = sampleLength;
    this.player = player;
    player.setLooping(false);
  }
   
  public SamplePlayer(AudioPlayer player) {
    this(player, player.getLengthMs());
  }
 
  public boolean play(float speed, float volume) {
    /*
     * Check if the sample has finished playing.
     */
    long now = millis();
    boolean donePlaying = now - startTime > sampleLength;
 
    if (donePlaying) {
      /*
       * If so, record the current time as the time the sample last started
       * playing.
       */
      startTime = now;
 
      /*
       * Then stop the player if it thinks it is still playing, rewind the
       * sample to the beginning, set the speed and volume and start playing
       * the sample.
       */
      player.stop();
      player.cue(0);
      player.speed(speed);
      player.volume(volume);
      player.play();
    }
 
    /*
     * Let the caller know if we were able to play the sample or not.
     */
    return donePlaying;
  }
}
 
/******************************************************************************
 * A PolyphonicPlayer is an aggregate Player that can play as many sounds at
 * once as the number of delegate Players that have been added to it.
 *
 * @author Gregory Bush
 */
public static class PolyphonicPlayer implements Player {
  /*
   * A list of delegate players that may be free to play a sound.
   */
  private final ArrayList voices = new ArrayList();
 
  /*
   * The index of the next player that we will attempt to play a sound on.
   */
  private int nextVoice = 0;
 
  /**
   * Add a delegate Player to the PolyphonicPlayer.  One or more players must be
   * added before the PolyphonicPlayer can play any sounds.
   */
  public void addPlayer(Player p) {
    voices.add(p);
  }
 
  public boolean play(float speed, float volume) {
    /*
     * Attempt to play the sound on the next Player in line.  If successful,
     * move the Player after that to the head of the line.
     */
    boolean played;
 
    int voiceCount = voices.size();
 
    if (voiceCount > nextVoice) {
      played = ((Player) voices.get(nextVoice)).play(speed, volume);
      if (played) {
        nextVoice = (nextVoice + 1) % voiceCount;
      }
    }
    else {
      played = false;
    }
    return played;
  }
}
 
/******************************************************************************
 * An AmplifiedPlayer is a Player that wraps a delegate Player and increases
 * (or decreases) the volume of all the sounds it plays by a specified scale
 * factor.
 *
 * @author Gregory Bush
 */
public class AmplifiedPlayer implements Player {
  /*
   * The delegate player that will actually play the sound.
   */
  private final Player delegate;
 
  /*
   * The scale factor we want to change the volume by.
   */
  private final float volumeMultiplier;
 
  public AmplifiedPlayer(Player delegate, float volumeMultiplier) {
    this.delegate = delegate;
    this.volumeMultiplier = volumeMultiplier;
  }
 
  public boolean play(float speed, float volume) {
    return delegate.play(speed, volume * volumeMultiplier);
  }
}

/*******************************************************************************
 * A Sound is a very simple abstraction of a sound that can be played at
 * a specified volume.  The baseline volume is 1.0.
 *
 * @author Gregory Bush
 */
public interface Sound {
  public void play(float volume);
}
 
/*******************************************************************************
 * A PlayerSound is a type of Sound that is played by a delegate player at a
 * predefined speed and specified volume.
 *
 * @author Gregory Bush
 */
public class PlayerSound implements Sound {
  private final Player player;
 
  private final float speed;
 
  public PlayerSound(Player player, float speed) {
    this.player = player;
    this.speed = speed;
  }
 
  public void play(float volume) {
    player.play(speed, volume);
  }
}
 
/*******************************************************************************
 * A Scale can produce a list of frequency multipliers necessary to produce the
 * notes in a specified range.
 *
 * Note 0 is the root of the scale and integer offsets below and above 0 are
 * lower and higher notes in the scale, respectively.
 *
 * For example, in a C major scale, there are 12 notes in an octave, where
 * 0 is middle C, 4 is 12 is high C.
 *
 * @author Gregory Bush
 */
public interface Scale {
  /**
   * Get the frequency multipliers needed to produce the note offsets in the
   * range from low (inclusive) to high (exclusive).
   */
  public float[] getFrequencyFactors(int low, int high);
}
 
/*******************************************************************************
 * A RationalScale is divided into octaves where the same pattern of frequency
 * ratios is repeated relative to the overall octave multiplier.
 *
 * @author Gregory Bush
 */
public static class RationalScale implements Scale {
  private final ArrayList factors = new ArrayList();
 
  public RationalScale() {
  }
 
  /*
   * Create a cyclic scale from an array of ratios.
   */
  public RationalScale(float[] ratios) {
    if (ratios.length > 0) {
      float rootRatio = ratios[0];
      for (float ratio : ratios) {
        addFrequencyFactor(ratio / rootRatio);
      }
    }
  }
 
  public void addFrequencyFactor(float factor) {
    factors.add(factor);
  }
 
  private float getFrequencyFactor(int noteOffset) {
    int cycleLength = factors.size();
 
    int cyclePosition = noteOffset % cycleLength;
 
    if (cyclePosition < 0) {
      cyclePosition += cycleLength;
    }
 
    /*
     * The frequency multiplier is 2^(octave offset) * (specified frequency)
     */
    return pow(2.0, int(noteOffset / cycleLength)) * (Float) factors.get(cyclePosition);
  }
 
  public float[] getFrequencyFactors(int low, int high) {
    /* 
     * Rewriting this section because it's doing something weird when 
     * returning notes, such that it sometimes returns a note that was lower than 
     * the note before it.
     */
//    int rangeLength = high - low;
// 
//    float[] result = new float[rangeLength];
// 
//    for (int i = 0; i < rangeLength; i++) {
//      result[i] = getFrequencyFactor(low + i);
//    }
// 
//    return result;
    
    int rangeLength = high - low;
    
    ArrayList results = new ArrayList();
    float lastResult = 0;
    for (int i = 0; i < rangeLength; i++)
    {
      float r = getFrequencyFactor(low + i);
      if (r > lastResult)
      {
        results.add(r);
        lastResult = r;
      }
    }
    
    float[] result = new float[results.size()];
    for (int i = 0; i < result.length; i++)
    {
       result[i] = (float) results.get(i);
    }
    
    return result;
  }
}
 
/*******************************************************************************
 * An EqualTemperamentScale divides octaves into uniform logarithmic intervals.
 *
 * Modern Western music uses scales based on subsets of 12 tone equal
 * temperament.
 *
 * @author Gregory Bush
 */
public static class EqualTemperamentScale implements Scale {
  private final int cycleLength;
 
  public EqualTemperamentScale(int cycleLength) {
    this.cycleLength = cycleLength;
  }
 
  private float getFrequencyFactor(int noteOffset) {
    /*
     * The frequency multiplier is 2^(noteOffset / cycleLength).
     */
    return pow(2.0, (float) noteOffset / cycleLength);
  }
 
  public float[] getFrequencyFactors(int low, int high) {
    int rangeLength = high - low;
 
    float[] result = new float[rangeLength];
 
    for (int i = 0; i < rangeLength; i++) {
      result[i] = getFrequencyFactor(low + i);
    }
 
    //return result;
    
    ArrayList newResults = new ArrayList();
    float lastResult = 0;
    for (int i = 0; i < result.length; i++)
    {
      if (result[i] > lastResult)
      {
        newResults.add(result[i]);
        lastResult = result[i];
      }
    }
    
    float result2 = new float[newResults.size];
    for (int i = 0; i < result2.length; i++)
    {
       result2[i] = (float) newResults.get(i);
       println(result2[i]);
    }
    
    return result2;
  }
}
 
/*******************************************************************************
 * Some interesting scales.  The pentatonic scales (the ones with 5 ratios
 * defined) are particularly nice for randomly generated music, since many
 * notes can be combined with little dissonance.
 *
 * @author Gregory Bush
 */
public static class ScaleFactory {
  public static Scale createPentatonicMinor() {
    return new RationalScale(new float[] {
      30, 36, 40, 45, 54
    });
  }
 
  public static Scale createPentatonicMajor() {
    return new RationalScale(new float[] {
      24, 27, 30, 36, 40
    });
  }
 
  public static Scale createEgyptianSuspended() {
    return new RationalScale(new float[] {
      24, 27, 32, 36, 40
    });
  }
 
  public static Scale createBluesMinor() {
    return new RationalScale(new float[] {
      15, 18, 20, 24, 27
    });
  }
 
  public static Scale createBluesMajor() {
    return new RationalScale(new float[] {
      24, 27, 32, 36, 40
    });
  }
 
  public static Scale createPentatonicPythagorean() {
    return new RationalScale(new float[] {
      54, 64, 72, 81, 96
    });
  }
 
  /*
   * The diatonic scale is not pentatonic.  (It has seven notes per cycle
   * instead of five.)  It creates a more dissonant effect.
   */
  public static Scale createDiatonic() {
    return new RationalScale(new float[] {
      24, 27, 30, 32, 36, 40, 45
    });
  }
 
  /*
   * The chromatic scale has a highly dissonant effect with 12 notes per
   * cycle.
   */
  public static Scale createChromatic() {
    return new EqualTemperamentScale(12);
  }
}
 
/*******************************************************************************
 * You can randomly select a Sound from a SoundBank.
 *
 * @author Gregory Bush
 */
public interface SoundBank {
  public Sound getRandomSound();
}
 
/*******************************************************************************
 * A ScaledSampleSoundBank contains a basic sound loaded from a file and
 * different tunings of the same sound according to a specified scale and note
 * range.
 *
 * @author Gregory Bush
 */
public class ScaledSampleSoundBank implements SoundBank {
  private Sound[] sounds;
 
  public ScaledSampleSoundBank(Maxim maxim, String sampleFile, Scale scale, int lowNote,
  int highNote, int polyphony, float amplification, float customSampleLength) {
    PolyphonicPlayer pp = new PolyphonicPlayer();
    for (int i = 0; i < polyphony; i++) {
      Player p;
      if (customSampleLength > 0.0) {
        p = new SamplePlayer(maxim.loadFile(sampleFile), customSampleLength);
      }
      else {
        p = new SamplePlayer(maxim.loadFile(sampleFile));
      }
      if (amplification != 1.0) {
        p = new AmplifiedPlayer(p, amplification);
      }
      pp.addPlayer(p);
    }
 
    float[] frequencyFactors = scale.getFrequencyFactors(lowNote, highNote);
 
    int soundCount = frequencyFactors.length;
 
    sounds = new Sound[soundCount];
 
    for (int i = 0; i < soundCount; i++) {
      sounds[i] = new PlayerSound(pp, frequencyFactors[i]);
    }
  }
 
  public Sound getRandomSound() {
    return sounds[int(random(0, sounds.length))];
  }  
  
  /*
   * getMappedSound() - return a tone based on where the mouse was clicked on 
   * the X-axis, mapping this to the scales stored by the SoundBank so that
   * notes go from low to high up the scale as you click from left to right.
   * 
   * @author Shannon Hale
   */
  public Sound getMappedSound(float x) {
    return sounds[int(map( x, 0, width, 0, sounds.length - 1 ))];
  }
}
 
/******************************************************************************
 * END SOUND PLAYER CODE
 */
  
