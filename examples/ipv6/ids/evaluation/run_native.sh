#!/bin/bash

if [ -z "$1" -o -z "$2" -o -z "$3" ]; then
    echo "To few arguments"
    echo "Usage: ./run_test.sh 5 simname simulation.csc"
    exit
fi

CURRENT=$(pwd)
COOJA=../../../../tools/cooja/

BORDER_ROUTER=$(find . -name border-router.native)

if [ -z "$BORDER_ROUTER" ]; then
    echo "Couldnt find border-router.native"
    exit
fi

DIR="."
while [ true ]; do
    COOJA=$(find $DIR -name cooja.jar)

    if [ -n "$COOJA" ]; then
        break
    fi
    DIR="$DIR/.."
done

COOJA=$(dirname $COOJA)

SIMULATION=$CURRENT/$3

simname=$2

RUNS=$1

echo "Found cooja.jar in $COOJA"

cd $COOJA
for i in $(seq 1 $RUNS); do
    sed -i "s/<randomseed>[0-9]\+/<randomseed>$RANDOM/" $SIMULATION
    java -mx512m -jar ../dist/cooja.jar -nogui=$SIMULATION > $CURRENT/$simname-$i.coojalog &
    sleep 10
    sudo $CURRENT/$BORDER_ROUTER -a 127.0.0.1 aaaa::1/64 | ts > $CURRENT/$simname-$i.brlog
    wait
    git log --pretty=oneline -n 1 > $CURRENT/$simname-$i.gitlog
    echo >> $CURRENT/$simname-$i.gitlog
    git status >> $CURRENT/$simname-$i.gitlog
    mv COOJA.log $CURRENT/$simname-$i.log
    mv COOJA.testlog $CURRENT/$simname-$i.testlog
done