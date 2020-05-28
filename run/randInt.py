# Author    : Andrzej Wojciechowski (AAWO)
# Copyright : Andrzej Wojciechowski (AAWO)
# --------------------------------------------
from sys import argv, stdout
from random import randrange

if len(argv) == 3:
   stdout.write(str(randrange(int(argv[1]), int(argv[2])+1)))
elif len(argv) == 4:
   stdout.write(str(randrange(int(argv[1]), int(argv[2])+1, int(argv[3]))))
else:
   argv_num = (len(argv)-1)
   raise TypeError("Wrong number of arguments. Expected 2 or 3 - received %d" % argv_num)
