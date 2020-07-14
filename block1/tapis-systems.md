# Managing systems


The Tapis API provides a way to access and manage the data storage and compute resources you already use (or maybe the systems you want to use), but first you have to tell Tapis where they are, how to login, and how to communicate with that system.  That is done by giving Tapis a short JSON description for each system.  

### Tapis Storage Systems

Storage systems tell Tapis where data resides.  You can store files for running compute jobs, archive results, share files with collaborators, and maintain copies of your Tapis apps on storage systems.  Tapis supports many of the communication protocols and  permissions models that go along with them, so you can work privately, collaborate with individuals, or provide an open community resource.  It's up to you.  Here is an example of a simple data storage system template accessed via SFTP for the TACC cloud storage system on Stampede2:

```json
{
  "id": "UPDATEUSERNAME.tacc.S2.storage",
  "name": "Storage system S2",
  "status": "UP",
  "type": "STORAGE",
  "description": "Storage system for TACC cloud storage on S2",
  "site": "www.tacc.utexas.edu",
  "public": false,
  "default": true,
  "storage": {
    "host": "stampede2.tacc.utexas.edu",
    "port": 22,
    "protocol": "SFTP",
    "rootDir": "/",
    "homeDir": "/work/dir../UPDATEUSERNAME/stampede2",
    "auth": {
      "username": "UPDATEUSERNAME",
      "publicKey":"paste public key here",
      "privateKey":"paste private key here",
      "type": "SSHKEYS"
    }
  }
}
```

* **id** -This needs to be a unqiue identifier amongst all systems in Tapis - so using your username helps ensure this.
* **name** - This can be whatever you like, but should be descriptive for you.
* **status** - This is used when querying systems and can give other users an idea if the system is UP or DOWN- only sytems that are UP can be accessed.
* **type** - A system can be STORAGE or EXECUTION.
* **site** - A url typically with information about the system.
* **default** - TRUE or FALSE if this is the default system for Tapis to use when not explicitly passed a system.
* **public** - Is this a shared resource available to all users - only Administrators can set this to TRUE.
* **host** -  This is the ip or domain of the server we need to connect to
* **port** -  This is the port we need to use when connecting, this is usally tied to the proctocal (SFTP is usually port 22)
* **protocol** - This is the communication protocol most systems use SFTP but others are supported.
* **rootDir** - This is the lowest directory any Tapis user accessing this system can navigate.
* **homeDir** - This is the directory that a Tapis user will access by default.
* **auth** - The Authenication type to use when accessing the system - in this tutorial we are using SSH-KEYS, you may use PASSWORD authentication as well

