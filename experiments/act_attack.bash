#!/bin/bash
echo "Start simple_reference experiment"
# Instruction: to run experiment for another senario for example s2, do the following:
#     Replace all "s1" in the commands by "s2"
#     Replace the name "simple_reference" to that of s2, that is, "simple_speaker_listener". 
#     See at the end of this file the names of all scenarios.


echo "Attack action with Laplace noise"
for mean in -3 -2 -1 0.001 0.05 0.1 0.25 0.5 1 2 3
do
   for decay in 3 2 1 0.5 0.25 0.1 0.05 0.001
   do
        filename="_m"$mean"_d"$decay
        echo "python train_action.py --scenario simple_reference --save-dir models/s1/ma_s1_e20/ --exp-name ma_s1_e20_lap$filename --benchmark --act-laplace-mean $mean --act-laplace-decay $decay"
        python train_action.py --scenario simple_reference --save-dir models/s1/ma_s1_e20/ --exp-name ma_s1_e20_lap$filename --benchmark --act-laplace-mean $mean --act-laplace-decay $decay
   done
done

echo "Attack action with uniform noise"
for high in 0.001 0.05 0.1 0.25 0.5 1 2 3
do
    echo "python train_action.py --scenario simple_reference --save-dir models/s1/ma_s1_e20/ --exp-name ma_s1_e20_unif_h$high --benchmark --act-unif-low -$high --act-unif-high $high"
    python train_action.py --scenario simple_reference --save-dir models/s1/ma_s1_e20/ --exp-name ma_s1_e20_unif_h$high --benchmark --act-unif-low -$high --act-unif-high $high
done

echo "Attack action with Gaussian noise"
for mean in -3 -2 -1 0.001 0.05 0.1 0.25 0.5 1 2 3
do
   for std in 3 2 1 0.5 0.25 0.1 0.05 0.001
   do
        filename="_m"$mean"_d"$std
        echo "python train_action.py --scenario simple_reference --save-dir models/s1/ma_s1_e20/ --exp-name ma_s1_e20_gau$filename --benchmark --act-gaus-mean $mean --act-gaus-std $std"
        python train_action.py --scenario simple_reference --save-dir models/s1/ma_s1_e20/ --exp-name ma_s1_e20_gau$filename --benchmark --act-gaus-mean $mean --act-gaus-std $std
   done
done

echo "Attack action with beta noise" 
for a in 0.001 0.05 0.1 0.25 0.5 1 2 3
do
   for b in 3 2 1 0.5 0.25 0.1 0.05 0.001
   do
        filename="_a"$a"_b"$b
        echo "python train_action.py --scenario simple_reference --save-dir models/s1/ma_s1_e20/ --exp-name ma_s1_e20_beta$filename --benchmark --act-beta-a $a --act-beta-b $b"
        python train_action.py --scenario simple_reference --save-dir models/s1/ma_s1_e20/ --exp-name ma_s1_e20_beta$filename --benchmark --act-beta-a $a --act-beta-b $b
   done
done

echo "Attack action with gamma noise"
for shape in 0.001 0.05 0.1 0.25 0.5 1 2 3
do
   for scale in 3 2 1 0.5 0.25 0.1 0.05 0.001
   do
        filename="_s"$shape"_s"$scale
        echo "python train_action.py --scenario simple_reference --save-dir models/s1/ma_s1_e20/ --exp-name ma_s1_e20_gamma$filename --benchmark --act-gamma-shape $shape --act-gamma-scale $scale"
        python train_action.py --scenario simple_reference --save-dir models/s1/ma_s1_e20/ --exp-name ma_s1_e20_gamma$filename --benchmark --act-gamma-shape $shape --act-gamma-scale $scale
   done
done

echo "Attack action with Gumbel noise"
for mode in -3 -2 -1 0.001 0.05 0.1 0.25 0.5 1 2 3
do
   for scale in 3 2 1 0.5 0.25 0.1 0.05 0.001
   do
        filename="_m"$mode"_s"$scale
        echo "python train_action.py --scenario simple_reference --save-dir models/s1/ma_s1_e20/ --exp-name ma_s1_e20_gum$filename --benchmark --act-gumbel-mode $mode --act-gumbel-scale $scale"
        python train_action.py --scenario simple_reference --save-dir models/s1/ma_s1_e20/ --exp-name ma_s1_e20_gum$filename --benchmark --act-gumbel-mode $mode --act-gumbel-scale $scale
   done
done

echo "Attack action with Wald noise"
for mean in 0.001 0.05 0.1 0.25 0.5 1 2 3
do
   for scale in 3 2 1 0.5 0.25 0.1 0.05 0.001
   do
        filename="_m"$mean"_s"$scale
        echo "python train_action.py --scenario simple_reference --save-dir models/s1/ma_s1_e20/ --exp-name ma_s1_e20_wald$filename --benchmark --act-wald-mean $mean --act-wald-scale $scale"
        python train_action.py --scenario simple_reference --save-dir models/s1/ma_s1_e20/ --exp-name ma_s1_e20_wald$filename --benchmark --act-wald-mean $mean --act-wald-scale $scale
   done
done

echo "Attack action with logistic noise"
for mean in -3 -2 -1 0.001 0.05 0.1 0.25 0.5 1 2 3
do
   for scale in 3 2 1 0.5 0.25 0.1 0.05 0.001
   do
        filename="_m"$mean"_s"$scale
        echo "python train_action.py --scenario simple_reference --save-dir models/s1/ma_s1_e20/ --exp-name ma_s1_e20_log$filename --benchmark --act-logistic-mean $mean --act-logistic-scale $scale"
        python train_action.py --scenario simple_reference --save-dir models/s1/ma_s1_e20/ --exp-name ma_s1_e20_log$filename --benchmark --act-logistic-mean $mean --act-logistic-scale $scale
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
