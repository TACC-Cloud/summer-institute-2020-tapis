# Intro to Tapis Apps 
---

### What is a Tapis app? 
A Tapis App is versioned, containerized executable that runs on a specific execution system through Tapis(Aloe) Jobs service.  
So, for example, if you have multiple versions of a software package on a system, you would register each version as its own app. Likewise, if a single application code needs to be run on multiple systems, each combination of app and system needs to be defined as an app.
Once you have storage and execution systems registered with Tapis, you are ready to build and use apps. 


### Tapis Apps service
Apps service is a central registry for all Tapis apps. With Apps service you can:  
* list or search apps
* register new apps
* manage or share app permissions
* revise existing apps
* view information about each app such as its version number, owner, revision number to name a few <br/>

The rest of this tutorial explains details about how to package your Tapis app, register your app with the Apps service and some other useful CLI commands for Apps. 


### Create Private App: Image Classifier 
Tapisapps are bundled into a directory and organized in a way that Tapis(Aloe) jobs can properly invoke it. Tapis(Aloe) is the new code name for rearchitectured Jobs service. We will discuss more on this in the next part of the tutorial. 

## Step 1: Initialize the app directory with following CLI command
```
$ tapis app init --app-label classifier --app-description "Image classifier" --app-version 0.0.1 classifier_app
```
The response should look like
```
+-------+---------------------------------------+
| stage | message                               |
+-------+---------------------------------------+
| setup | Project name: classifier_app          |
| setup | Project description: Image classifier |
| setup | Project version: 0.0.1                |
| setup | Safened project name: classifier_app  |
| setup | Project path: ./classifier_app        |
| clone | Project path: ./classifier_app        |
+-------+---------------------------------------+
```
This will create a new template app folder (in this case, called ~/classifier_app)

```
$ ls -la classifier_app
classifier_app
├── Dockerfile
├── app.json
├── assets
│   ├── lib
│   │   ├── VERSION
│   │   └── container_exec.sh
│   ├── runner.sh
│   └── tester.sh
├── job.json
└── project.ini
```
A brief summary of the files are as follows:

* Dockerfile: a Dockerfile for the app runtime
* app.json: json file describing the app metadata, inputs, parameters, and outputs
* VERSION: version file containing the image tag
* container_exec.sh: utility script for executing a container on a TACC HPC system
* runner.sh: main run script for the app; takes input and parameters from app.json
* tester.sh: legacy script that may be used to run a local test
* job.json: template for a job json file specific to this app
* project.ini: initialization parameters for the app which are injected in to app.json


## Step 2: Edit the project.ini file
By default, the fields are populated by some of the flags specified on the command line or picked up from the environment. 
Set the following and unncomment these two lines:
```
deployment_system = {input your private storage system created in this tutorial}
execution_system = {input your private execution system created in this tutorial}
```

## Step 3: Create a deployment folder on $WORK of Stampede2
In a separte terminal login to Stampede2 using your TACC credentials and TACC MFA token
* cd $WORK
* mkdir classifyapp
* Note this path for later use. This is the deploymentPath that you will need to update in the app.json


## Step 4: Create a wrapper.sh
In order to run your application, you will need to create a wrapper template that calls your executable code. For the sake of maintainability, it should be named something simple and intuitive like `wrapper.sh`. The singularity image to run the app is stored in a public location /work/05278/ajamthe/stampede2/public/gateways19-classifier.simg, make sure you **keep it as it is** Within a wrapper script, you can reference the ID of any Tapis input or parameter from the app description. Before executing a wrapper script, Tapiswill look for the these references and substitute in whatever was that value was. This will make more sense once we start running jobs, but this is the way we connect what you tell the Tapis API that you want to do and what actually runs on the execution system. The other thing Tapis will do with the wrapper script is prepend all the scheduler information necessary to run the script on the execution system.

* Create a file wrapper.sh in the deployment folder (on Stampede2) and copy the script below into the wrapper.sh 

```
#/bin/bash
module load tacc-singularity/3.4.2

singularity run /work/05278/ajamthe/stampede2/public/gateways19-classifier.simg  python /classify_image.py ${imagefile} ${predictions} > predictions.txt

```

## Step 5: Create a test script
A test script named something simple and intuitive like `tester.sh`, along with any sample data needed to evaluating whether the application can be executed in a current command-line environment. It should exit with a status of 0 on success when executed on the command line. A simple way to create your test script is to set some sensible default values for your app's inputs and parameters and then call your wrapper template.

* Create a file tester.sh in the deployment path (on Stampede 2) and copy the script below into the tester.sh file

```
#!/bin/bash
module load tacc-singularity/3.4.2

export imagefile="--image_file=https://s3.amazonaws.com/cdn-origin-etr.akc.org/wp-content/uploads/2017/11/12231410/Labrador-Retriever-On-White-01.jpg"
export predictions="--num_top_predictions 5"

cd ../ && bash wrapper.sh

```

