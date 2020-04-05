---
title: 'Using OpenVAS from Metasploit's Console' 
date: 2018-05-14
layout: post.html
collection: cybersecurity, linux, all 
--- 

Metasploit and OpenVAS are awesome open source security tools designed for penetration tests that anybody can use. Metasploit is an exploitation framework designed to make exploiting known vulnerabilities extremely simple. However, before you can know what to exploit you should run a vulnerability scanner to look for vulnerabilities on a network. OpenVAS is an open source vulnerability scanner that ties into Metasploit really well. 
This article will walk through connecting Metasploit to OpenVAS and then running OpenVAS from Metasploit's console. This article will assume that you have OpenVAS and Metasploit already set up on your machine.
Assuming you have Docker installed, you can quickly spin up OpenVAS using this command: 
```
docker run -d -p 443:443 -p 9390:9390 --name openvas mikesplain/openvas
```
### The Commands:
First, open Metasploit's console: `msfconsole` 

Then, load the OpenVAS module: 
```
msf> load openvas 
```
<br>

Display the OpenVAS module's help page: 
```
msf > openvas_help
[*] openvas_help                  Display this help
[*] openvas_debug                 Enable/Disable debugging
[*] openvas_version               Display the version of the OpenVAS server
[*]
[*] CONNECTION
[*] ==========
[*] openvas_connect               Connects to OpenVAS
[*] openvas_disconnect            Disconnects from OpenVAS
[*]
[*] TARGETS
[*] =======
[*] openvas_target_create         Create target
[*] openvas_target_delete         Deletes target specified by ID
[*] openvas_target_list           Lists targets
[*]
[*] TASKS
[*] =====
[*] openvas_task_create           Create task
[*] openvas_task_delete           Delete a task and all associated reports
[*] openvas_task_list             Lists tasks
[*] openvas_task_start            Starts task specified by ID
[*] openvas_task_stop             Stops task specified by ID
[*] openvas_task_pause            Pauses task specified by ID
[*] openvas_task_resume           Resumes task specified by ID
[*] openvas_task_resume_or_start  Resumes or starts task specified by ID
[*]
[*] CONFIGS
[*] =======
[*] openvas_config_list           Lists scan configurations
[*]
[*] FORMATS
[*] =======
[*] openvas_format_list           Lists available report formats
[*]
[*] REPORTS
[*] =======
[*] openvas_report_list           Lists available reports
[*] openvas_report_delete         Delete a report specified by ID
[*] openvas_report_import         Imports an OpenVAS report specified by ID
[*] openvas_report_download       Downloads an OpenVAS report specified by ID
```
<br>

The first thing we need to do is connect to OpenVAS: 
```
msf > openvas_connect <admin> <password> 127.0.0.1 9390 
ok 
```
<br>

Now, create a target: 
```
msf > openvas_target_create host1 192.168.1.50 'My First Host'
```
<br>

List your targets: 
```
msf > openvas_target_list
```
<br>

Before we can create a task, let's also list the scan configs that can be used as we will need that to create the task: 
```
msf > openvas_config_list
[+] OpenVAS list of configs



ID Name
-- ----
085569ce-73ed-11df-83c3-002264764cea empty
2d3f051c-55ba-11e3-bf43-406186ea4fc5 Host Discovery
698f691e-7489-11df-9d8c-002264764cea Full and fast ultimate
708f25c4-7489-11df-8094-002264764cea Full and very deep
74db13d6-7489-11df-91b9-002264764cea Full and very deep ultimate
8715c877-47a0-438d-98a3-27c7a6ab2196 Discovery
bbca7412-a950-11e3-9109-406186ea4fc5 System Discovery
daba56c8-73ec-11df-a475-002264764cea Full and fast
```

The command for creating a task is this: 
```
msf > openvas_task_create <scan name> 'Scan details' <scan ID> <target ID>
```
     
If we were to use the ID for host1 from my example openvas_target_list above and a 'Full and fast' scan, this would be the command:
 
