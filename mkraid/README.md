## Find the disks to create RAID0
```
wget -q https://raw.githubusercontent.com/prasannakdev0/dev-scripts/refs/heads/main/mkraid/1__find_disks.sh -O - | bash
```

## Create RAID0
```
wget -q https://raw.githubusercontent.com/prasannakdev0/dev-scripts/refs/heads/main/mkraid/2__mkraid.sh -O - | bash
```

## Benchmark IOPS
```
wget -q https://raw.githubusercontent.com/prasannakdev0/dev-scripts/refs/heads/main/mkraid/3__benchmark.sh -O - | bash
```