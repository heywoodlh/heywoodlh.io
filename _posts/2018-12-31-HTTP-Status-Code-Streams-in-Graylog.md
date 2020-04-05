---
layout: post.html
date: 2018-12-31
title: 'Configuring HTTP Status Code Streams in Graylog'
collections: all, linux, cybersecurity
---


This is a simple breakdown of setting up streams in Graylog based on HTTP status codes. This is useful for looking at web server logs to identify potential unwanted or malicious activity from a remote machine to a web server.



## The Example Log:

```
message
wordpress[782]: 172.17.0.1 - - [01/Jan/2019:07:03:56 +0000] "GET /promotion/bantamsbanter.co.uk/1405657.html HTTP/1.0" 404 68641 "-" "Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)"
```


## The Regular Expressions:


### HTTP Status Code:

```
\s(\d\d\d)\s
```

This regular expression against the example log will extract '404' (without quotes). 


### HTTP Client IP:

```
(\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b)
```

This regular expression against the example log will extract '172.17.0.1' (without quotes). A more precise regular expression could be used but in this case I'm not too concerned with the precision of the regular expression (for example, this regex would also detect 999.999.999.999 as an IP address).



## Create Extractors for the Inputs in Graylog:


Use the above regular expressions as "regular expression" extractors on the inputs in Graylog receiving the web server logs. 

Go to System/Inputs > Inputs > [Your Web Server Log Input] > Manage extractors > Add extractor > Get started > Load Message

Find your "message" field and select "Select extractor type" and then "Regular expression" on that field. On the following page in the Regular expression field, enter one of the above regular expressions for the extractor you would like to create (I.E. \s(\d\d\d)\s for a HTTP Status Code extractor). In the "Store as field" field enter what you would like the extracted data to be named. 


## Use Case:

Using extractors for each of the above regular expressions it would be relatively easy to correlate potential scanning/attacks on a web server. For example, it would be easy to see a remote IP generating multiple 404 status codes (most likely scanning of some sort) on a single web server and to generate alerts or an automated response based on those events. 
