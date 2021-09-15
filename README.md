# ShellPhish
Ferramenta de phishing para propósitos educacinais ;)

<!-- shellphish --> 
<pre id="taag_output_text" class="fig" contenteditable="true">   _____ _          _ _       _     _     _     
  / ____| |        | | |     | |   (_)   | |    
 | (___ | |__   ___| | |_ __ | |__  _ ___| |__  
  \___ \| '_ \ / _ \ | | '_ \| '_ \| / __| '_ \ 
  ____) | | | |  __/ | | |_) | | | | \__ \ | | |
 |_____/|_| |_|\___|_|_| .__/|_| |_|_|___/_| |_|
                       | |                      
                       |_|          </pre>
                                                                  
</p> <p align="center">A beginners friendly, Automated phishing tool with 30+ templates.</p>

##

### Features

- Latest and updated login pages.
- Mask URL support
- Beginners friendly
- Docker support (checkout `docker-legacy` branch)
- Multiple tunneling options
- Localhost
- Ngrok (With or without hotspot)

### Installation

- Just, Clone this repository -
```
$ git clone https://github.com/faccboy/shellphish.git
```
- Change to cloned directory and run `shellphish.sh` -
``` $ cd shellphish
$ bash shellphish.sh ```
- On first launch, It'll install the dependencies and that's it. `shellphish` is installed. 
### Run on Docker
```
$ docker pull faccboy/shellphish
$ docker run --rm -it faccboy/shellphish ```
### Dependencies
**`shellphish`** requires following programs to run properly -
- `php` - `wget`
- `curl`
- `git`
> All the dependencies will be installed automatically when you run `shellphish` for the first time.

> Supported Platform : **`Termux`**, **`Ubuntu/Debian/Kali`**, **`Arch Linux/Manjaro`**, **`Fedora`**
