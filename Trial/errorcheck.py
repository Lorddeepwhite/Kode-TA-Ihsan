dataLog = []
with open('/home/ihsanfr/Downloads/ejbca1.log', 'r') as f:
    data = f.readlines()
for line in data:
    if 'INFO' in line:
        print(line)
        dataLog.append(line)
print(dataLog)