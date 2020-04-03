 
declare -i TARGETS=0
#declare -i TESTED=0
declare -i SEC=0
declare -i MIN=0

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

  echo " Total downtime: " $MIN:$SEC

  if [ $MIN == 3 ] && [ $SEC == 30 ]; then
    echo ""
    echo "   WOW!"
    echo ""
    break
  fi

  sleep 10
  
  SEC=SEC+10
  
  if [ $SEC == 60 ]; then
    SEC=0
    MIN=MIN+1
  fi

done

echo "Sarasa starting ..."
echo ""


