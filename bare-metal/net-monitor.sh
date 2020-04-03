 
declare -i TARGETS=0
#declare -i TESTED=0
declare -i SECONDS=0
declare -i MINUTES=0

INTERNET_TARGET_1="10.6.17.36"
LOCAL_TARGET_1="10.6.17.1"
LOCAL_TARGET_2="10.6.17.41"

for TGT in $INTERNET_TARGET_1 $LOCAL_TARGET_1 $LOCAL_TARGET_2; do
	TARGETS=TARGETS+1
	echo " Target $TARGETS -->" $TGT
done

echo "Targets to test: $TARGETS"
echo ""


# Check internet
while ! ping -c1 -w2 "$INTERNET_TARGET_1" &> /dev/null; do
#while ! ping -c1 -w2 "$INTERNET_TARGET_1" &> /dev/null; do
  echo "down" $MINUTES:$SECONDS
  sleep 10
  SECONDS=SECONDS+10
  if test $SECONDS -ge 60; then
    SECONDS=0
    MINUTES=MINUTES+1
  fi
done

echo "Sarasa starting ..."
echo ""


