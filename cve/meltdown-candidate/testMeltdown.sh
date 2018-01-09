cd Am-I-affected-by-Meltdown
sudo sh -c "echo 0  > /proc/sys/kernel/kptr_restrict"
./meltdown-checker
