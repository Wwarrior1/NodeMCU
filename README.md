# NodeMCU
#### *IoT board NodeMCU - university project and examples*

---

*Note: This repository was moved from another version control system*

**Watch our project on [YouTube](https://youtu.be/0UnUoXtbh8c) !**

**Read our [Wiki](https://github.com/Wwarrior1/NodeMCU/wiki) pages to get more information** (shortened version is below).

## In order to run your code on NodeMCU:

* You need to flash the current firmware if you use your NodeMCU for the first time.
  - You can find detailed guidance on this page: https://nodemcu.readthedocs.io/en/master/en/flash/
    + **step1:** Use the site https://nodemcu-build.com/ to get your firmware file, following instructions on that site.
           If you don't know which modules to include in the firmware build, leave the defaults.
           You probably will be sent an email with the notifications on the status of firmware build.
           As the process may take a while, let's proceed to the next step
    + **step2:** Download the Espressif SDK patch from http://bbs.espressif.com/download/file.php?id=1572
    + **step3:** Extract file named 'esp_init_data_default.bin' from the root directory and place it in the
           'firmware_flash' project directory
    + **step4:** Once you have received the firmware download links from step1 by an email,
           you probably need to choose one of two files: one ending with 'integer.bin'
           and the other ending with 'float.bin'. The second one will provide support for floating-point operations,
           while the first will not. If you are usure which one to download, choose the one ending with 'float.bin'
    + **step5:** Copy the .bin firmware file into the 'firmware_flash' project directory.
    + **step6:** You will also need a flashing program that is available on github repository:
           https://github.com/espressif/esptool
           Just download the 'esptool.py' file and copy it into the 'firmware_flash' project directory
    + **step7:** Plug your NodeNCU into the usb port of your computer
    + **step8:** Use the 'NodeMCU_Erase'('.bat') script to erase all memory from your NodeMCU
    + **step9:** Use the 'NodeMCU_Write'('.bat') script to flash your firmware. You will be needed to provide file names
             for the 'esp_init_data_default.bin' file and the firmware file (*-(integer/float).bin)
    + **step10:** IMPORTANT: after the firmware flash is completed, do not unplug or reset the NodeMCU and wait for
             several seconds while the file system on the NodeMCU is being formatted.
            
  - Once your firmware is up and running, use a flash program to upload your code to the NodeMCU.
    One of available tools is ESPlorer, described here: https://nodemcu.readthedocs.io/en/master/en/upload/
  
  - When you are set up, you need to upload the files: 'init.lua' and 'basic_compile.lua' to the NodeMCU
    from the 'Modules\api' project directory. Any program you wish to run, should be named starting with 'main'.
    For example 'main_blink_led.lua', which will be executed at startup of the NodeMCU.
    Ordinary modules should not be named starting with 'main'
