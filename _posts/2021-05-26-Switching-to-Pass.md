---
title: 'Switching (Back) to Pass as My Password Manager'
layout: post
permalink: switching-to-pass
tags: all, linux, macos, bash, automation, password-manager, pass, bitwarden, 1password
---

This is a post that is a bit more opinionated that my general how-to stuff. Feel free to disagree with my ideas or opinions, I don't care.

## Why do I want to switch password managers?

### Bitwarden:
I have been using [Bitwarden](https://bitwarden.com) as my daily-driver password manager for the past 4-ish years. I think it's a great application and I don't have many complaints with it. It's open source, is extremely polished and has made sharing passwords with my friends and family a breeze. Plus, Bitwarden gives you the option to officially self-host or go with a totally compatible, unofficial rewrite like [vaultwarden](https://github.com/dani-garcia/vaultwarden). I've self hosted the official version and also used vaultwarden (back when it was called bitwarden_rs) and it was nice to be in control of where my data was. 


### 1Password:
I also use [1Password](https://1password.com) for work. 1Password is closed source and I will be honest that really annoys me (I'm definitely being petty but I can't shake it). On top of that there is no free version -- just a paid trial. Especially when compared to Bitwarden's free version that is very unattractive for a user like me. With Bitwarden I get a password manager that is open source and has a free tier that has most of the functionality. However, 1Password is a very reliable product and is deserving of the reputation it has gained as one of the best password managers out there. Just for a user like me, it's not the best fit. Also, I will readily admit I'm definitely living a double-standard by complaining about 1Password not being open source but choosing to rely so much on Github [despite the server-side codebase not being open source](https://stackoverflow.com/questions/24254324/is-github-com-source-code-open-source).

### The one function I need:

There is one function that 1Password has that I absolutely love that Bitwarden hasn't implemented yet. The ability to call a mini instance of 1Password with a keyboard shortcut that overlays whatever application I have open is incredibly useful as I can easily call upon 1Password while I am in any application. I have grown especially reliant on using a keyboard shortcut when I have my terminal emulator open and am SSH-ed into a server and need to elevate privileges using a password I have stored in my password manager. 

On Linux, I have used [bitwarden-rofi](https://github.com/mattydebie/bitwarden-rofi) and it works pretty close to perfect. On MacOS, [I forked bitwarden-rofi](https://github.com/heywoodlh/choose-password-scripts) and tried to replicate most of the same functionality. But for some reason my fork on MacOS is way slower and I haven't had the willpower to figure it out and have grown increasingly resentful that Bitwarden hasn't implemented something comparable to 1Password's keyboard shortcut. [There is an open feature request that is two years old that adds this functionality](https://github.com/bitwarden/desktop/pull/231) -- yet Bitwarden still has not implemented it.

## Why I am using pass:

[Pass](https://www.passwordstore.org) is by far the simplest password manager I've ever used. It's a command line application with an incredibly easy to use syntax. The author of `pass` is Jason A. Donenfeld, the author of [Wireguard](https://www.wireguard.com/) -- the simplest and fastest VPN solution I've used. I like Jason's tools a lot.

As an added bonus, `pass` uses `gpg` to manage the encryption and decryption of each entry and [I'm a big fan of GPG](https://heywoodlh.io/gpg-cheatsheet/).

Before switching to Bitwarden I used `pass` as my daily-driver password manager for about a year and never really had any complaints. I stopped using `pass` in favor of Bitwarden simply because at the time there was no iOS app and I switched to an iPhone away from Android. A few months ago I noticed that there is now a [very polished community-made iOS app for `pass`](https://github.com/mssun/passforios) and have been itching to switch back.

And with `pass` being a command line application first (not an afterthought like [Bitwarden's CLI](https://github.com/bitwarden/cli) or [1Password's far clunkier CLI](https://1password.com/downloads/command-line/)) it is as extensible as I want it to be with additional wrappers. I liked Bitwarden initially because of the priority for the CLI but I'm not a huge fan of using the slow Node JS-based CLI just for a simple feature that should be baked into the desktop application.

Pass strikes the perfect balance for me at being simple, extensible and now available for me on mobile.

## Setting up pass:

### GPG key:

You will need to setup a GPG key to use with pass. You can generate a new one with the following command:

```bash
gpg --full-generate-key
```

After `pass` is installed on your machine, you can use the following command to initialize your password-store with the newly created GPG key:

```bash
pass init email@domain.com
```

If you want to use the same password-store on other systems you will have to export your newly created GPG key to your other systems.
Export the GPG private and public key with the following commands:

```bash
gpg --output ~/Downloads/public_key.gpg --armor --export email@domain.com

gpg --output ~/Downloads/private_key.pgp --armor --export-secret-key email@domain.com
```

On another machine that you need to import the key you can import the keys:

```bash
gpg --import public_key.gpg

gpg --import private_key.gpg
```

You will want to be careful with the private key as a malicious actor could decrypt your password store if they had the passphrase (you had better set a strong passphrase on your private key, idiot). 

[Check out my GPG cheatsheet for more commands to manage your GPG key](https://heywoodlh.io/gpg-cheatsheet/).

### Basic password management:

Here are some example commands that should be pretty self explanatory in regard to what they do, but I'll document each one with comments (and you could totally have a different organization to your password store than my own):

```bash
## Create a new entry for example.com for heywoodlh user (re-run this command to overwrite the entry):
pass insert example.com/heywoodlh

## Print the password to the terminal:
pass example.com/heywoodlh

## Retrieve the password and pipe it to the clipboard on MacOS:
pass example.com/heywoodlh | pbcopy

## Retrieve the password and pipe it to the clipboard on Linux:
pass example.com/heywoodlh | xclip -selection clipboard

## To create or edit a multi-line entry (I like using the `edit` subcommand for notes):
pass edit example.com/multiline

## Delete an entry:
pass rm example.com/heywoodlh

## Rename an entry:
pass mv example.com/multiline example.org/multi-line

## Search for an entry:
pass search example.org

## Search the contents of your entires for a string:
pass grep string

## Check out the man page, there are some great examples:
man pass
```

### Syncing between devices: 

I use a remote `git` repository on my own server to sync my password-store repository between devices.
Setup the remote repository over SSH with the following command:

```bash
ssh user@remote-host "git init --bare /path/to/password-store"
```

Assuming the remote repository has been setup and is accessible via SSH, you can use the following commands to configure the remote repository for your password-store:

```bash
## Set up the local git repo to connect to the remote repo
pass git init
pass git remote add origin ssh://user@remote-host:/path/to/password-store

## Push your changes to the remote repository
pass git push -u --all

## Pull changes that were made to the repository to your device
pass git pull 
```

### Using TOTP codes with pass:

A [nice pass extension exists for creating and fetching totp entries](https://github.com/tadfisher/pass-otp). You can [refer to the Installation section in the Readme instructions per package manager](https://github.com/tadfisher/pass-otp#installation) or install it from source:

```bash
git clone https://github.com/tadfisher/pass-otp
cd pass-otp
sudo make install
```

Then to enable the extension you need to set some variables in your shell. I do it with BASH by placing the following in my `~/.bash_profile`:

```bash
export PASSWORD_STORE_ENABLE_EXTENSIONS=true
if [[ -d /usr/local/lib/password-store/extensions ]]
then
        export PASSWORD_STORE_EXTENSIONS_DIR=/usr/local/lib/password-store/extensions/
fi
```

Once the extension is available you can use the otp plugin just like the original command to manage TOTP entries using the `otp` subcommand:

```bash
## Create a new TOTP entry
pass otp insert example.org/totp
```

What's kind of annoying about this is that you have to use a crazy `otpauth` URI: to set it up. I would recommend that you use the `-e` flag so that way you can see the output when you add the URI, like so (replacing the `X`'s with the TOTP key):

```bash
pass otp insert -e example.org/totp
Enter otpauth:// URI for example.org/totp: otp_uri="otpauth://totp/example.org?secret=XXXXXXXXXXXX&issuer=totp-secret"
```

[I use a BASH function to make this easy for me](https://gist.github.com/heywoodlh/819d97b9010f7c744c9aa8f19df51445).

You can use the following command to get more usage instructions on how to use `pass otp`:

```bash
pass otp --help
```
