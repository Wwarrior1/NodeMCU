#!/usr/bin/env bash

./LuaSrcDiet-0.12.1/bin/LuaSrcDiet.lua --opt-srcequiv Projects/main_mqtt_client_oled.lua -o minimized/main_mqtt_client_oled.lua
./LuaSrcDiet-0.12.1/bin/LuaSrcDiet.lua --opt-srcequiv Projects/main_mqtt_client_temp.lua -o minimized/main_mqtt_client_temp.lua

./LuaSrcDiet-0.12.1/bin/LuaSrcDiet.lua --opt-srcequiv Projects/main_mqtt_client_oled_1.lua -o minimized/main_mqtt_client_oled_1.lua
./LuaSrcDiet-0.12.1/bin/LuaSrcDiet.lua --opt-srcequiv Projects/main_mqtt_client_oled_2.lua -o minimized/main_mqtt_client_oled_2.lua

./LuaSrcDiet-0.12.1/bin/LuaSrcDiet.lua --maximum --opt-srcequiv Modules/api/init.lua -o minimized/init.lua
./LuaSrcDiet-0.12.1/bin/LuaSrcDiet.lua --maximum --opt-srcequiv Modules/debouncer.lua -o minimized/debouncer.lua
./LuaSrcDiet-0.12.1/bin/LuaSrcDiet.lua --maximum --opt-srcequiv Modules/api/wifi_status.lua -o minimized/wifi_status.lua
./LuaSrcDiet-0.12.1/bin/LuaSrcDiet.lua --maximum --opt-srcequiv Modules/api/basic_files_tool.lua -o minimized/basic_files_tool.lua

./LuaSrcDiet-0.12.1/bin/LuaSrcDiet.lua --maximum --opt-srcequiv Modules/LED_RGB/led_rgb.lua -o minimized/led_rgb.lua
./LuaSrcDiet-0.12.1/bin/LuaSrcDiet.lua --maximum --opt-srcequiv Modules/sensor_light/sensor_light.lua -o minimized/sensor_light.lua
./LuaSrcDiet-0.12.1/bin/LuaSrcDiet.lua --maximum --opt-srcequiv Modules/sensor_temp_DS18B20/sensor_temp.lua -o minimized/sensor_temp.lua
./LuaSrcDiet-0.12.1/bin/LuaSrcDiet.lua --opt-srcequiv Modules/OLED/SSD1306.lua -o minimized/SSD1306.lua

./LuaSrcDiet-0.12.1/bin/LuaSrcDiet.lua --maximum --opt-srcequiv Modules/api/mqtt_reasons.lua -o minimized/mqtt_reasons.lua
./LuaSrcDiet-0.12.1/bin/LuaSrcDiet.lua --maximum --opt-srcequiv wifi_credentials.lua -o minimized/wifi_credentials.lua