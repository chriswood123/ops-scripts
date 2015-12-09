# Get the number of days to keep from the 1st arg
# or print usage if no args present
if [ $1 ]; then
  daystokeep=$1
else
  echo "Usage ${0} <Number of days indices to keep>"
  exit 1
fi

# Get a list of all logstash indices
indices=$(curl -s http://localhost/_cat/indices | grep logstash | awk '{ print $2 }')
# Get seconds since epoch for $daystokeep days ago
oldunixtime=$(date --date "${daystokeep} days ago" +%s)

# Loop through the list of indices
# Check to see if the index date is older than $daystokeep
# and delete the index if it is
for index in $indices; do
  # Grab date string
  datestr=$(echo $index | cut -f2 -d'-' | sed s/\\./-/g)
  # Convert to seconds since epoch
  unixtime=$(date --date $datestr +%s)
  if [ $unixtime -lt $oldunixtime ]; then
    echo "Deleting index: ${index}"
    curl -XDELETE "http://localhost:9200/${index}"
  fi
done
