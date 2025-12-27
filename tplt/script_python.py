#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# author: Daniel Rode
# name:
# tags:
# dependencies:
#   python 3.10+
#   dep2
#   dep3
#   ...
# version: 1
# created:
# updated: -


"""Brief description of what script does.

More in-depth description of what the script does.
"""


import os
import sys
import subprocess as sp
from pathlib import Path

from collections.abc import Iterable

import dbus


# Constants
PROGRAM_NAME = "[Unique Name of Program]"
EXE_NAME = Path(sys.argv[0]).name  # This script's filename
HELP_TEXT = f"Usage: {EXE_NAME} [OPTION]... ARG"
DST = Path(
    "dir",
    "dir",
    "dir",
    "file",
)

# Variables: XDG Base Directory (user data paths)
if 'XDG_CONFIG_HOME' in os.environ:
    XDG_CONFIG_HOME = Path(os.environ['XDG_CONFIG_HOME'])
else:
    XDG_CONFIG_HOME = Path.home() / '.config'
CONFIG_HOME = XDG_CONFIG_HOME / 'daniel_rode_code' / PROGRAM_NAME
CONFIG_HOME.mkdir(parents=True, exist_ok=True)

if 'XDG_CACHE_HOME' in os.environ:
    XDG_CACHE_HOME = Path(os.environ['XDG_CACHE_HOME'])
else:
    XDG_CACHE_HOME = Path.home() / '.cache'
CACHE_HOME = XDG_CACHE_HOME / 'daniel_rode_code' / PROGRAM_NAME
CACHE_HOME.mkdir(parents=True, exist_ok=True)

if 'XDG_DATA_HOME' in os.environ:
    XDG_DATA_HOME = Path(os.environ['XDG_DATA_HOME'])
else:
    XDG_DATA_HOME = Path.home() / '.local/share'
DATA_HOME = XDG_DATA_HOME / 'daniel_rode_code' / PROGRAM_NAME
DATA_HOME.mkdir(parents=True, exist_ok=True)


# Functions
def print2(*args, **kwargs) -> None:
    print(*args, **kwargs, file=sys.stderr)

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

def notify_send(title, body='', app_name='', icon='', timeout_ms=0) -> int:
    """Send desktop notification via D-Bus."""

    # Create connection to the D-Bus system bus
    bus = dbus.SessionBus()

    # Get the org.freedesktop.Notifications interface
    bus_name = 'org.freedesktop.Notifications'
    notification_service = bus.get_object(
        bus_name,
        '/org/freedesktop/Notifications',
    )
    notifications = dbus.Interface(notification_service, bus_name)

    # Send notification
    notification_id = notifications.Notify(
        app_name, 0, icon, title, body, [], {}, timeout_ms,
    )

    return notification_id


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
    from concurrent.futures import ProcessPoolExecutor

    def go(func, value):
        executor = ProcessPoolExecutor(max_workers=1)
        worker = executor.submit(func, value)
        executor.shutdown(wait=False)

        return worker

    worker = go(sum, [1,2,3,4])  # non-blocking
    result = worker.result()  # blocking

    # Use concurrency to run several tasks in parallel in the background
    import os
    from concurrent.futures import ProcessPoolExecutor
    from concurrent.futures import as_completed
    from collections.abc import Iterator
    from collections.abc import Callable
    from typing import Any

    def dispatch(
        jobs: iter, worker: Callable, max_workers=os.cpu_count(),
    ) -> Iterator[(Any, Any)]:
        """Run jobs in parallel.

        Parallel apply dispatching function: Run a list of jobs with a given
        worker function, in parallel. Yield worker results in order they
        finish.
        """

        with ProcessPoolExecutor(max_workers=max_workers) as executor:
            futures_jobs = {executor.submit(worker, j): j for j in jobs}
            for f in as_completed(futures_jobs):
                yield (futures_jobs[f], f.result())

    def worker(job):
        return job**3

    jobs = [10,20,30,40]
    for job, result in dispatch(jobs, worker):
        # Results are ordered by which finish first
        print(job, result)

    # Style: Chain method calls
    result = (
        function
        .method(something)
        .method2(another_thing)
        .last_method()
    )

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
import IPython; IPython.embed()
# OR
import code; code.interact(local=locals())



"""
TODO
- task 1
- task 2
- ...
"""
