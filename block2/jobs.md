# Intro to Tapis(Aloe) Jobs

### Tapis(Aloe) Jobs service
The Tapis(Aloe) Jobs service is a basic execution service that allows you to run applications registered with the Tapis Apps service across multiple, distributed, heterogeneous systems through a common REST interface. <br/> This service manages all aspects of execution and job management from data staging, job submission, monitoring, output archiving, event logging, sharing, and notifications. 
The Agave jobs service has been rearchitectured, is called Tapis(Aloe), which provides improved reliability, scalability, performance and serviceability. More details on this new jobs service can be found in the [Jobs Tutorial](https://tacc-cloud.readthedocs.io/projects/agave/en/latest/agave/guides/jobs/introduction.html)


### Jobs Parameters 
An example Job JSON defintion:
```json
{
  "name":"UPDATEUSERNAME.job.imageclassify",
  "appId":"UPDATEAPPID",
  "archive":false,
  "inputs": {},
  "parameters": { 
    "imagefile": "https://texassports.com/images/2015/10/16/bevo_1000.jpg"
    } 
}
```
* **appId**	- The unique ID (name + version) of the application run by this job. This must be a valid application that the user has permission to run.
* **name**	-  The user selected name for the job.
* **archive**	-	Whether the job output should be archived. When true, all new files created during job execution will be moved to the archivePath.
* **parameters** - Application-specific parameters with types defined in the application defintion. <br/>
**appId** and **name** are required parameters. 
Please refer to all the job parameters here [Job Parameters](https://tacc-cloud.readthedocs.io/projects/agave/en/latest/agave/guides/jobs/aloe-job-changes.html#submission-request-parameters)


### Exercise: Submitting a Job
Once you have at least one app registered, you can start running jobs.  To run a job, Tapis just needs to know what app you want to run and what inputs and parameters you want to use. <br/>
There are number of other optional features, which are explained in detail in the [Job Management Tutorial](https://tacc-cloud.readthedocs.io/projects/agave/en/latest/agave/guides/jobs/job-submission.html).  <br/>
Note that you can specify which **queue** to use as well as **runtime limits** in your job.  If those are absent, Tapis falls back to whatever was listed in the app description (also optional). If that app doesn't specify, then it falls back to the defaults given for the execution system.

Lets run our very first Tapis(Aloe) Job! <br/>

### Step 1: Crafting a Job Definition 
You can find the appId of the app that you just registered and your storage system id with the command below.

```
$ tapis apps list
```

Modify the job.json with the app id obtained with apps list
```json
{
  "name":"UPDATEUSERNAME.job.imageclassify",
  "appId":"UPDATEAPPID",
  "archive":false,
  "inputs": {},
  "parameters": { 
    "imagefile": "https://texassports.com/images/2015/10/16/bevo_1000.jpg"
    } 
}
```


### Step 2: Submit job 

Run the job submission command from the directory where you have job.json

```
$ tapis job submit -F job.json 

```

You should see job id, name of job and status as "ACCEPTED"

### Step 3: Check Job Status
Job status allows you to see the current state of the job. You can check the status of job with followinng command. You can also set up email or webhook notification and get notified when the job state changes

```
$ tapis jobs status {job id}
```

Job enters into different states throughout the execution. Details about different job states are given here [JOB STATES](https://tacc-cloud.readthedocs.io/projects/agave/en/latest/agave/guides/jobs/aloe-job-changes.html#job-states)


### Step 4: Download Job Output. This may take few minutes. 

```
tapis jobs output download {job id}

```

With this command, you can see the job folder created in pwd. <br/>
You can cd into the job folder and view the predictions.txt file. If the job ran successfully you should see following output in predictions.txt file
```
>> Downloading inception-2015-12-05.tgz 100.0%
Successfully downloaded inception-2015-12-05.tgz 88931400 bytes.
ox (score = 0.80479)
water buffalo, water ox, Asiatic buffalo, Bubalus bubalis (score = 0.06445)
oxcart (score = 0.02327)
ram, tup (score = 0.00376)
lakeside, lakeshore (score = 0.00230)
```


### Jobs Notifications
You can monitor progress of your job by setting by email or webhook notifications
Add this to your job definition and try to submit the job again

```
"notifications":[
    {
      "url":"UPDATEEMAILADDRESS",
      "event":"*",
      "persistent":true
    }
    ]
```

You should see email notifications pop up in your inbox as the job changes state.

## What's next?

If you made it this far, you have successfully created a new app within a container and have deployed that tool on an HPC system, and now you can run that tool through the cloud from anywhere!  That is quite a lot in one workshop.

At this point, it would be a good idea to connect with other developers that are publishing apps and running workflows through Tapis by joining the Tapis API Slack channel: [tacc-cloud.slack.com](https://bit.ly/2XHYJEk)

[BACK](https://tacc.github.io/summer-institute-2020-tapis/)


