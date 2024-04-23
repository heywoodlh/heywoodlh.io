---
title: "Using Vim (or any other editor) with Obsidian Notes"
layout: post
published: true
permalink: use-vim-with-obsidian 
tags: [ obsidian, notes, vim, linux ]
---

I recently posted [My Notes Setup using Obsidian](https://heywoodlh.io/notes-with-obsidian) -- but I have made some changes to my note-taking workflow that I'm excited about and thought I would briefly document.

I like Vim but you could really replace Vim in this article with any preferred text editor that can interact with the filesystem.

## Using Vim with Obsidian

I really like the Obsidian app on mobile but it doesn't really give me much on the desktop side of things. I still prefer `vim` over anything else. Out of the box, if I wanted to use `vim` in conjunction with Obsidian and the [Obsidian Livesync community plugin](https://github.com/vrtmrz/obsidian-livesync) I would need to keep the Obsidian app open all the time so it could monitor changes. 

A few weeks ago [I opened an issue on the obsidian-livesync repository](https://github.com/vrtmrz/obsidian-livesync/issues/57) to see if I could get some help in using the livesync functionality without needing the Obsidian desktop app to run on my machine. The author [vrtmrz](https://github.com/vrtmrz) was gracious enough to build out all the functionalityI requested in the [filesystem-livesync](https://github.com/vrtmrz/filesystem-livesync) repository.

### Running filesystem-livesync

I [created a Docker image for filesystem-livesync](https://hub.docker.com/r/heywoodlh/filesystem-livesync) and am using that to sync with the CouchDB instance that I'm using to livesync.

In this example, I will assume that you want your vault synced at `~/Documents/obsidian/Notes/vault`. Replace that path with your preferred path. Although filesystem-livesync can sync multiple vaults, I would recommend repeating this process for each vault you want to sync if you have multiple vaults.

Create `~/Documents/obsidian/Notes/config.json` with the following content:

```
{
    "vault_1": {
        "server": {
            "uri": "http://couch_db_uri/database_name",
            "auth": {
                "username": "couch_db_username",
                "password": "couch_db_password",
		"passphrase": "vault_passphrase"
            }
        },
        "local": {
            "path": "/data/vault",
            "initialScan": true
        },
        "auto_reconnect": true,
	"sync_on_connect": true 
    }
}
```

Now run the following command to run a Docker container on your machine to monitor file changes:

```
docker run --name=obsidian-notes -d --restart=always -e CHOKIDAR_USEPOLLING=1 -v ~/Documents/obsidian/Notes:/data heywoodlh/filesystem-livesync:2022_04
```

_Note: the `CHOKIDAR_USEPOLLING` variable allows filesystem-livesync to poll the filesystem. If you don't set this variable, the container will not see any changes to files unless you edit the files from within the container._

The container will then use `~/Documents/obsidian/Notes/config.json` as it's config file and it should create your vault in your filesystem at `~/Documents/obsidian/Notes/vault`. I would recommend making a shortcut or symlink to the directory so it's not as buried.

Again, if you have multiple vaults, I would recommend repeating this process for each vault and create a new config file, directory and container per vault. The `CHOKIDAR_USEPOLLING` variable makes syncing a bit slower.

And that's all you need to use an external text editor with the Obsidian Livesync plugin!