```
msf > openvas_task_create scan1 'My first scan' daba56c8-73ec-11df-a475-002264764cea ddcf992e-c705-455c-8fb3-1fdb4fb5a672 
```
<br>

Once the task has been created, list it: 
```
msf > openvas_task_list
[+] OpenVAS list of tasks

ID                                    Name      Comment                 Status
Progress
--                                    ----      -------                 -----
-  --------
4c66fc5b-cab9-4a98-80b9-28147803dfff  scan1     My first scan           New
-1
Start the task: msf > openvas_task_start 4c66fc5b-cab9-4a98-80b9-28147803dfff
Check the status of the task: msf > openvas_task_list The Status will change to
done when the task is completed:
msf > openvas_task_list
[+] OpenVAS list of tasks

ID                                    Name      Comment                 Status
Progress
--                                    ----      -------                 -----
-  --------
4c66fc5b-cab9-4a98-80b9-28147803dfff  scan1     My first scan           Done
-1
Now, list available vulnerability reports: msf > openvas_report_list
[+] OpenVAS list of reports

ID                                    Task Name  Start Time            Stop
Time
--                                    ---------  ----------            --------
-
94919a2f-e338-4b2e-8b49-5f2ab4f6a36b  scan1      2018-05-14T20:23:37Z  2018-05-
14T20:30:41Z
Before downloading it, we also need to know what format id we will be using:
msf > openvas_format_list
[+] OpenVAS list of report formats

ID                                    Name           Extension  Summary
--                                    ----           ---------  -------
5057e5cc-b825-11e4-9d0e-28d24461215b  Anonymous XML  xml        Anonymous
version of the raw XML report
50c9950a-f326-11e4-800c-28d24461215b  Verinice ITG   vna        Greenbone
Verinice ITG Report, v1.0.1.
5ceff8ba-1f62-11e1-ab9f-406186ea4fc5  CPE            csv        Common Product
Enumeration CSV table.
6c248850-1f62-11e1-b082-406186ea4fc5  HTML           html       Single page
HTML report.
77bd6c4a-1f62-11e1-abf0-406186ea4fc5  ITG            csv        German "IT-
Grundschutz-Kataloge" report.
9087b18c-626c-11e3-8892-406186ea4fc5  CSV Hosts      csv        CSV host
summary.
910200ca-dc05-11e1-954f-406186ea4fc5  ARF            xml        Asset Reporting
Format v1.0.0.
9ca6fe72-1f62-11e1-9e7c-406186ea4fc5  NBE            nbe        Legacy OpenVAS
report.
9e5e5deb-879e-4ecc-8be6-a71cd0875cdd  Topology SVG   svg        Network
topology SVG image.
a3810a62-1f62-11e1-9219-406186ea4fc5  TXT            txt        Plain text
report.
a684c02c-b531-11e1-bdc2-406186ea4fc5  LaTeX          tex        LaTeX source
file.
a994b278-1f62-11e1-96ac-406186ea4fc5  XML            xml        Raw XML report.
c15ad349-bd8d-457a-880a-c7056532ee15  Verinice ISM   vna        Greenbone
Verinice ISM Report, v3.0.0.
c1645568-627a-11e3-a660-406186ea4fc5  CSV Results    csv        CSV result
list.
c402cc3e-b531-11e1-9163-406186ea4fc5  PDF            pdf        Portable
Document Format report.
```
<br>

The syntax for the report download command is this: 
```
msf > openvas_report_download <report ID> <format ID> <path to directory> <file name>
```   
<br>

If we were to use the above report ID and TXT format and download the report to the file `~/Downloads/report.txt`, this would be the command used: 
```
msf > openvas_report_download 94919a2f-e338-4b2e-8b49-5f2ab4f6a36b a3810a62-1f62-11e1-9219-406186ea4fc5 ~/Downloads/ report.txt
``` 
Now that the report has been generated, you can view it and use it for your pen test.
