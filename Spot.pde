/***********************************************************
 * A Spot is a colourful circle with a limited lifecycle.
 * As it expands in size it fades away until it burns out.
 * It can also create an echo of itself, which starts out
 * a little faded from its previous incarnation.
 *
 * @author Shannon Hale
 */
 
/*
 * These control the size of the spot and speed of expansion.
 */
float MIN_DIAMETER = 25; // Minimum diameter
float MAX_DIAMETER = 600; // Maximum diameter
float EXPAND_SPEED = 1.25; // How fast diameter increases
  
/*
 * Color ranges to use when generating spots.
 */
int MIN_RED = 51; // Minimum value for red channel (0 - 255)
int MAX_RED = 153; // Maximum value for red channel (0 - 255)
int MIN_GREEN = 102; // Minimum value for green channel (0 - 255)
int MAX_GREEN = 204; // Maximum value for green channel (0 - 255)
int MIN_BLUE = 153; // Minimum value for blue channel (0 - 255)
int MAX_BLUE = 255; // Maximum value for blue channel (0 - 255)

/*
 * Control how opaque the initial incarnation of the spot is,
 * and how much the alpha and sound fades with each echo.
 */ 
float MAX_ALPHA = 100;  // Max alpha channel value (0 - 255)
float ECHO_ALPHA_REDUCTION = 2.5; // Amount to reduce alpha for echoes
float ECHO_VOLUME_REDUCTION = 0.0275; // Amount to reduce volume for echoes.

public class Spot 
{
  // Spot properties
  private float x, y, w, h; // Position and canvas size
  private float diameter; // Size
  private float red, green, blue, alpha; // Fill values
  private float initialAlpha; // Starting alpha value
  private boolean burnedOut = false; // Whether spot has faded away
  private Sound sound; // Sound associated with this spot
  private float volume = 1.0; // Volume to play sound

  // Constructor
  public Spot( float x, float y, Sound sound ) 
  {
    this.x = x;
    this.y = y;
    this.sound = sound;
    w = width;
    h = height;

    // Set the initial size.
    diameter = MIN_DIAMETER;

    // Fill: red maps to x-axis, blue to y-axis, and green is distance from centre.
    // Variation in red, blue and green channels can be refined using min/max constants.
    red = map( x, 0, w, MIN_RED, MAX_RED );
    blue = map( y, 0, h, MIN_BLUE, MAX_BLUE );
    green = map( dist( w / 2, h / 2, x, y ), 0, sqrt( sq( w / 2 ) + sq( h / 2 ) ), MIN_GREEN, MAX_GREEN );
    alpha = initialAlpha = MAX_ALPHA;
        
    noStroke();
    ellipseMode( CENTER );
  }
  
  // echo() -- makes a copy of the spot at its original location, 
  // but reduces the alpha and volume a bit.
  public Spot echo()
  {
    Spot spot = new Spot( x, y, sound );
    
    // Location, canvas and color properties are identical for echo and parent.
    spot.w = w;
    spot.h = h;
    spot.red = red;
    spot.blue = blue;
    spot.green = green;
    
    // Alpha and volume are reduced by a small amount from the parent.
    // Because alpha decays as the spot expands, use the initial alpha
    // for the parent as the starting point - not its current alpha.
    spot.alpha = spot.initialAlpha = initialAlpha - ECHO_ALPHA_REDUCTION;
    spot.volume = volume - ECHO_VOLUME_REDUCTION;
    
    // Technically it's not burned out until alpha == 0, but by the time
    // the initial alpha is about 20 it's barely visible.
    if ( spot.alpha <= 20 || spot.volume <= 0 )
    {
      spot.burnedOut = true;
    }
    
    return spot;
  }

  // play() -- handles drawing the spot.
  public void draw()
  {
    if ( !isBurnedOut() ) 
    {
      fill( red, green, blue, alpha );
      ellipse( x, y, diameter, diameter );

      expand();
    }
  }

  public boolean isBurnedOut()
  {
    return burnedOut;
  }

  public void playSound()
  {
    sound.play( volume );
  }
  
  // expand() -- increases diameter and fades the alpha channel.
  private void expand() 
  {
    // Alpha fade is calculated so it reaches 0 at the same time the diameter reaches its max.
    alpha -= ( EXPAND_SPEED * initialAlpha ) / ( MAX_DIAMETER - MIN_DIAMETER ); 
    diameter += EXPAND_SPEED;
    if ( diameter >= MAX_DIAMETER || alpha <= 0 ) 
    {
      burnedOut = true;
    }
  }
  
}

/******************************************************************************
 * END SPOT CODE
 */

