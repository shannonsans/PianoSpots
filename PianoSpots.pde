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
int ECHO_INTERVAL_DEFAULT = 5000; // Time (in ms) to wait between echoes

int MODE_MANUAL = 0;
int MODE_AUTO = 1;

/* Globals for this sketch */
SoundBank soundBank; // Sound generation
ArrayList spotQueue = new ArrayList(); // All spots queued up at a given time
ArrayList timeouts = new ArrayList(); // All timeouts (to make it easy to clear them on reset)
int echoInterval = ECHO_INTERVAL_DEFAULT;
int mode = MODE_MANUAL;

// setup() -- handle setup.
void setup() {
  size(window.innerWidth, window.innerHeight);
  smooth();

  soundBank = new ScaledSampleSoundBank( 
    new Maxim(this), 
    "c3.wav", // Sample file: C3 piano note from http://www.freesound.org/people/Meg/sounds/83122/
    ScaleFactory.createBluesMinor(), // Scale for generating tones
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
  timeouts.add(setTimeout(generateSpots, delay));
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
    timeouts.add(setTimeout(queueSpot, echoInterval, spot.echo()));
  }
}

// killAllSpots() -- clear all active and pending spots
void killAllSpots() {
  // Clear spots in the active queue
  for (int i = spotQueue.size() - 1; i >= 0; i--) {
    spotQueue.remove(i);
  }

  // Clear any timeouts waiting in the wings
  for (int i = timeouts.size() - 1; i >= 0; i--) {
    clearTimeout(timeouts.get(i));
    timeouts.remove(i);
  }
}

