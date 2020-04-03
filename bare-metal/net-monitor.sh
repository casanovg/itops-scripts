 
declare -i TARGETS=0

INTERNET_TARGET_1="8.8.8.8"
LOCAL_TARGET_1="10.6.17.37"

for TARGET in $INTERNET_TARGET_1 $LOCAL_TARGET_1; do
	TARGETS=TARGETS+1;
done

echo "Targets to test: " $TARGETS
echo ""

declare -i s=0
declare -i m=0

# Check internet
while [ -z "$(ping -c1 -w2 "$INTERNET_TARGET_1" &> /dev/null)" ]; do
#while ! ping -c1 -w2 "$INTERNET_TARGET_1"; do
  echo "down" $m:$s
  sleep 10
  s=s+10
  if [ $s -ge 60 ]; then
    s=0
    m=m+1;
  fi
done

echo "Sarasa starting ..."
echo ""


