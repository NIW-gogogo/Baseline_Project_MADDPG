import argparse
import numpy as np
import tensorflow as tf
import time
import pickle
import sys
# Nov 12, 2022

sys.path.append('../')
sys.path.append('../../')
sys.path.append('../../../')

import maddpg.common.tf_util as U
from maddpg.trainer.maddpg import MADDPGAgentTrainer
import tensorflow.contrib.layers as layers
import os

def parse_args():
    parser = argparse.ArgumentParser("Reinforcement Learning experiments for multiagent environments")
    # Environment
    parser.add_argument("--scenario", type=str, default="simple", help="name of the scenario script")
    parser.add_argument("--max-episode-len", type=int, default=25, help="maximum episode length")
    parser.add_argument("--num-episodes", type=int, default=60000, help="number of episodes")
    parser.add_argument("--num-adversaries", type=int, default=0, help="number of adversaries")
    parser.add_argument("--good-policy", type=str, default="maddpg", help="policy for good agents")
    parser.add_argument("--adv-policy", type=str, default="maddpg", help="policy of adversaries")
    # Core training parameters
    parser.add_argument("--lr", type=float, default=1e-2, help="learning rate for Adam optimizer")
    parser.add_argument("--gamma", type=float, default=0.95, help="discount factor")
    parser.add_argument("--batch-size", type=int, default=1024, help="number of episodes to optimize at the same time")
    parser.add_argument("--num-units", type=int, default=64, help="number of units in the mlp")
    # Checkpointing
    parser.add_argument("--exp-name", type=str, default=None, help="name of the experiment")
    parser.add_argument("--save-dir", type=str, default="/tmp/policy/", help="directory in which training state and model should be saved")
    parser.add_argument("--save-rate", type=int, default=1000, help="save model once every time this many episodes are completed")
    parser.add_argument("--load-dir", type=str, default="", help="directory in which training state and model are loaded")
    # Evaluation
    parser.add_argument("--restore", action="store_true", default=False)
    parser.add_argument("--display", action="store_true", default=False)
    parser.add_argument("--benchmark", action="store_true", default=False)
    parser.add_argument("--benchmark-iters", type=int, default=100000, help="number of iterations run for benchmarking")
    parser.add_argument("--benchmark-dir", type=str, default="./benchmark_files/", help="directory where benchmark data is saved")
    parser.add_argument("--plots-dir", type=str, default="./learning_curves/", help="directory where plot data is saved")
    ##### Add different noise for actions
    ## Gaussian
    parser.add_argument("--act-gaus-std", type=float, help="std of Gaussian noise for action")
    parser.add_argument("--act-gaus-mean", type=float, help="mean of Gaussian noise level for action")
    ## Uniform
    parser.add_argument("--act-unif-high", type=float, help="Upper bound of the uniform interval of the noise for action")
    parser.add_argument("--act-unif-low", type=float, help="Lower bound of the uniform interval of the noise for action")
    ## Laplace
    parser.add_argument("--act-laplace-mean", type=float, help="mean of Laplace noise for action")
    parser.add_argument("--act-laplace-decay", type=float, help="decay of Laplace noise for action")
    ## Beta
    parser.add_argument("--act-beta-a", type=float, help="a of beta noise for action")
    parser.add_argument("--act-beta-b", type=float, help="b of beta noise for action")
    ## Gamma
    parser.add_argument("--act-gamma-shape", type=float, help="shape of gamma noise for action")
    parser.add_argument("--act-gamma-scale", type=float, help="scale of gamma noise for action")
    ## Gumbel
    parser.add_argument("--act-gumbel-mode", type=float,help="mode of gumbel noise for action")
    parser.add_argument("--act-gumbel-scale", type=float, help="scale of gumbel noise for action")
    ## Wald
    parser.add_argument("--act-wald-mean", type=float, help="mean of wald noise for action")
    parser.add_argument("--act-wald-scale", type=float, help="scale of wald noise for action")
    ## logistic
    parser.add_argument("--act-logistic-mean", type=float, help="mean of logistic noise for action")
    parser.add_argument("--act-logistic-scale", type=float, help="scale of logistic noise for action")
    
    

    return parser.parse_args()

