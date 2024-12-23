# hisdeploy

The new deployment project for the Paraguayan HIS (Health Information System)

- [hisdeploy](#hisdeploy)
  - [Semi automatic setup](#semi-automatic-setup)
    - [1. Update HIS](#1-update-his)
    - [2. Build and deploy the war file on a local machine (e.g. your own computer)](#2-build-and-deploy-the-war-file-on-a-local-machine-eg-your-own-computer)
      - [AMBULATORIA](#ambulatoria)
  - [CI/CD Deployment Guide](#cicd-deployment-guide)
    - [Pre-configuration](#pre-configuration)
    - [Add new deploydeployment target](#add-new-deploydeployment-target)

## Semi automatic setup

### 1. Update HIS
- Confirm the variables in **.his.prod.env**
- Use the following script to setup the docker containers on the remote server (e.g., testing server, training server, guaira server, etc.)
```bash
$ bash shells/gen_configs.sh
$ docker compose build
$ docker compose pull
$ docker compose up -d
```

### 2. Build and deploy the war file on a local machine (e.g. your own computer)

1. Build the war file on the local machine
2. Deploy the war through tomcat manager
3. Post-deploy process
   - Update the remote static files for the nginx
   - Run the flyway migration on the remote machine

```bash
# AMBULATORIA

## 1. Build the war file
## Ensure the java version 8 is used, 
## e.g., sdk use java 8.0.382-tem
$ ./gradlew war

## 2. Deploy the war file via tomcat manager
$ curl -T "./build/libs/his.war" "https://{user}:{pass}@{remote_domain}/outhis-manager/text/deploy?path=/ambulatoria&update=true" -v

## 3. Update the remote static files and flyway version
$ ssh -t {remote_domain/remote_vpn_ip} 'cd {something}/hisdeploy; bash shells/update_outhis_assets.sh .; bash shells/migratedb.sh outhis migrate;'


# INTERNACION

## 1. Build the war file
$ ./gradlew buildhis # for the production.2.7.x branch
$ bash shells/build.sh cmd # for the master branch

## 2. Deploy the war file via tomcat manager
$ curl -T "./build/libs/internacion.war" "https://{user}:{pass}@{remote_domain}/interhis-manager/text/deploy?path=/internacion&update=true" -v

## 3. Update the remote static files and flyway version
$ ssh -t {remote_domain/remote_vpn_ip} 'cd {something}/hisdeploy; bash shells/update_interhis_assets.sh .; bash shells/migratedb.sh interhis migrate;'
```

#### AMBULATORIA

1. Build the war file on the local machine
2. Deploy the war through tomcat manager
3. Update the remote static files for the nginx
4. Run the flyway migration on the remote machine

```bash
```

## CI/CD Deployment Guide

### Pre-configuration

(One-time operation)

hispy (his_internacion) > Settings > CI/CD: [hispy](https://gitlab.com/hispydevelopteam/hispy/-/settings/ci_cd) / [his_internacion](https://gitlab.com/hispydevelopteam/his_internacion/-/settings/ci_cd)

1. Switch-off (disable) "Shared runners"
    ![](https://hackmd.io/_uploads/Hk0Kyf-S2.png)

2. Register our GitLab runner
    
    On `hisicdf@192.168.1.110`
    
    Run `sudo gitlab-runner register` and follow its steps.
    ref. https://docs.gitlab.com/runner/register/

2. Add `SSH_PRIVATE_KEY` to the "Variables" section
    ![](https://hackmd.io/_uploads/ryNWkMWS2.png)


### Add new deploydeployment target

1. Select a linux user to act as the deployer. GitLab pipeline will use this user to establish an SSH connection with the server.
    - All the files under `hisdeploy` should have owner like `<deployer>:deploy`


2. Append the SSH key (see `hisdeploy/key/deploy.key.pub`) to the `~/.ssh/authorized_keys` file.
    > Here for example, if the deployer is `ideploy`, then
    ```bash
    $ echo '<CONTENT OF deploy.key.pub>' >> /home/ideploy/.ssh/authorized_keys
    ```
3. Complete the `hispy/gitlab-ci/servers_info.csv` file.

4. Run the `hispy/gitlab-ci/gen-ci-yaml.py` script to regerate the `.gitlab-ci.yml` file and push to GitLab.


## Diploy ELK client to VM

### ENV check
    
    make sure VM can connect to 192.168.101.11

### Install elastic agent

1. add agent policies (optional)(https://192.168.101.11:5601/app/fleet/policies)
2. add agent select policies, choose [Enroll in Fleet (recommended)], copy command and run it (https://192.168.101.11:5601/app/fleet/agents)

### Postgresql user Setting 
Setting user and password in 
Agent policies -> your policy -> postgresql -> Collect PostgreSQL metrics -> Settings -> username and password

