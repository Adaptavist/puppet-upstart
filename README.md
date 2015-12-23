# Upstart Module

## Overview

The **Upstart** module handles the following aspects of configuring
upstart services

* Ironing out differences in RedHat and Debian based systems
* Ensures that service is running and upstart script is created

## Usage

Usage with definer puppet module

```
definer::defs:
  upstart:
    app_username: 'service1_user'
    launch_cmd: '/opt/service1/start.sh'
    start_on: true
    env: 
      SERVICE_1_HOME: '/opt/service1'
    chdir: '/opt/service1'
```

### Prameters
* app_username - Service will be started as app_username user
* launch_cmd   - Command to start the service
* start_on     - Sets start on runlevel, default false will set start on stopped rc RUNLEVEL=[2345]
* env          - Environment variables to be exported, accepts hash
* chdir        - Change directory before starting service, default false

