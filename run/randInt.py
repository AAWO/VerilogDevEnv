from sys import argv, stdout
from random import randint

if len(argv) == 3:
   stdout.write(str(randint(int(argv[1]), int(argv[2]))))
elif len(argv) == 4:
   stdout.write(str(randint(int(argv[1]), int(argv[2]), int(argv[3]))))
else:
   argv_num = (len(argv)-1)
   raise TypeError("Wrong number of arguments. Expected 2 or 3 - received %d" % argv_num)
