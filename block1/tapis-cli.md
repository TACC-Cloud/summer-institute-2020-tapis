
Tutorial: Getting Started with Tapis CLI
===============================================
The following instructions will guide you through setting up Tapis CLI (command line interface).  As an aside, everything we do today can also be accomplished from a command line interface or by directly calling API endpoints.  

The Tapis CLI commands all respond with help for -h and return back information on the parameters that can be passed.  

Need help?  Ask your questions using the [TACC Institutes Slack Channel](https://app.slack.com/client/T015E2VMTLH/C015RUFEYBH)

Initial Requirements
===============================================

Before getting started, you need to have the following:
* A TACC Account
* Docker installed on your local computer
* Familiarity with [working at the command line](http://www.gnu.org/software/bash/manual/bashref.html#Introduction)

Any questions?  Join the [TACC Institute SLACK CHANNEL](https://app.slack.com/client/T015E2VMTLH/C015RUFEYBH) and ask away.


Command Line Access
===============================================

**Goal of this section:** Open a terminal on your machine and install Tapis CLI.

Tapis has a downloadable set of command line tools that make it easier to work with the API from the shell. Using the CLI is easier than hand-crafting cURL commands, but if you prefer that route, consult the [Tapis API Documentation](https://tacc-cloud.readthedocs.io/en/latest/).

Using docker, we'll download and run an environment which allows the use of the `tapis` command, which is what we'll be using to communicate with Tapis.
```
docker run --rm -it -v ${PWD}:/work -v ${HOME}/.tapis:/root/.agave tacc/tapis-cli:latest bash
```
After waiting for the image to download, do you see the cow? (moo in the chat if you do) ```🐮 tapis-cli:1.0.0@4fab4de30c26#```

We'll know Tapis CLI installed correctly when the `tapis -h` command returns some information about the application:

```
> tapis -h
usage: tapis [--version] [-v | -q] [--log-file LOG_FILE] [-h] [--debug]

Tapis CLI: Command line tools to support the TACC Tapis platform. For support
contact "TACC Help" <cli-help@tacc.cloud>

optional arguments:
  --version            show program's version number and exit
  -v, --verbose        Increase verbosity of output. Can be repeated.
  -q, --quiet          Suppress output except warnings and errors.
  --log-file LOG_FILE  Specify a file to log output. Disabled by default.
  -h, --help           Show help message and exit.
  --debug              Show tracebacks on errors.

Commands:
  apps create    Create a new app
  apps disable   Disable usage of an app
  apps enable    Restore usage for an app if disabled
  apps history   List history for an specific app
  apps list      List the Apps catalog
  apps pems grant  Grant permissions on an app to a user
...
```

(Did you get this working? Answer the poll in our Slack channel and our proctors can help you through it!)


Authentication
===============================================

Tapis has robust Authentication/Authorization pathways - we could spend an hour or more discussing them, but will keep our focus simple for this tutorial.

The Tapis API uses OAuth 2 for managing authentication and authorization. OAuth 2 is an open standard for access delegation, commonly used as a way for Internet users to grant websites or applications access to their information on other websites but without giving them the passwords.

Understand that instead of passing a username and password every time we want to make an authenticated/authorized request to the Tapis APIs, we will be using an Access Token that has a defined expiration - this keeps our credentials safe and ensures that if someone where to obtain the token it could not be used forever.

Run the following in the CLI and expect to get the following message

```
> tapis auth show
Auth configuration was not loaded. Try running "tapis auth init".
```

We will see that we have to initialize a client before we can use Tapis CLI.

Initialize an API client using the CLI
===============================================

Upon installation, you must initialize your Tapis CLI

You can initialize the TACC tenant by running ```tapis auth init```:

**Note:** The `tapis auth init` command creates a Tapis client and requests an API token. The TACC tenant, client, and API token information will be placed into a cache in `~/.tapis/current`. This is the file that Tapis CLI will look for when making API calls so that you don't have to enter those parameters for every call.

```
> tapis auth init

Use of Tapis requires acceptance of the TACC Acceptable Use Policy 
which can be found at https://portal.tacc.utexas.edu/tacc-usage-policy

Do you agree to abide by this AUP? (type 'y' or 'n' then Return) y

Use of Tapis requires acceptance of the Tapis Project Code of Conduct
which can be found at https://tapis-project.org/code-conduct

Do you agree to abide by this CoC? (type 'y' or 'n' then Return) y

To improve our ability to support Tapis and the Tapis CLI, we would like to
collect your IP address, operating system and Python version. No personally-
identifiable information will be collected. This data will only be shared in
aggregate form with funders and Tapis platform stakeholders.

Do you consent to this reporting? [Y/n]: Y
```
After answering the yes or no questions, you should see `Enter a tenant name`. For those who may not know, a tenant is... TODO: What is a tenant?

We will be using the `portals` tenant, so type that as the tenant name and press enter. 

```
+---------------+--------------------------------------+----------------------------------------+
|      Name     |             Description              |                  URL                   |
+---------------+--------------------------------------+----------------------------------------+
|      3dem     |             3dem Tenant              |         https://api.3dem.org/          |
|   agave.prod  |         Agave Public Tenant          |      https://public.agaveapi.co/       |
|  araport.org  |               Araport                |        https://api.araport.org/        |
|     bridge    |                Bridge                |     https://api.bridge.tacc.cloud/     |
|   designsafe  |              DesignSafe              |    https://agave.designsafe-ci.org/    |
|  iplantc.org  |         CyVerse Science APIs         |       https://agave.iplantc.org/       |
|      irec     |              iReceptor               | https://irec.tenants.prod.tacc.cloud/  |
|    portals    |            Portals Tenant            |  https://portals-api.tacc.utexas.edu/  |
|      sd2e     |             SD2E Tenant              |         https://api.sd2e.org/          |
|      sgci     | Science Gateways Community Institute |        https://sgci.tacc.cloud/        |
|   tacc.prod   |                 TACC                 |      https://api.tacc.utexas.edu/      |
| vdjserver.org |              VDJ Server              | https://vdj-agave-api.tacc.utexas.edu/ |
+---------------+--------------------------------------+----------------------------------------+
Enter a tenant name [tacc.prod]: portals
tacc.prod username: your_tacc_username
tacc.prod password for your_tacc_username: [PASSWORD]

Container registry access:
--------------------------
Registry Url [https://index.docker.io]: [ENTER]
Registry Username: n/a
Registry Password: n/a
Registry Namespace: n/a

Git server access:
------------------
Git Username: n/a
Learn about github.com personal access tokens:
https://help.github.com/en/github/authenticating-to-github/creating-a-personal-access-token-for-the-command-line
Git Token: n/a
Git Namespace [n/a]: n/a
+--------------------+--------------------------------------+
| Field              | Value                                |
+--------------------+--------------------------------------+
| tenant_id          | portals                              |
| username           | your_tacc_username                   |
| client_name        | _cli-portals-username-a6fb810bd43e   |
| api_key            | 0fvGYkdummypTsVASlpBdummy48a         |
| access_token       | 1234345636b1106698f581erhfg4d3a8     |
| expires_at         | Mon Jul 13 21:19:26 2020             |
| verify             | True                                 |
| registry_url       | https://index.docker.io              |
| registry_username  | n/a                                  |
| registry_password  | n*a                                  |
| registry_namespace | n/a                                  |
| git_username       | n/a                                  |
| git_token          | n*a                                  |
| git_namespace      | n/a                                  |
+--------------------+--------------------------------------+
```

Behold the glorious box that is your initialized API client!

Run ```tapis auth show``` to see your newly minted client's access token and refresh token

(Talk about token expiration and auto-refreshing in the CLI)

```
tapis auth show
+---------------+----------------------------------+
| Field         | Value                            |
+---------------+----------------------------------+
| tenant_id     | portals                          |
| username      | your_tacc_username               |
| api_key       | 0fvGYkdummypTsVASlpBdummy48a     |
| access_token  | 1234345636b1106698f581erhfg4d3a8 |
| expires_at    | Mon Jul 13 21:19:26 2020         |
| refresh_token | 938fb1c860a97f5bjd7239532eef4e5d |
+---------------+----------------------------------+
```


To see a list of all your systems:
```
> tapis systems list
+-----------------------------------+-------------------------------------------------+-----------+---------+
| id                                | name                                            | type      | default |
+-----------------------------------+-------------------------------------------------+-----------+---------+
| your_pre_existing_system_1        | My pre-existing system                          | EXECUTION | False   |
| your_pre_existing_system_2        | Another pre-existing system                     | EXECUTION | False   |
+-----------------------------------+-------------------------------------------------+-----------+---------+
```

## Command Help

Please read the [Tapis CLI documentation](https://tapis-cli.readthedocs.io/en/latest/) for more in depth documentation.

Note that all the CLI commands take the '-h' flag to display a short description and the accept parameters for the command.

General Tapis help:
```
> tapis -h
usage: tapis [--version] [-v | -q] [--log-file LOG_FILE] [-h] [--debug]

Tapis CLI: Scripting interface to the Tapis platform. Documentation at https://tapis-cli.rtfd.io/. For support contact "TACC Help" <help@tacc.cloud>

optional arguments:
  --version            show program's version number and exit
  -v, --verbose        Increase verbosity of output. Can be repeated.
  -q, --quiet          Suppress output except warnings and errors.
  --log-file LOG_FILE  Specify a file to log output. Disabled by default.
  -h, --help           Show help message and exit.
  --debug              Show tracebacks on errors.

Commands:
  actors aliases create  Add an Alias for an Actor
  actors aliases delete  Delete an Actor Alias
  actors aliases list  List all Actor Aliases
  actors aliases show  Show details for an Actor Alias
  actors create  Create an Actor
  actors delete  Delete an Actor
```

Help regarding a specific command:
```
> tapis auth show -h
usage: tapis auth show [-h] [-f {json,shell,table,value,yaml}] [-c COLUMN] [--noindent] [--prefix PREFIX] [--max-width <integer>] [--fit-width] [--print-empty]

Show current Tapis authentication configuration

optional arguments:
  -h, --help            show this help message and exit

output formatters:
  output formatter options

  -f {json,shell,table,value,yaml}, --format {json,shell,table,value,yaml}
                        the output format, defaults to table
  -c COLUMN, --column COLUMN
                        specify the column(s) to include, can be repeated to show multiple columns

json formatter:
  --noindent            whether to disable indenting the JSON

shell formatter:
  a format a UNIX shell can parse (variable="value")

  --prefix PREFIX       add a prefix to all variable names

table formatter:
  --max-width <integer>
                        Maximum display width, <1 to disable. You can also use the CLIFF_MAX_TERM_WIDTH environment variable, but the parameter takes precedence.
  --fit-width           Fit the table to the display width. Implied if --max-width greater than 0. Set the environment variable CLIFF_FIT_WIDTH=1 to always enable
  --print-empty         Print empty table if there is no data to show.
```

If you have any additional questions or are having issues, please post it in our [Slack channel](https://app.slack.com/client/T015E2VMTLH/C015RUFEYBH)
