## Piano Spots

Piano Spots is a [Processing.js](http://processingjs.org) sketch influenced by Brian Eno's Bloom app. Clicking/tapping on the screen draws a spot with an accompanying piano note. The spot and note echo repeatedly, decreasing slightly in opacity and volume with each echo until they finally fade out.

See a working demo at http://shannonsansserif.com/PianoSpots. (It requires a browser that supports WebAudioAPI properly -- see http://caniuse.com/audio-api for a list.) Click anywhere to begin. The notes are mapped to where you click, with octaves increasing from left to write in a minor Blues scale. The colors are also determined by where you click: red maps to the x-axis, blue to the y-axis, and green to the distance from the center of the screen.

## Attribution

Because I'm not mathematically capable of generating the scales I wanted for this sketch, I used the Player, Sound and Scale classes from a Creative Commons-licensed sketch by Gregory Bush called [Spark Chimes](www.openprocessing.org/sketch/100985). All code by Bush is in the file [SoundBank.pde](./SoundBank.pde).

Piano Spots also uses a fork of [Mick Grierson's Maxim](https://github.com/micknoise/Maxim) cross-platform JavaScript digital signal processing library. [My fork](https://github.com/shannonsans/Maxim/) fixes some issues rising from  changes in the webkitAudioContext code (see [Porting webkitAudioContext code to standards based AudioContext](https://developer.mozilla.org/en-US/docs/Web/API/Web_Audio_API/Porting_webkitAudioContext_code_to_standards_based_AudioContext)).

The base piano note sample is the [Manthey-C3.WAV by Meg from FreeSound.org](http://www.freesound.org/people/Meg/sounds/83122/).

## Motivation

I started writing this as an assignment for the [Creative Programming for Digital Media & Mobile Apps course on Coursera](https://www.coursera.org/course/digitalmedia) in 2013, which I didn't finish but I recommend if you're interested in playing around with Processing.js to write interactive creative apps.

## Installation

If you're interested in playing around with the code, you can do the following:

1. Go to http://processing.org/download and installing the appropriate version for your machine.
2. Run the Processing IDE.
3. Install the JavaScript mode. (On Mac OS X, click the Java mode button in the upper-right of the Processing window; click Add Mode...; then choose the JavaScript mode.) You may need to reboot to switch to this mode.
4. Clone the PianoSpots repository to your machine.
5. Open the PianoSpots.pde file in your Processing IDE.
6. Press the "Play" button to start the web server and run the sketch. (You'll get a warning message in the IDE about the applet size, because it's dynamically determined by the browser window at runtime. Just click OK.)

For more information, see the [Processing.js Quick Start](http://processingjs.org/articles/p5QuickStart.html) guide.

## License

The PianoSpots code (except for the maxim.js file) is distributed under the [Creative Commons Attribution-ShareAlike](http://creativecommons.org/licenses/by-sa/3.0/) license.

The maxim.js file is distributed under the MIT license.