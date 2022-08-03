import mysql.connector
from mysql.connector import Error
import pandas as pd

string = "20:19:47,434 INFO  [org.cesecore.config.ConfigurationHolder] (MSC service thread 1-1) Allow external re-configuration: false\n"
start = 0
end = start

while string[end] != " " :
    end += 1
    
timestamp = string[start:end]
start = end

# space
while string[start] == " " :
    start += 1
    
end = start
while string[end] != " " :
    end += 1
level = string[start:end]

start = end
# space
while string[start] == " " :
    start += 1
    
# Bracketing
end = start
while string[end] != "]" :
    end += 1
event_name = string[start+1:end]

# Bracketing
start = end

while string[start] == "(" :
    start += 1
    
end = start
while string[end] != ")" :
    end += 1
server_port = string[start+3:end]

#Tab
start = end
while string[start] == " " :
    start +=1
end = start
while string[end] != "\n" :
    end += 1
Deskripsi = string[start+2:end]

print((timestamp, level, event_name, server_port, Deskripsi))