/******************************************************************************
 * Piano Spots is an adaptation of of Brian Eno's "Bloom" app. Clicking on the 
 * screen draws a spot at the mouse location with an accompanying piano note. 
 * The spot and note echo repeatedly, decreasing slightly in opacity and volume
 * with each echo until they finally fade out.
 *
 * Player, Sound and Scale classes from a Creative Commons-licensed sketch by 
 * Gregory Bush called Spark Chimes. All code by Bush is clearly attributed.
 */

/* Constants */
int ECHO_INTERVAL_DEFAULT = 5000; // Time (in ms) to wait between echoes spots

int SCALE_PENTATONIC_MAJOR = 0;
int SCALE_PENTATONIC_MINOR = 1;
int SCALE_PENTATONIC_PYTHAGOREAN = 2;
int SCALE_BLUES_MAJOR = 3;
int SCALE_BLUES_MINOR = 4;
int SCALE_EGYPTION_SUSPENDED = 5;
int SCALE_DIATONIC = 6;
int SCALE_CHROMATIC = 7;

int TONE_SMOOTH = 0;
int TONE_WISTFUL = 1;

int MODE_MANUAL = 0;
int MODE_AUTO = 1;

/* Globals for this sketch */
SoundBank soundBank; // Sound generation
ArrayList spotQueue = new ArrayList(); // All spots queued up at a given time
int scale = SCALE_BLUES_MINOR;
int echoInterval = ECHO_INTERVAL_DEFAULT;
int tone = TONE_WISTFUL;
int mode = MODE_MANUAL;

// setup() -- handle setup.
void setup() {
  size(window.innerWidth, window.innerHeight);
  smooth();

  soundBank = new ScaledSampleSoundBank( 
    new Maxim(this), 
    generateTone(tone), // Sample file: C3 piano note from http://www.freesound.org/people/Meg/sounds/83122/
    generateScale(scale), // Scale for generating tones
    -16, // Number of intervals below the root tone
    16, // Number of intervals above the root tone
    30, // Max number of tones (lower this if performance is a problem) 
    1.0, // Amplification
    15 // Sample file length
  );

  if (mode == MODE_AUTO) {
    generateSpots();
  }
}

void generateSpots() {
  int delay = int(random(0, echoInterval * 2));
  int x = int(random(0, window.innerWidth));
  int y = int(random(0, window.innerHeight));
  queueSpot(new Spot(x, y, soundBank.getMappedSound(x)));
  setTimeout(generateSpots, delay);
}

// draw() -- handle drawing
void draw() {
  background(0);

  // Spots on the canvas.
  noStroke();
  for (int i = spotQueue.size() - 1; i >= 0; i--) {
    Spot spot = (Spot) spotQueue.get(i);
    spot.draw();
    if (spot.isBurnedOut())
    {
      // Remove burned out spots from the queue.
      spotQueue.remove(i);
    }

    spot = null;
  }
}

// mousePressed() -- handle mousePressed event
void mousePressed() {
  // Queue up a new spot with the maximum number of lives remaining at the mouse/finger location
  queueSpot(new Spot( mouseX, mouseY, soundBank.getMappedSound(mouseX)));
}

// queueSpot() -- add a spot and queue up echo on a timed loop.
void queueSpot(Spot spot) {
  // Add this spot to the spots in play -- unless it's burned out!
  if (!spot.isBurnedOut()) {
    spotQueue.add(spot);
    spot.playSound();
    setTimeout(queueSpot, echoInterval, spot.echo());
  }
}

void killAllSpots() {
  for (int i = spotQueue.size() - 1; i >= 0; i--) {
    spotQueue.remove(i);
  }
}

Scale generateScale(int s) {
  Scale scale = null;
  switch(s) {
    case SCALE_BLUES_MAJOR:
      scale = ScaleFactory.createBluesMajor();
      break;
    case SCALE_BLUES_MINOR:
      scale = ScaleFactory.createBluesMinor();
      break;
    case SCALE_DIATONIC:
      scale = ScaleFactory.createDiatonic();
      break;
    case SCALE_EGYPTION_SUSPENDED:
      scale = ScaleFactory.createEgyptianSuspended();
      break;
    case SCALE_PENTATONIC_MAJOR:
      scale = ScaleFactory.createEgyptianSuspended();
      break;
    case SCALE_PENTATONIC_MINOR:
      scale = ScaleFactory.createEgyptianSuspended();
      break;
    case SCALE_PENTATONIC_PYTHAGOREAN:
      scale = ScaleFactory.createEgyptianSuspended();
      break;
    default:
      scale = ScaleFactory.createBluesMinor();
  }

  return scale;
}

String generateTone(int t) {
  String tone = null;
  switch(t) {
    case TONE_WISTFUL:
      tone = "c3.wav"; // Sample file: C3 piano note from http://www.freesound.org/people/Meg/sounds/83122/
      break;
    case TONE_SMOOTH:
      tone = "g.wav";
      break;
    default:
      tone = "c3.wav";
  }

  return tone;
}
