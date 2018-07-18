# Mother's Work is Never Done

_Mother's Work is Never Done_ is an electronic object consisting of a standard Medela breastpump that can be used to pump breastmilk but also to make music using the rhythm that the breastpump generates while pumping. This sound is passed through sets of filters. 

## Hardware Documentation


## Software Documentation

The project consists of a ruby script that runs in Sonic Pi, a Live Coding Synth. The second main component is a  startup script that starts JACK, the audio routing toolkit as well as Sonic Pi. Installing the project requires that you have [sonic-pi-cli](https://github.com/Widdershin/sonic-pi-cli) installed on your Raspberry Pi. Sonic Pi, Audio Jack, and QJackCtl should already be installed. 

### The Startup Script
The startup script is a shell script that runs on startup. To run a script on startup on stretch you need to modify the following document like this:

```markdown
sudo nano .config/lxsession/LXDE-pi/autostart
```



Markdown is a lightweight and easy-to-use syntax for styling your writing. It includes conventions for

```markdown
Syntax highlighted code block

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