More details on the possible parameters for storage systems can be found in the [Tapis Storage System documentation](https://tacc-cloud.readthedocs.io/projects/agave/en/latest/agave/guides/systems/systems-storage.html).

## Hands-on Exercises

### Keys retrival
Before you start working on the storage system definition please make sure that your public key is placed in the authorized keys file on Stampede2. <br/>
Keep the public key and private key handy, these are required for the system definition. To retrive keys, login to Stampede2, go to .ssh folder and copy your public key into a notepad. It is recommended to generate one line private key using the command below. Save this to a notepad as well.

```
awk -v ORS='\\n' '1' private_key_name

```

### System definition

Copy the above system definition template in a new storage.json file on your present working directory on the CLI terminal. Please make sure to change the username, homeDir and auth block in the above template. Copy the one liner keys in the auth block. Once your system definition is ready, use the command below to register the system.


CLI command to register system is:
```
tapis systems create -F storage.json
```

The above command will submit the JSON file "storage.json" to Tapis and create a new system with the attributes specified in the JSON file. Please note the system id, as it will be used throughout this tutorial.

You can now see your newly created system by running the following Tapis CLI command:
```
tapis systems list
```
To make sure that the system keys are configured correct, try to do files listing using the storage system id
```
tapis files list agave://{storage system id }/
```
If the keys are configured correct, it should show you the files on your stampede2 work dir. This is an important step and must not be missed.

---
## Tapis Execution Systems

Execution systems in Tapis are very similar to storage systems.  They just have additional information for how to launch jobs.  In this example, we are using the Stampede2 HPC system, so we have to give scheduler and queue information.  This system description is longer than the storage definition due to logins, queues, scratch systems definitions.

```json
{
  "id": "UPDATEUSERNAME.stampede2.execution",
  "name": "Execution system S2",
  "status": "UP",
  "type": "EXECUTION",
  "description": "Execution system for Stampede2 ",
  "site": "www.tacc.utexas.edu",
  "executionType": "HPC",
  "scratchDir": "/home1/dir/UPDATEUSERNAME/scratch",
  "workDir": "/home1/dir/UPDATEUSERNAME/work",
  "login": {
    "host": "stampede2.tacc.utexas.edu",
    "port": 22,
    "protocol": "SSH",
    "scratchDir": "/home1/dir/UPDATEUSERNAME/scratch",
    "workDir": "/home1/dir/UPDATEUSERNAME/work",
    "auth": {
      "username": "UPDATEUSERNAME",
      "publicKey":"paste public key here",
      "privateKey":"paste private key here",
      "type": "SSHKEYS"
    }
  },
  "storage": {
    "host": "stampede2.tacc.utexas.edu",
    "port": 22,
    "protocol": "SFTP",
    "rootDir": "/",
    "homeDir": "/home1/dir/UPDATEUSERNAME",
    "auth": {
      "username": "UPDATEUSERNAME",
      "publicKey":"paste public key here",
      "privateKey":"paste private key here",
      "type": "SSHKEYS"
    }
  },
  "maxSystemJobs": 100,
  "maxSystemJobsPerUser": 10,
  "scheduler": "SLURM",
  "queues": [
    {
      "name": "normal",
      "maxJobs": 100,
      "maxUserJobs": 10,
      "maxNodes": 128,
      "maxMemoryPerNode": "2GB",
      "maxProcessorsPerNode": 128,
      "maxRequestedTime": "24:00:00",
      "customDirectives":"-A UPDATEPROJECT -r UPDATERESERVATION",
      "default": true
    }
  ],
  "environment": "",
  "startupScript": null
}
```

We covered what some of these keywords are in the storage systems section.  Below is some commentary on the new fields:

* **executionType** - Either HPC, Condor, or CLI.  Specifies how jobs should go into the system. 
* **scheduler** - For HPC or CONDOR systems, Tapis is "scheduler aware" and can use most popular schedulers to launch jobs on the system.  This field can be LSF, LOADLEVELER, PBS, SGE, CONDOR, FORK, COBALT, TORQUE, MOAB, SLURM, UNKNOWN. The type of batch scheduler available on the system.
* **environment** - List of key-value pairs that will be added to the Linux shell environment prior to execution of any command.
* **scratchDir** - Whenever Tapis runs a job, it uses a temporary directory to cache any app assets or job data it needs to run the job.  This job directory will exist under the "scratchDir" that you set.  The path in this field will be resolved relative to the rootDir value in the storage config if it begins with a "/", and relative to the system homeDir otherwise.
* **workDir** - Path to use for a job working directory. This value will be used if no scratchDir is given. The path will be resolved relative to the rootDir value in the storage config if it begins with a "/", and relative to the system homeDir otherwise.
* **queue** - An array of batch queue definitions providing descriptive and quota information about the queues you want to expose on your system. If not specified, no other system queues will be available to jobs submitted using this system.
* **startupScript** - Path to a script that will be run prior to execution of any command on this system. The path will be a standard path on the remote system. A limited set of system macros are supported in this field. They are rootDir, homeDir, systemId, workDir, and homeDir. The standard set of runtime job attributes are also supported. Between the two set of macros, you should be able to construct distinct paths per job, user, and app. Any environment variables defined in the system description will be added after this script is sourced. If this script fails, output will be logged to the .agave.log file in your job directory. Job submission will still continue regardless of the exit code of the script.

Complete reference information is located here:
[Systems](https://tacc-cloud.readthedocs.io/projects/agave/en/latest/agave/guides/systems/introduction.html)

## Hands-on Exercises

As a hands on exercise, register the Stampede2 HPC as a execution system using the Tapis-CLI using the above JSON template. Copy the above template in new compute.json file on your pwd in the CLI terminal. Make changes into fields id, scratchDir, workDir,homeDir, auth stanza and customDirectives. Use your training project name and resevation name in customDirectives. 

CLI command to register is:
```
tapis systems create -F compute.json
```

Store the execution system id for later use. You can now see your newly created system by running the following Tapis CLI command:
```
tapis systems list

```

If you want to view the system details use this CLI command
```
tapis systems show -f json {compute system id}

```
Just like you did files listing for storage system, list files on execution system to make sure that the SSH keys are set up correct
```
tapis files list agave://{compute system id}/
```

Congratulations! You have successfully registered private systems, in the next part of the tutorial we will talk about registering applications with Tapis.

[NEXT-> APPS](/block2/apps.md)