def mlp_model(input, num_outputs, scope, reuse=False, num_units=64, rnn_cell=None):
    # This model takes as input an observation and returns values of all actions
    with tf.variable_scope(scope, reuse=reuse):
        out = input
        out = layers.fully_connected(out, num_outputs=num_units, activation_fn=tf.nn.relu)
        out = layers.fully_connected(out, num_outputs=num_units, activation_fn=tf.nn.relu)
        out = layers.fully_connected(out, num_outputs=num_outputs, activation_fn=None)
        return out

def make_env(scenario_name, arglist, benchmark=False):
    from multiagent.environment import MultiAgentEnv
    import multiagent.scenarios as scenarios

    # load scenario from script
    scenario = scenarios.load(scenario_name + ".py").Scenario()
    # create world
    world = scenario.make_world()
    # create multiagent environment
    if benchmark:
        env = MultiAgentEnv(world, scenario.reset_world, scenario.reward, scenario.observation, scenario.benchmark_data)
    else:
        env = MultiAgentEnv(world, scenario.reset_world, scenario.reward, scenario.observation)
    return env

def get_trainers(env, num_adversaries, obs_shape_n, arglist):
    trainers = []
    model = mlp_model
    trainer = MADDPGAgentTrainer
    for i in range(num_adversaries):
        trainers.append(trainer(
            "agent_%d" % i, model, obs_shape_n, env.action_space, i, arglist,
            local_q_func=(arglist.adv_policy=='ddpg')))
    for i in range(num_adversaries, env.n):
        trainers.append(trainer(
            "agent_%d" % i, model, obs_shape_n, env.action_space, i, arglist,
            local_q_func=(arglist.good_policy=='ddpg')))
    return trainers


