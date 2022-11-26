#!/bin/bash
echo "Start simple_reference experiment"

echo "Attack state with Laplace noise"
for mean in -3 -2 -1 0.001 0.05 0.1 0.25 0.5 1 2 3
do
   for decay in 3 2 1 0.5 0.25 0.1 0.05 0.001
   do
        filename="_m"$mean"_d"$decay
        echo "python train.py --scenario simple_reference --save-dir models/s1/ma_s1_e20/ --exp-name ma_s1_e20_lap$filename --benchmark --obs-laplace-mean $mean --obs-laplace-decay $decay"
        python train.py --scenario simple_reference --save-dir models/s1/ma_s1_e20/ --exp-name ma_s1_e20_lap$filename --benchmark --obs-laplace-mean $mean --obs-laplace-decay $decay
   done
done

echo "Attack state with uniform noise"
for high in 0.001 0.05 0.1 0.25 0.5 1 2 3
do
    echo "python train.py --scenario simple_reference --save-dir models/s1/ma_s1_e20/ --exp-name ma_s1_e20_unif_h$high --benchmark --obs-unif-low -$high --obs-unif-high $high"
    python train.py --scenario simple_reference --save-dir models/s1/ma_s1_e20/ --exp-name ma_s1_e20_unif_h$high --benchmark --obs-unif-low -$high --obs-unif-high $high
done

echo "Attack state with Gaussian noise"
for mean in -3 -2 -1 0.001 0.05 0.1 0.25 0.5 1 2 3
do
   for std in 3 2 1 0.5 0.25 0.1 0.05 0.001
   do
        filename="_m"$mean"_d"$std
        echo "python train.py --scenario simple_reference --save-dir models/s1/ma_s1_e20/ --exp-name ma_s1_e20_gau$filename --benchmark --obs-gaus-mean $mean --obs-gaus-std $std"
        python train.py --scenario simple_reference --save-dir models/s1/ma_s1_e20/ --exp-name ma_s1_e20_gau$filename --benchmark --obs-gaus-mean $mean --obs-gaus-std $std
   done
done

echo "Attack state with beta noise" 
for a in 0.001 0.05 0.1 0.25 0.5 1 2 3
do
   for b in 3 2 1 0.5 0.25 0.1 0.05 0.001
   do
        filename="_a"$a"_b"$b
        echo "python train.py --scenario simple_reference --save-dir models/s1/ma_s1_e20/ --exp-name ma_s1_e20_beta$filename --benchmark --obs-beta-a $a --obs-beta-b $b"
        python train.py --scenario simple_reference --save-dir models/s1/ma_s1_e20/ --exp-name ma_s1_e20_beta$filename --benchmark --obs-beta-a $a --obs-beta-b $b
   done
done

echo "Attack state with gamma noise"
for shape in 0.001 0.05 0.1 0.25 0.5 1 2 3
do
   for scale in 3 2 1 0.5 0.25 0.1 0.05 0.001
   do
        filename="_s"$shape"_s"$scale
        echo "python train.py --scenario simple_reference --save-dir models/s1/ma_s1_e20/ --exp-name ma_s1_e20_gamma$filename --benchmark --obs-gamma-shape $shape --obs-gamma-scale $scale"
        python train.py --scenario simple_reference --save-dir models/s1/ma_s1_e20/ --exp-name ma_s1_e20_gamma$filename --benchmark --obs-gamma-shape $shape --obs-gamma-scale $scale
   done
done

echo "Attack state with Gumbel noise"
for mode in -3 -2 -1 0.001 0.05 0.1 0.25 0.5 1 2 3
do
   for scale in 3 2 1 0.5 0.25 0.1 0.05 0.001
   do
        filename="_m"$mode"_s"$scale
        echo "python train.py --scenario simple_reference --save-dir models/s1/ma_s1_e20/ --exp-name ma_s1_e20_gum$filename --benchmark --obs-gumbel-mode $mode --obs-gumbel-scale $scale"
        python train.py --scenario simple_reference --save-dir models/s1/ma_s1_e20/ --exp-name ma_s1_e20_gum$filename --benchmark --obs-gumbel-mode $mode --obs-gumbel-scale $scale
   done
done

echo "Attack state with Wald noise"
for mean in 0.001 0.05 0.1 0.25 0.5 1 2 3
do
   for scale in 3 2 1 0.5 0.25 0.1 0.05 0.001
   do
        filename="_m"$mean"_s"$scale
        echo "python train.py --scenario simple_reference --save-dir models/s1/ma_s1_e20/ --exp-name ma_s1_e20_wald$filename --benchmark --obs-wald-mean $mean --obs-wald-scale $scale"
        python train.py --scenario simple_reference --save-dir models/s1/ma_s1_e20/ --exp-name ma_s1_e20_wald$filename --benchmark --obs-wald-mean $mean --obs-wald-scale $scale
   done
done

echo "Attack state with logistic noise"
for mean in -3 -2 -1 0.001 0.05 0.1 0.25 0.5 1 2 3
do
   for scale in 3 2 1 0.5 0.25 0.1 0.05 0.001
   do
        filename="_m"$mean"_s"$scale
        echo "python train.py --scenario simple_reference --save-dir models/s1/ma_s1_e20/ --exp-name ma_s1_e20_log$filename --benchmark --obs-logistic-mean $mean --obs-logistic-scale $scale"
        python train.py --scenario simple_reference --save-dir models/s1/ma_s1_e20/ --exp-name ma_s1_e20_log$filename --benchmark --obs-logistic-mean $mean --obs-logistic-scale $scale
   done
done

#python train.py --scenario simple_reference --save-dir models/s1/ma_s1_e20/ --exp-name ma_s1_e20_batch --benchmark

#python train.py --scenario simple_speaker_listener --save-dir models/s2/ma_s2_e20/ --exp-name ma_s2_e20_batch  --benchmark

#python train.py --scenario simple_spread --save-dir models/s3/ma_s3_e20/ --exp-name ma_s3_e20_batch --benchmark

#python train.py --scenario simple_adversary --save-dir models/s4/ma_s4_e20/ --exp-name ma_s4_e20_batch --benchmark

#python train.py --scenario simple_crypto --save-dir models/s5/ma_s5_e20/ --exp-name ma_s5_e20_batch --benchmark

#python train.py --scenario simple_push --save-dir models/s6/ma_s6_e20/ --exp-name ma_s6_e20_batch --benchmark

#python train.py --scenario simple_tag --save-dir models/s7/ma_s7_e20/ --exp-name ma_s7_e20_batch --benchmark

#python train.py --scenario simple_world_comm --save-dir models/s8/ma_s8_e20/ --exp-name ma_s8_e20_batch --benchmark
