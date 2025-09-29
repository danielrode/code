#!/usr/bin/env python3
# Author: Daniel Rode
# Name: 5 dice
# Type: Simulator, Math
# Description: Multithreaded simulation that displays the percentage of
#   rolls that 3 came up at least once in each roll
# Version: 1.0.1
# Made: August 31 2015
# Last updated: Dec 24 2017


import random
from multiprocessing import Pool  # threads!


# Variables
threads = 24
rolls_per_thread = 12000
dice = 5


# Functions
def cruncher(rolls_per_thread):
    counter = 0
    for i in range(rolls_per_thread):

        # [1, 1, 1, 3, 2]
        roll = [random.randrange(1, 7) for x in range(dice)]

        if 3 in roll:
            counter += 1
    return counter


# Main
pool = Pool(threads)  # make the Pool of workers
x = [rolls_per_thread for i in range(threads)]
results = pool.map(cruncher, x)  # spin off threads

# Wait for crunching to finish and then cleanup
pool.close()
pool.join()

# Calculate and display results
print(sum(results) / (threads * rolls_per_thread))
