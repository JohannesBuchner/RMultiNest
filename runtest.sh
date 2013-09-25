
cat > test.r << EOF
prior <- function(cube) cube

log_likelihood <- function(params) {
print (params);
0
}
EOF

echo source test.r > conf.rs

mkdir chains

{
echo 'library(Rserve)'
echo 'Rserve(args=c("--RS-conf", "conf.rs", "--no-save"))'
} | R --no-save &
RPID=$!

sleep 0.1
echo "R started."
sleep 1

echo "Starting RMultiNest run"
./rbridge || exit 1

pgrep -f Rserve|xargs -rt kill

test -e "chains/rbridge-summary.txt"
r=$?

[ $r = 0 ] && echo "TEST SUCCESSFUL" || echo "TEST FAILED. see log above"

exit $?


