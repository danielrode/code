#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# Author: Daniel Rode
# Created:
# Updated: -


"""Brief description of what script does.

More in-depth description of what the script does.
"""


import os
import sys
import subprocess as sp
from pathlib import Path
from concurrent.futures import ProcessPoolExecutor
from concurrent.futures import as_completed

from collections.abc import Iterable


# Constants
SRC = Path(
    "dir",
    "dir",
    "dir",
    "file",
)
DST = Path("./")


# Functions
def print2(*args, **kwargs) -> None:
    print(*args, **kwargs, file=sys.stderr)


def go(func, value):
    executor = ProcessPoolExecutor(max_workers=1)
    worker = executor.submit(func, value)
    executor.shutdown(wait=False)

    return worker


def dispatch(job_list, worker):
    with ProcessPoolExecutor() as executor:
        worker_list = { executor.submit(worker, j): j for j in job_list }
        for future in as_completed(worker_list):
            job = worker_list[future]
            result = future.result()
            yield job, result


def run_iter(cmd: list[str]) -> Iterable:
    """Run system executable; yield its output in real time line-by-line."""

    # Start process
    process = sp.Popen(
        cmd,
        stdout=sp.PIPE,
        stderr=sp.PIPE,
        text=True,
        bufsize=1,  # Line-buffered output
    )

    # Yield process output as lines, as the lines are produced
    for line in process.stdout:
        yield line.rstrip()

    # If process failed, abort
    return_code = process.wait()
    if return_code != 0:
        print2(process.stderr.read(), end='')
        raise sp.CalledProcessError(return_code, cmd)


# Main
def main() -> None:
    # Parse command line arguments
    args = iter(sys.argv[1:])
    pos_args = []
    for a in args:
        if not a.startswith('-'):
            pos_args += [a]
            continue
        match i:
            case '-p' | '--path':
                path = next(args)
            case '-d' | '--do':
                do_the_thing = True
            case _:
                print("error: Invalid flag", a)
                sys.exit(1)

    try:
        main_arg1, main_arg2 = pos_args
    except ValueError:
        print(HELP_TEXT)
        sys.exit(1)

    # Read content from file if path is provided, otherwise, read from stdin
    try:
        path = Path(sys.argv[1])
    except IndexError:
        file_content = sys.stdin.read()
    else:
        with open(path, 'r') as f:
            file_content = f.read()

    # Ensure output directory exists
    DST_DIR.mkdir(parents=True, exist_ok=True)

    # Use concurrency via parallelism to run a task in the background
    worker = go(sum, [1,2,3,4])  # non-blocking
    result = worker.result()  # blocking

    # Use parallel concurrency to run several tasks in the background
    def worker(job):
        return job**3

    jobs = [10,20,30,40]
    for job, result in dispatch(jobs, worker):
        # Results are ordered by which finish first
        print(job, result)

    # Style: Long with blocks (requires Python 3.10+)
    with (
        mock.patch('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa') as a,
        mock.patch('bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb') as b,
        mock.patch('cccccccccccccccccccccccccccccccccccccccccc') as c,
    ):
        # do stuff


if __name__ == '__main__':
    main()


# Drop into interactive session for easier development
# import IPython; IPython.embed()
import code; code.interact(local=locals())



"""
TODO
- task 1
"""
