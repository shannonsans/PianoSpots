/******************************************************************************
 * Piano Spots is an adaptation of of Brian Eno's "Bloom" app. Clicking on the 
 * screen draws a spot at the mouse location with an accompanying piano note. 
 * The spot and note echo repeatedly, decreasing slightly in opacity and volume
 * with each echo until they finally fade out.
 *
 * Because I'm not mathematically capable of generating the scales I wanted for this
 * sketch, I'm using the Player, Sound and Scale classes from a Creative Commons-
 * licensed sketch by Gregory Bush called Spark Chimes. Any code by Bush is
 * clearly attributed.
 */

/* Constants */
int DEFAULT_ECHO_INTERVAL = 5000; // Time (in ms) to wait between echoes spots

/* Globals for this sketch */
SoundBank soundBank; // Sound generation
ArrayList spotQueue = new ArrayList(); // All spots queued up at a given time

// setup() -- handle setup.
void setup() 
{
  size( 1024, 768 );
  smooth();
  
  soundBank = new ScaledSampleSoundBank( 
                      new Maxim( this ), 
                      "c3.wav", // Sample file: C3 piano note from http://www.freesound.org/people/Meg/sounds/83122/
                      ScaleFactory.createBluesMinor(), // Scale for generating tones
                      -14, // Number of intervals below the root tone
                      12, // Number of intervals above the root tone
                      24, // Max number of tones (lower this if performance is a problem) 
                      1.0, // Amplification
                      15 // Sample file length
                      );
}

// draw() -- handle drawing.
void draw() 
{
  background( 0 );
  
  // Spots on the canvas.
  noStroke();
  for ( int i = spotQueue.size() - 1; i >= 0; i-- )
  {
    Spot spot = (Spot) spotQueue.get( i );
    spot.draw();
    if ( spot.isBurnedOut() )
    {
      // Remove burned out spots from the queue.
      spotQueue.remove( i );
    }
    
    spot = null;
  }
}

// mousePressed() -- handle mousePressed event
void mousePressed()
{
  // Queue up a new spot with the maximum number of lives remaining at the mouse/finger location
  queueSpot( new Spot( mouseX, mouseY, soundBank.getMappedSound() ) );
}

// queueSpot() -- recursive function to add a spot and queue up echo on a timed loop.
void queueSpot( Spot spot )
{
  // Add this spot to the spots in play -- unless it's burned out!
  if ( !spot.isBurnedOut() )
  {
    spotQueue.add( spot );
    spot.playSound();
    setTimeout( queueSpot, DEFAULT_ECHO_INTERVAL, spot.echo() );
  }
}

void killAllSpots()
{
  for ( int i = spotQueue.size() - 1; i >= 0; i-- )
  {
    spotQueue.remove( i );
  }
}
