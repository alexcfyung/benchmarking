#!/bin/bash
CURRENT_DIR=`cd $(dirname $0);pwd`
echo "CURRENTDIR: ${CURRENT_DIR}"
NODE_UNDERTEST=$COMPARE_NODE
echo "NODE_UNDERTEST: $NODE_UNDERTEST"
#chmod u+x ${NODE_UNDERTEST}/node
NODE_BASELINE=$BASE_NODE
echo "NODE_BASELINE: $NODE_BASELINE"
#chmod u+x ${NODE_BASELINE}/node
echo "Machine information:"
#numactl --hardware
echo "NODE Build :"
${NODE_UNDERTEST}/node -v
${NODE_UNDERTEST}/node -e "console.log(process.versions)"
echo "Baseline set as :"
${NODE_BASELINE}/node -v
${NODE_BASELINE}/node -e "console.log(process.versions)"
build_fail=0
baseline_fail=0
CURRENT_PATH=${PATH}
echo "using baseline to do npm install."
pushd ${CURRENT_DIR}/nd/acmeair-nodejs
export PATH=${NODE_BASELINE}:${CURRENT_PATH}

npm install
popd
#Driver command for Jmeter
DRIVERCMD=${CURRENT_DIR}/nd/Jmeter/bin/jmeter
LOGS="${CURRENT_DIR}/nd/results/`date +%Y%m%d-%H%M%S`/"
mkdir -p $LOGS
for i in {1..3}
do

#pushd ${CURRENT_DIR}/nd/benchmarking/experimental/benchmarks/acmeair
echo "Running build:"
export PATH=${NODE_UNDERTEST}:${CURRENT_PATH}
./run_acmeair.sh ${CURRENT_DIR}/nd >> ${LOGS}/BUILD-${i}.out 2>&1
throughput_build=`grep "metric throughput" ${LOGS}/BUILD-${i}.out|awk {'print $3'}`
latency_build=`grep "metric latency" ${LOGS}/BUILD-${i}.out|awk {'print $3'}`
if [ "${throughput_build%.*}" -ge 0 ] && [ "${latency_build%.*}" -ge 0 ]; then
	echo "Build generated throughput number of ${throughput_build}"
	build_results="${build_results} ${throughput_build}"
	echo "Build generated latency number of ${latency_build}"
	build_latency="${build_latency} ${latency_build}"
else
	let build_fail=$build_fail+1
	echo "Failed job output:"
	cat  ${LOGS}/BUILD-${i}.out
fi

export PATH=${NODE_BASELINE}:${CURRENT_PATH}
./run_acmeair.sh ${CURRENT_DIR}/nd >> ${LOGS}/BASELINE-${i}.out 2>&1
throughput_baseline=`grep "metric throughput" ${LOGS}/BASELINE-${i}.out|awk {'print $3'}`
latency_baseline=`grep "metric latency" ${LOGS}/BASELINE-${i}.out|awk {'print $3'}`
if [ "${throughput_baseline%.*}" -ge 0 ] && [ "${latency_baseline%.*}" -ge 0 ]; then
	echo "Baseline generated throughput number of ${throughput_baseline}"
	baseline_results="${baseline_results} ${throughput_baseline}"
	echo "Build generated latency number of ${latency_baseline}"
	baseline_latency="${baseline_latency} ${latency_baseline}"
else
	let baseline_fail=$baseline_fail+1
	echo "Failed job output:"
	cat ${LOGS}/BASELINE-${i}.out
fi

#popd
done
total=0
count=0
for result in $build_results
do
total=`echo $total+$result|bc`
let count=count+1
done
build_average=`echo "$total/$count"|bc`
total=0
count=0
for result in $baseline_results
do
total=`echo $total+$result|bc`
let count=count+1
done
baseline_average=`echo "$total/$count"|bc`

#work out percenntage - throughput = higher is better

percentage=`echo "scale=4;($build_average/$baseline_average)*100"|bc`
total=0
count=0
for result in $build_latency
do
total=`echo $total+$result|bc`
let count=count+1
done
build_lat_average=`echo "$total/$count"|bc`
total=0
count=0
for result in $baseline_latency
do
total=`echo $total+$result|bc`
let count=count+1
done
baseline_lat_average=`echo "$total/$count"|bc`

#work out percenntage - throughput = higher is better

percentage_lat=`echo "scale=4;($build_lat_average/$baseline_lat_average)*100"|bc`
echo "RESULTS:" | tee -a results
echo "THROUGHPUT" | tee -a results
echo "BUILD results:" | tee -a results
echo ${build_results}| tee -a results
echo "Average : ${build_average}"| tee -a results
echo "BASELINE results:"| tee -a results
echo ${baseline_results}| tee -a results
echo "Average: ${baseline_average}"| tee -a results
echo "Percentage of build vs baseline - above 100% is good, less than is bad"| tee -a results
echo "Percentage : ${percentage}%"| tee -a results
echo "-------------------------------" | tee -a results
echo "LATENCY" | tee -a results
echo "BUILD results:" | tee -a results
echo ${build_latency}| tee -a results
echo "Average : ${build_lat_average}"| tee -a results
echo "BASELINE results:"| tee -a results
echo ${baseline_latency}| tee -a results
echo "Average: ${baseline_lat_average}"| tee -a results
echo "Percentage of build vs baseline - less than 100% is good, more than is bad"| tee -a results
echo "Percentage : ${percentage_lat}%"| tee -a results