## Step 6: Modify app.json in the CLI
This is a templated app json file. By default, it will grab the app name, version, executionSystem, deploymentSystem, and other parameters from your project.ini. Copy the app.json from [here](./templates/app.json) and paste in your app.json and make following changes:
* Change the value of deploymentPath to one obtained in Step 2
* Change the values of deploymentSystem to your storage system
* Change the value of executionSystem to your execution system

### Application Metadata
An example Tapis App JSON definition:

```
{
  "checkpointable": false,
  "name": " app.name ",
  "executionSystem": "replace with execution system name",
  "executionType": "HPC",
  "deploymentPath": "replace with deployment path",
  "deploymentSystem": "replace with storage system name",
  "helpURI": "",
  "label": " app.label",
  "shortDescription": "app.description",
  "longDescription": "",
  "modules": [
    "load tacc-singularity/3.4.2"
  ],
  "ontology": [],
  "parallelism": "SERIAL",
  "tags": [],
  "templatePath": "wrapper.sh",
  "testPath": "tester.sh",
  "version": "app.version",
  "defaultMaxRunTime": "00:30:00",
  "inputs": [],
  "parameters": [
  {
    "id": "imagefile",
    "details": {
      "label": "Image to classify",
      "description":"",
      "argument": "--image_file ",
      "showArgument":true
    },
    "semantics": {
      "minCardinality":1,
      "ontology": [
        "http://edamontology.org/format_3547"
      ],
      "maxCardinality": 1
    },
    "value": {
      "default": "https://texassports.com/images/2015/10/16/bevo_1000.jpg",
      "order": 0,
      "required": true,
      "type": "string",
      "visible": true
    }
   },
  {
    "id": "predictions",
    "details": {
      "label": "Number of predictions to return",
      "argument": "--num_top_predictions ",
      "showArgument": true
    },
    "semantics": {
      "maxCardinality": 1,
      "ontology": [],
      "minCardinality": 1
    },
    "value": {
      "visible": true,
      "required": true,
      "type": "number",
      "default": 5
    }
  }
  ],
  "outputs": []
}

```
* **name** - Apps are given an ID by combining the "name" and "version". That combination must be unique across the entire Tapis tenant, so unless you are an admin creating public system, you should probably put your username somewhere in there, and it's often useful to have the system name somehow referenced there too. You shouldn't use spaces in the name.
* **version** - This should be the version of the software package that you are wrapping.  If you end up updating your app description later on, Tapis will keep track of the app revision separately, so there is no need to reflect that here.
* **deploymentSystem** - The data storage system where you keep the app assets, such as the wrapper script, test script, etc.  App assets are not stored on the execution system where they run.  For provenance and reproducibility, Tapis requires that you keep them on a cloud storage system.
* **deploymentPath** - the directory on the deploymentSystem where the app bundle is located
* **templatePath** - This template is what Tapis uses to run your app.  The path you specify here is relative to the deploymentPath
* **testPath** - The intention here is that you include a testcase inside of your app bundle.
* **argument** - In combination with "showArgument", the "argument" keyword is a convenience that lets you build up commandline arguments in your wrapper script.
* **Cardinality** - Sets the min and max number of files you can give for inputs and outputs.  A "maxCardinality" of -1 will accept an unlimited number of files.
Some of the above fields are manadatory to register the app. A complete list of application metadata can be found at [Application Metadata](https://tacc-cloud.readthedocs.io/projects/agave/en/latest/agave/guides/apps/app-wrapper-templates.html#application-metadata)


## Step 7: Registering an app  
Registering an app with the Apps service is conceptually simple. Just describe your app as a JSON document and POST it to the Apps service. From the folder where you have app.json run command below
```
$ tapis apps create -F app.json 
```
Tapis will check the app description, look for the app bundle on the deploymentSystem, and if everything passes, make it available to run jobs with Tapis Jobs service.<br/>

Some other useful CLI commands:

### List apps 
Now if you list apps you should see the app you just registered. You should also see other public apps available to the user in that tenant

```
$ tapis apps list
```

To see details about a specific app 

```
$ tapis apps show {app_id}
```

### Managing App Permissions

To view the permissions on the app for different users 

```
$ tapis apps pems list {app_id}

```

 Now that we have our very first app ready to use, we are ready to run it on Stampede2 using Tapis(Aloe) Jobs service. 

 [NEXT-> JOBS](./jobs.md)


## More Resources

Building Tapis applications can be very rewarding way to share your code with your colleagues and the world. This is a very simple example. If you are interested to learn more, please check out the [App Management Tutorial](https://tacc-cloud.readthedocs.io/projects/agave/en/latest/agave/guides/apps/introduction.html),
[Create custom App with Tapis CLI](https://tapis-cli-how-to-guide.readthedocs.io/en/latest/advanced-api/create_a_custom_app.html)
