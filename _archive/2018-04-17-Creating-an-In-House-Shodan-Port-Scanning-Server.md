---
title: 'Creating an In-House "Shodan" Port Scanning Server' 
date: 2018-04-17 
layout: post.html
collection: cybersecurity, all 
--- 

I do not promote illegal activity of any sort so please use this information responsibly. First, I want everyone to know that I think Shodan is an awesome service and that you will definitely want to continue using it for security purposes. I believe it would be unwise to try to completely replace it with your own solution and not utilize the information it
offers. However, I do believe that supplementing its data with a more accurate, in-house port-scanning server has huge advantages. 

The primary technologies that will make this possible will be Elasticsearch, Kibana (both made by Elastic) and Masscan (https://github.com/robertdavidgraham/masscan).

This tutorial will walk through a basic installation of Elasticsearch, Kibana and Masscan on Ubuntu 16.04.

### Install Java:
Elasticsearch and Kibana both require Java in order to run. So first, we will install Java: 
```
sudo apt-get update sudo apt-get install openjdk-8-jdk
``` 
Verify that Java is installed with this command: `java -version`

### Install and Configure Elasticsearch:
Run these commands to install the Elasticsearch 6.x repository: 
```
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add - 


echo "deb https://artifacts.elastic.co/packages/6.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-6.x.list 
```

Now install Elasticsearch: 
```
sudo apt-get update 
sudo apt-get install elasticsearch
```

I won't go into all the details on configuring Elasticsearch but I will give some simple commands to change the configurations we want. First, we will name the Elasticsearch cluster 'port-scanner': 
```
sudo sed -i 's/#cluster.name: my-application/cluster.name: port-scanner/g' /etc/elasticsearch/elasticsearch.yml
```

Then we will also only allow Elasticsearch to be accessible from 127.0.0.1: 
```
sudo sed -i 's/#network.host: 192.168.0.1/network.host: 127.0.0.1/g' /etc/elasticsearch/elasticsearch.yml
```

Now, enable and start the Elasticsearch service: 
```
sudo systemctl enable elasticsearch.service 
sudo systemctl start elasticsearch.service 
```

Verify Elasticsearch is running using these two commands after a few minutes: 
```
sudo systemctl status elasticsearch.service 
curl http://localhost:9200
```

### Install Kibana:
As the Elastic repository has already been installed, this command can be used to install Kibana: `sudo apt-get install kibana` 

If Kibana is running on another server, run this command to make it accessible on whatever its IP address is (replacing the lettering in bold for your server's IP address or hostname):
```
sudo sed -i 's/#server.host: "localhost"/server.host: "ip-or-hostname"/g' /etc/kibana/kibana.yml 
```

Enable and start the service: 
```
sudo systemctl enable kibana.service 
sudo systemctl start kibana.service 
```

Kibana will now be available on port 5601: http://ip-or-hostname:5601. If you would like to secure Kibana's web interface, set up an Nginx reverse proxy secured with an self-signed SSL certificate.

### Install Masscan:
At the time of this writing, Masscan is available for install through `apt-get`, however the version in Canonical's repositories is outdated. So we will build from source as the repo on Github has a few additional features: 
```
sudo su - 
apt-get install git gcc make libpcap-dev 
cd /opt 
git clone https://github.com/robertdavidgraham/masscan 
cd masscan 
make 
cp bin/masscan /usr/bin/
exit
```

### Install Jsonpyes:
Jsonpyes is a Python program that allows us to upload the masscan results directly to our Elasticsearch machine. We install it through pip: `sudo pip install jsonpyes`. If the pip command is not found, install pip with this command: `sudo apt-get install python-pip`.


### A Script to do All the Work: 
This script will allow a user to run the commands needed to run a scan and upload it to the local Elasticsearch cluster, to have the data easily organized and parseable in Kibana. After editing the script -- see the comments in the script for help editing it -- place it in a specific location and then configure a cron job to run this script at a desired time: 
```
#!/bin/bash #PORTS
should have ports in it that you want to scan for, comma separated. 
PORTS="0-1024, 3389" 
#IP_ADDRESSES should have the IP addresses that you would like to scan, separated only by spaces. 
IP_ADDRESSES='192.168.1.0/24 192.168.2.0/24'
#This variable sets the name of what you want the index to be called that will be uploaded to ES. I would recommend changing this to something more professional but keep the date appended to it so each index is unique. 
DATE="$(date '+%Y-%m-%d_%H:%M')" 
INDEX_NAME="myindex-$DATE" 

#Don't edit the following variables, they create a file based on the date with an extension of .json.

FILE_EXT=".json" 
COMPLETE_FILE="$DATE$FILE_EXT" 

#This is the scan that actually does the work. Change the IP ranges to what you need and add any others that you need behind them. This outputs a JSON file (i.e. 2018-04-10_09:49.json) with the results. 

/usr/bin/masscan "$IP_ADDRESSES" -p "$PORTS" --banners -oJ "$COMPLETE_FILE" 

#When masscan creates the json file mentioned above, it appends an extra $ symbol that prevents the JSON from being valid in Elasticsearch. #These next two commands remove the offending $ by creating a correct temporary file and then overwrites the actual file to be used with the correct JSON format. 

sed '1d; $d' "$COMPLETE_FILE" > "$DATE" sed 's/.$//' "$DATE" > "$COMPLETE_FILE" 

#jsonpyes is a Python program that uploads the
JSON file to Elasticsearch. Install it with sudo pip install jsonpyes. 

/usr/local/bin/jsonpyes --data "$COMPLETE_FILE" --bulk http://localhost:9200 --import --index "$INDEX_NAME" --type scan --check --thread 8 

#Clean up the files created so as to conserve disk space. You can comment out the last line if you want to actually open the json file. 

rm "$DATE" 
rm "$COMPLETE_FILE" 
```

Change the INDEX_NAME variable to reflect what you want the index to be called (I would recommend leaving the date appended to each index so each index is uniquely named based on date and time). You will use the index name to create an initial index pattern in Kibana. Also, change the IP_ADDRESSES and PORTS variable to reflect the respective IPs and ports you would like to scan.  

### Map the Timestamp Field to a Date: 
When the index is imported into Kibana, the timestamp field will not be a date, it will be a string. We want it to be a date so that we can parse through the results by date rather than all of them all at once (assuming you do scans on a repetitive basis). 

Use this command to create an index template to map the Timestamp field to a date: 
```
curl -XPUT 'localhost:9200/_template/**templatename**' -d '{"template": "myindexpattern-*", "mappings": {"scan": {"properties":{"timestamp": {"type" : "date", "format" : "epoch_second"} } } } }'
```

Change the portions of the command that are in bold to reflect what you want the template to be named and then whatever your index pattern will be. If you went with the pattern in the script, the index pattern will be "myindex-*".

### Conclusion: 
Once the script has been run, data should now be stored in Elasticsearch. If it hasn't been set up in Kibana, you will need to create an Index Pattern matching the new index that has been created by the script referenced in the last step.

If the INDEX_NAME variable was set to equal "myindex-$DATE", a sufficient index pattern would be "myindex-*" for all indices that are uploaded using the above script. 

Assuming that all has gone well, Kibana will now have the information available to you to start parsing through and creating visualizations for.
