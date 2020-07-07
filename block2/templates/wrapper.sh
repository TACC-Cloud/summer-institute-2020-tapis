#/bin/bash
module load tacc-singularity/3.4.2

singularity run /work/05278/ajamthe/stampede2/public/gateways19-classifier.simg  python /classify_image.py ${imagefile} ${predictions} > predictions.txt