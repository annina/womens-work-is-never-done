# Mother's Work is Never Done

_Mother's Work is Never Done_ is an electronic object consisting of a standard Medela breastpump that can be used to pump breastmilk but also to make music using the rhythm that the breastpump generates while pumping. This sound is passed through sets of filters. 

## Hardware Documentation


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
This is the last step where sonic-pi-cli loads  ruby script in midi_script.txt. Although Sonic-Pi can be controlled via Python (my preferred programming language), I did not find the libraries intuitive to use for my purposes, so I am using Ruby here. 

```markdown
cat ~/Desktop/RaspberryPiVersion/midi_script.txt | sonic_pi
```
Markdown is a lightweight and easy-to-use syntax for styling your writing. It includes conventions for

```markdown
Syntax highlighted code block
```
# Header 1
## Header 2
### Header 3

- Bulleted
- List

1. Numbered
2. List

**Bold** and _Italic_ and `Code` text

[Link](url) and ![Image](src)
```

For more details see [GitHub Flavored Markdown](https://guides.github.com/features/mastering-markdown/).

### Jekyll Themes

Your Pages site will use the layout and styles from the Jekyll theme you have selected in your [repository settings](https://github.com/annina/mothers-work-is-never-done/settings). The name of this theme is saved in the Jekyll `_config.yml` configuration file.

### Support or Contact

Having trouble with Pages? Check out our [documentation](https://help.github.com/categories/github-pages-basics/) or [contact support](https://github.com/contact) and we’ll help you sort it out.
