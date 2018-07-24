# Women's Work is Never Done

_Women's Work is Never Done_ is an interactive sound object consisting of a standard Medela breastpump and audio hardware. The pump can be used to pump breastmilk. It can also be used to make electronic music using the rhythmic sounds that the breastpump generates. There are three sets of sounds that can be layered while playing the instrument: Two streams of audio from the pump and a third (optional) stream consisting of samples of politicians talking about women, gender, and family. The title comes from the couplet  “Men work from sun to sun but women’s work is never done”.  It describes how women tend to work longer hours than men because of the disproportionate amount of invisible labor women still do. The breastpump is symbolic of this invisible labor. Pumping breastmilk is done by many women (and a few transgender men, cyborgs, nonbinary people, etc.) during work breaks or while doing other work. The pumping typically happens in private since it is not seen as an appropriate activity for public spaces. Like most invisible work, pumping takes a lot of time but is not a type of work that is remunerated. _Women's Work is Never Done_  brings the breastpump out into the public. In this project, the breastpump is not treated as sonic curiosity but rather as a symbol for how products for women could be envisioned and designed differently and work done with these products valued more. 

![Image](http://www.anninaruest.com/img/cover_small.jpg)

## Video Documentation
<a href="https://vimeo.com/281295400" target="_blank"><img src="http://www.anninaruest.com/img/video.jpg" 
width="900" /></a>

## Hardware Documentation
![Image](http://www.anninaruest.com/img/bag_documentation.jpg)
![Image](http://www.anninaruest.com/img/hardware_diagram.jpg)

## Software Documentation

The project consists of a ruby script that runs in Sonic Pi, a Live Coding Synth. The second main component is a  startup script that starts JACK, the audio routing toolkit as well as Sonic Pi. Installing the project requires that you have [sonic-pi-cli](https://github.com/Widdershin/sonic-pi-cli) installed on your Raspberry Pi. Sonic Pi, Audio Jack, and QJackCtl should already be installed. 

### The Startup Script
The startup script is a shell script that runs on startup. The script takes care of routing sound from the microphone to Sonic Pi and starts the project on Sonic Pi so it can be run without a monitor. Sound routing is necessary because Raspberry Pi does not by default have a sound input. So Raspbian does not expect one to be present and will not automatically route sound input to Sonic Pi. For the purpose of the project, being able to record the sound of a breastpump via a microphone and modify it in real time is necessary. Therefore, the code below is necessary. But first things first: To run a script on startup on Raspbian stretch you need to modify the following document like this:

```markdown
sudo nano .config/lxsession/LXDE-pi/autostart
```
Add the following line (if your startup_script.sh is located on the Desktop - else modify to reflect its location):
```markdown
@Desktop/startup_script.sh
```
Upon reboot, the script should run after the LXSession starts and the Desktop is displayed.

The startup script (startup_script.sh) starts jackd and directs all output to /dev/null and disconnects the process with &

```markdown
jackd -d alsa -dhw:0,0 1>/dev/null 2>/dev/null &
```
The startup script then calls qjackctl, a graphical interface to jack. I use it to debug. It allows me to check whether jackd is working correctly. It has a 

```markdown
qjackctl 1>/dev/null 2>/dev/null &
```
this starts Sonic Pi (the graphical interface and everything). I never figured out how to use the server without the graphical interface, so this is how I am doing it. Later in the script when the audio routing is set up, I'll use sonic-pi-cli to control it.

```markdown
sonic-pi 1>/dev/null 2>/dev/null &
```
The following line writes the connection between system_capture_1 and SuperCollider (the software that Sonic Pi runs on) into a variable. Actually, it executes a jack_connect command and then routes the error message from stderr to stdout. This is necessary because stderr would not be captured in a variable. Why are we doing all of this? Raspberry Pi does not have a microphone on board, so the OS does not automatically route sound recorded by the microphone on the usb soundcard to Sonic Pi (as is the case on other OSs like Mac OS). 
It takes a (looong) while for Sonic Pi to start. So the script probes repeatedly whether SuperCollider has started and whether SuperCollider:in_1 is available. Else, no sound will reach Sonic Pi. 

```markdown
STR=$(jack_connect system:capture_1 SuperCollider:in_1 2>&1)
```
Here is the loop that checks on the availability of SuperCollider:in_1. The error messages start with either "Cannot" or "Error". If one of those messages is detected, the loop sleeps for two seconds, then tries again. Once the jack_connect is successfully executed, the script goes to the next step. 

```markdown
STR=$(jack_connect system:capture_1 SuperCollider:in_1 2>&1)
echo $STR
sleep 1
newstring=$(echo $STR | cut -c1-5)
echo $newstring
while [ "$newstring" = "Canno" ] || [ "$newstring" = "ERROR" ]; do
sleep 2
echo "another try"
STR=$(jack_connect system:capture_1 SuperCollider:in_1 2>&1)
newstring=$(echo $STR | cut -c1-5)
done
```
This is the last step where sonic-pi-cli loads the ruby script contained in the text file midi_script.txt. Although Sonic-Pi can be controlled via Python (my preferred programming language), I did not find any libraries that do what I wanted. It therefore was simplest to write it directly in the language that Sonic Pi seems to be most comfortable with.
```markdown
cat ~/Desktop/RaspberryPiVersion/midi_script.txt | sonic_pi
```
### The Ruby Script
The Ruby script runs the effects that are applied to the live audio stream to create the sound. I am using an AKAI MPKmini midi controller. It comes with rotary controllers as well as piano keys and a red knob intended for pitch bending.  If you are using a different midi controller with Sonic Pi, plug it in, turn a knob or hit a key, and you will see the path to it in the cues window within Sonic Pi.

The rotary controllers make numbers from 0-127. This can be accessed as follows. Variable x is the number of the controller and z is the position that it has been rotated to. 

A rotary controller
```markdown
  x, z = sync "/midi/mpkmini2_midi_1/1/1/control_change"
```
A key press has both note_on and note_off. The note variable holds the number of the key and the velocity holds a number from 0 to 127 that holds the intensity of the key press.
```markdown
  note, velocity= sync "/midi/mpkmini2_midi_1/1/1/note_on"  
  note_off, velocity_off= sync "/midi/mpkmini2_midi_1/1/1/note_off"
```
Input from pitch bend looks like this: 
```markdown
 w = sync "/midi/mpkmini2_midi_1/1/1pitch_bend"
```
Every key, pad, and rotary controller has their own effect or set of effects. Below is an example of what this looks like. The process goes like this: First, look for control_change or note_on signal from midi controller. Then apply the effect. Effects are documented under FX in the Sonic Pi help.

```markdown
live_loop :eight do
  use_real_time #
  x, z = sync "/midi/mpkmini2_midi_1/1/1/control_change"
  puts x,z                  # prints values to the Log window
  if x == 8 then            # if it is the 8th rotary controller. 
    if z > 5 then           # only apply the effect when z > 5.
      with_fx :whammy, transpose: z do  # this is the section where the effect is applied. 
        live_audio :aoo                 # the name of the live_audio stream.
      end
    else
      live_audio :aoo                   #this will play the breastpump sound without effect.
    end
  end
  sleep 1                               #sleep is necessary (in more than one sense). Here, the amount depends on the effect you're using.
end
```
What I have learned about live_audio streams in the context of this project is that if you give every live_audio stream a unique name, they will all overlap and the result will not be interesting. Playing everything at once eradicates differences and interaction with the keyboard. So I have two live_audio streams that are connected to the keys and rotary controllers respectively. Keys cannot play together and sound controlled by rotary controllers cannot be layered on top of each other. But sound made by pressing keys can be layered on top of sound produced when rotary keys are turned.

## License

MIT License

Copyright (c) 2018 Annina Rüst

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

