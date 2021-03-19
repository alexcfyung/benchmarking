usage() {
    cat <<END
$0

Acmeair benchmark on z/OS

Syntax:

    $0 [-ic] base_node_path compare_node_path

Compare Acmeair benchmark with different node version

  -i    Install and setup necessary tools like Jmeter driver and acmeair repo, reinstall if existed
  -c    Clean up all setup files and repository

END
    exit 1
}

while getopts "ic" c; do
    case $c in
        i) install=true ;;
        c) cleanup=true ;;
        *) usage ;;
    esac
done

shift $((OPTIND-1))

if [ $install ]; then
    rm -rf ./nd
    mkdir ./nd ./nd/Jmeter ./nd/node_undertest ./nd/node_baseline
    ./setupJmeter.sh
fi

if [ $cleanup ]; then
    rm -rf ./nd
    exit 0
fi

export COLUMNS=1024
ln -sf $1 ./nd/node_baseline
ln -sf $2 ./nd/node_undertest
export BASE_NODE=$PWD/nd/node_baseline/bin
export COMPARE_NODE=$PWD/nd/node_undertest/bin
./run_acmeair_docker.sh
