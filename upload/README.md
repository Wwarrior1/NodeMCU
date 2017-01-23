# Usage:
```
py upload.py
```

## Requirements
***luatool.py*** script inside "./lib" in relation to the ***upload.py*** file - available [here](https://github.com/4refr0nt/luatool).

## This tool is for easy uploading predefined list of files from the project to the NodeMCU flash.
You need to specify serial connection parameters, which files to upload
and the root directory where to search for the files to upload.

#### In order to specify which files to upload, you need to provide information in "*.csv" files of three-level tree hierarchy:

1) **Primary file:** general upload configuration file ("config.csv") in root directory
2) **Secondary files:** contain information about which groups of files to upload (eg. "build1.csv")
3) **Ternary files:** contain list of filenames to include in the group of files for upload (eg. commons.csv)
   they must be placed inside the "configs" directory

Except the lowest-level files, all the files specify a file or list of files of the lower level for uploading.

Each file level has it's csv required headers and optional headers. Required headers must be specified
in order for the upload to success. Optional headers specify options for upload of concrete file or groups of files.
The set of optional headers is constant for all file levels and can be overwritten in a specific file,
affecting default upload specifications for all underlying file uploads.

#### Values are inherited by the lower-level configuration files if you do not override them or their value in the csv file is equal to "", e.g.:
    Primary file contains:
        key1,key2
        value1,value2
    Secondary file contains:
        key1,key2
        value_1_override
    Then all uploads executed under the Secondary file will have:
        - "key1" value set to "value_1_override"
        - "key2" value set to "value2" - the value is inherited from the higher-level file

#### Global optional headers:
```
compile (boolean) -------------(default=false)  compile files after upload
restart (boolean) -------------(default=false)  restart NodeMCU after file upload
dofile (boolean) --------------(default=false)  execute file after upload
verbose (boolean) -------------(default=false)  print details of progress to stdout and stderr
wipe (boolean) ----------------(default=false)  delete all files before upload of each file (ATTENTION! makes sense when uploading only one file: before each file upload, all previous are deleted)
echo (boolean) ----------------(default=false)  print NodeMCU echo feedback (makes sense with verbose=true)
delay (float) -----------------(default=0.005)  delay in seconds between serial writes - default value is the minimal acceptable
source_files_basedir (string) -(default="..")   root directory where to look for the source files to upload to NodeMCU
baud_rate (int) ---------------(default=115200) baud rate rof the serial interface connection
port (string) -----------------(default="COM4") port name for the serial interface connection
```

#### Required headers:
- **Primary file:**
    *files_upload_config_file* (string)
    - name of secondary file with further upload specification
- **Secondary files:**
    *upload_spec_file* (string)
    - name of ternary file inside "configs" directory containing list of files and options for upload
- **Ternary files:**
    *file* (string)
    - name of source file to upload

#### Example contents of files:

* file ***config.csv*** - primary file:
    ```
    source_files_basedir,files_upload_config_file,port,baud_rate,compile,restart,dofile,verbose,wipe,echo,delay
    ..,build1.csv,COM4,115200
    ```
* file ***build1.csv*** - secondary file:
    ```
    upload_spec_file,compile,restart,dofile,verbose,wipe,echo,delay,source_files_basedir
    mqttclient_nokia.csv
    mqttclient_custom.csv
    ```
* file ***configs/mqttclient_nokia.csv*** - ternary file:
    ```
    file,compile,restart,dofile
    basic.lua,true,,true
    main_mqttclient.lua
    ```
* file ***configs/mqttclient_custom.csv*** - ternary file:
    ```
    file,compile,restart,dofile
    sonic_sensor.lua
    main_oled.lua
    ```