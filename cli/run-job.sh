job=$1
run_id=$(az ml job create -f $job --query name -o tsv)

if [[ -z "$run_id" ]]
then
  echo "Job creation failed"
  exit 3
fi

status=$(az ml job show -n $run_id --query status -o tsv)

if [[ -z "$status" ]]
then
  echo "Status query failed"
  exit 4
fi

job_uri=$(az ml job show -n $run_id --query services.Studio.endpoint)

echo $job_uri

running=("Queued" "Preparing" "Finalizing" "Running")
while [[ ${running[*]} =~ $status ]]
do
  echo $status
  echo $job_uri
  status=$(az ml job show -n $run_id --query status -o tsv)
  sleep 8 
done

if [[ $status == "Completed" ]]
then
  echo "Job completed"
  exit 0
elif [[ $status == "Failed" ]]
then
  echo "Job failed"
  exit 1
else
  echo "Job not completed or failed. Status is $status"
  exit 2
fi

echo $job_uri