def train(arglist):
    with U.single_threaded_session():
        # Create environment
        env = make_env(arglist.scenario, arglist, arglist.benchmark)
        # Create agent trainers
        obs_shape_n = [env.observation_space[i].shape for i in range(env.n)]
        num_adversaries = min(env.n, arglist.num_adversaries)
        trainers = get_trainers(env, num_adversaries, obs_shape_n, arglist)
        print('Using good policy {} and adv policy {}'.format(arglist.good_policy, arglist.adv_policy))

        # Initialize
        U.initialize()

        # Load previous results, if necessary
        if arglist.load_dir == "":
            arglist.load_dir = arglist.save_dir
        if arglist.display or arglist.restore or arglist.benchmark:
            print('Loading previous state...')
            U.load_state(arglist.load_dir)

        episode_rewards = [0.0]  # sum of rewards for all agents
        agent_rewards = [[0.0] for _ in range(env.n)]  # individual agent reward
        final_ep_rewards = []  # sum of rewards for training curve
        final_ep_ag_rewards = []  # agent rewards for training curve
        agent_info = [[[]]]  # placeholder for benchmarking info
        saver = tf.train.Saver()
        obs_n = env.reset()
        episode_step = 0
        train_step = 0
        t_start = time.time()
        

        print('Starting iterations...')
        
        
        def add_noise(arglist):
            if arglist.act_gaus_mean is not None and arglist.act_gaus_std is not None:
               return np.random.normal, arglist.act_gaus_mean, arglist.act_gaus_std
            if arglist.act_unif_low is not None and arglist.act_unif_high is not None:
               return np.random.uniform, arglist.act_unif_low, arglist.act_unif_high
            if arglist.act_laplace_mean is not None and arglist.act_laplace_decay is not None:
               return np.random.laplace, arglist.act_laplace_mean, arglist.act_laplace_decay
            if arglist.act_beta_a is not None and arglist.act_beta_b is not None:
               return np.random.beta, arglist.act_beta_a, arglist.act_beta_b
            if arglist.act_gamma_shape is not None and arglist.act_gamma_scale is not None:
               return np.random.gamma, arglist.act_gamma_shape, arglist.act_gamma_scale
            if arglist.act_gumbel_mode is not None and arglist.act_gumbel_scale is not None:
               return np.random.gumbel, arglist.act_gumbel_mode, arglist.act_gumbel_scale
            if arglist.act_wald_mean is not None and arglist.act_wald_scale is not None:
               return np.random.wald, arglist.act_wald_mean, arglist.act_wald_scale
            if arglist.act_logistic_mean is not None and arglist.act_logistic_scale is not None:
               return np.random.logistic, arglist.act_logistic_mean, arglist.act_logistic_scale
            
            return None, None, None

        
        while True:
            if train_step%10000 == 0:
                print(train_step)
            # get action
            action_n = [agent.action(obs) for agent, obs in zip(trainers,obs_n)]
            
            # add noise in actions
            noise_fun, noise_par1, noise_par2 = add_noise(arglist)
            if noise_fun is not None and noise_par1 is not None and noise_par2 is not None:
                for i, act in enumerate(action_n):
                    action_n[i] = act + noise_fun(noise_par1, noise_par2, act.shape)
            
            # end of adding noise
            
            new_obs_n, rew_n, done_n, info_n = env.step(action_n)
            
            #if train_step%100 == 0:
            #    print("Actions:",action_n,"New Obs:",new_obs_n, "Rewards:",rew_n)
            episode_step += 1
            done = all(done_n)
            terminal = (episode_step >= arglist.max_episode_len)
            # collect experience
            for i, agent in enumerate(trainers):
                agent.experience(obs_n[i], action_n[i], rew_n[i], new_obs_n[i], done_n[i], terminal)
            obs_n = new_obs_n

            for i, rew in enumerate(rew_n):
                episode_rewards[-1] += rew
                agent_rewards[i][-1] += rew

            if done or terminal:
                obs_n = env.reset()
                episode_step = 0
                episode_rewards.append(0)
                for a in agent_rewards:
                    a.append(0)
                agent_info.append([[]])

            # increment global step counter
            train_step += 1

            # for benchmarking learned policies
            if arglist.benchmark:
                for i, info in enumerate(info_n):
                    agent_info[-1][i].append(info_n['n'])
                if train_step > arglist.benchmark_iters and (done or terminal):
                    file_name = arglist.benchmark_dir + arglist.exp_name + '.pkl'
                    print('Finished benchmarking, now saving...')
                    with open(file_name, 'wb') as fp:
                        pickle.dump(agent_info[:-1], fp)
                    break
                continue

            # for displaying learned policies
            if arglist.display:
                time.sleep(0.1)
                env.render()
                continue

            # update all trainers, if not in display or benchmark mode
            loss = None
            for agent in trainers:
                agent.preupdate()
            for agent in trainers:
                loss = agent.update(trainers, train_step)

            # save model, display training output
            if terminal and (len(episode_rewards) % arglist.save_rate == 0):
                U.save_state(arglist.save_dir, saver=saver)
                # print statement depends on whether or not there are adversaries
                if num_adversaries == 0:
                    print("steps: {}, episodes: {}, mean episode reward: {}, time: {}".format(
                        train_step, len(episode_rewards), np.mean(episode_rewards[-arglist.save_rate:]), round(time.time()-t_start, 3)))
                else:
                    print("steps: {}, episodes: {}, mean episode reward: {}, agent episode reward: {}, time: {}".format(
                        train_step, len(episode_rewards), np.mean(episode_rewards[-arglist.save_rate:]),
                        [np.mean(rew[-arglist.save_rate:]) for rew in agent_rewards], round(time.time()-t_start, 3)))
                t_start = time.time()
                # Keep track of final episode reward
                final_ep_rewards.append(np.mean(episode_rewards[-arglist.save_rate:]))
                for rew in agent_rewards:
                    final_ep_ag_rewards.append(np.mean(rew[-arglist.save_rate:]))

            # saves final episode reward for plotting training curve later
            if len(episode_rewards) > arglist.num_episodes:
                rew_file_name = arglist.plots_dir + arglist.exp_name + '_rewards.pkl'
                with open(rew_file_name, 'wb') as fp:
                    pickle.dump(final_ep_rewards, fp)
                agrew_file_name = arglist.plots_dir + arglist.exp_name + '_agrewards.pkl'
                with open(agrew_file_name, 'wb') as fp:
                    pickle.dump(final_ep_ag_rewards, fp)
                print('...Finished total of {} episodes.'.format(len(episode_rewards)))
                break


if __name__ == '__main__':
    arglist = parse_args()
    train(arglist)