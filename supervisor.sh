#!/bin/sh

if [ $# -eq 0 ]; then
    echo "No arguments supplied!"
    echo "Usage: $0 process1 process2 ..."
    exit 1
fi

# Shutdown of the process group
trap shutdown TERM INT
shutdown() {
    trap - TERM # Avoid recursive traps
    kill 0
    exit
}

# Supervise process
run_and_wait() {
    while true ; do
        if "$@" ; then
            echo "'$@' terminated normally, restarting"
        else
            echo "oops '$@' died again with code $?, restarting"
        fi
        sleep 1
    done
}

# Run the process on the argument
for arg in "$@"; do
    printf 'RUN "%s"\n' "$arg"
    run_and_wait $arg &
done

# Periodically check zombie
while true ; do
    sleep 60 &
    wait $!
    ps -A -ostat,ppid | grep -e '[zZ]' | awk '{ print $2 }' | xargs -r kill -9
done
