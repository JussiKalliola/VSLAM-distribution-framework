#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Module Description:
    This module provides a basic template for a Python script with a main function.

Author:
    Your Name (your.email@example.com)

Date:
    Date when this script was created or last modified.

Usage:
    How to run this script or example commands.
"""
# Import required modules
import sys
import argparse
import math as mt
import numpy as np

import matplotlib
matplotlib.use( 'TKAgg' )
import matplotlib.pyplot as plt

import pandas as pd
import os

def read_data_from_path(data_path, header=None):
  if os.path.exists(data_path):
    if header is not None:
      df = pd.read_csv(data_path, names=header, skiprows=[0])
      return df
    else:
      df = pd.read_csv(data_path, header=[0])
      return df

  return None

def get_files_from_path(data_path):
  if os.path.exists(data_path):
    return os.listdir(data_path)

  return []

def get_times(df, start_time=0, last_time=0):

  times=[]

  df_np = df.to_numpy()
  if len(df_np) > 0:
    last_time_i = df_np[-1,0] #.astype(int)
    start_time_i = df_np[0,0] #.astype(int)
    if last_time_i > last_time and last_time_i > 0 and last_time_i < 500:
      last_time=last_time_i

    if start_time_i < start_time and start_time_i > 0:
      start_time=start_time_i

    starting_times=df.loc[:,["Start"]].to_numpy().flatten() #.astype(int)
    total_times = df.loc[:,["Total"]].to_numpy().flatten() / 1000 #.astype(int) / 1000

    for i in range(len(starting_times)):
      if starting_times[i] < 0 or starting_times[i] > 500:
        continue
      elif total_times[i] < 0 or total_times[i] > 3:
        continue
      #elif total_times[i] <= 3:
      #  times.append((starting_times[i], 1))
      else:
        times.append((starting_times[i], total_times[i]))

  return times, start_time, last_time

def read_data(data_path):

  df_dict={"kf_pub": [],
           "kf_sub": [],
           "kf_lat": [],
           "map_pub": [],
           "map_sub": [],
           "map_lat": [],
           "atlas_pub": [],
           "atlas_sub": [],
           "atlas_lat": [],
           "lm": [],
           "lba": [],
           "track": [],
           "pr": [],
           "merge": [],
           "loop": [],
           "gba": [],
           "tr": [],
           "tr_all": [],
           "cpu": [],
           "lt": []}

  system_labels=["TR", "LM", "LC"]

  for label in system_labels:

    filenames = get_files_from_path(f'{data_path}/{label}/')
    #print(f'{data_path}/{label}/')
    #print(filenames)

    for fn in filenames:
      #if ".DS" in fn:
      #  continue
      if ".txt" in fn and fn[0] != ".":
        print(f'{data_path}/{label}/{fn}')
        df = read_data_from_path(f'{data_path}/{label}/{fn}')
      else:
        continue

      if df is None:
        continue

      # ROS
      #['Time from start [ms]' ' KF Conversion[ms]' ' KeyFrame PreSave[ms]'' MPs PreSave[ms]' ' Total[ms]']
      if "KeyFramePublishTime" in fn:
        df.columns = ["Start", "KF Conv.", "KF PreSave", "MPs PreSave", "Total"]
        df_dict["kf_pub"].append(df)
        #['Time from start [ms]' ' KF Conversion[ms]' ' Prep data[ms]' ' MPs Conversion[ms]' ' KF PostLoad[ms]'
        # ' MPs PostLoad[ms]' ' KF Injection[ms]' ' MPs Injection[ms]' ' Total[ms]' ' #KFs' ' #MPs' ' #New MPs' ' #Update MPs']
      elif "KeyFrameSubscribeTime" in fn:
        df.columns = ["Start", "KF Conv.", "Prep. Data", "MPs Conv.", "KF PostLoad", "MPs PostLoad", "KF Injection", "MPs Injection", "Total", "#KFs", "#MPs", "#New MPs", "#Update MPs"]
        df_dict["kf_sub"].append(df)
        #['Latency[ms]']
      elif "KeyFrameLatencyTime" in fn:
        df.columns = ["Latency[ms]"]
        df_dict["kf_lat"].append(df)
        #['Time from start [ms]' ' Conversion(KF+MPs)[ms]' ' Presave[ms]' ' Total[ms]']
      elif "MapPublishTime" in fn:
        df.columns=["Start", "KFs+MPs Conv.", "PreSave", "Total"]
        df_dict["map_pub"].append(df)
        #['Time from start [ms]' ' #MPs PostLoad[ms]' ' KFs PostLoad[ms]'
        #' KFs Conversion[ms]' ' MPs Conversion[ms]' ' KFs+MPs Conversion[ms]'
        #' MPs Injection[ms]' ' KFs Injection[ms]' ' Map Conversion[ms]'
        #' Total[ms]' ' #MPs/msg' '  #KFs/msg' ' #MPs Total' ' #KFs Total']
      elif "MapSubscribeTime" in fn:
        df.columns=["Start", "MPs PL", "KFs PL", "KFs Conv.", "MPs Conv.", "KFs+MPs Conv.", "MPs Injection", "KFs Injection", "Map conv.", "Total", "#MPs", "#KFs", "#MPs Total", "#KFs Total"]
        df_dict["map_sub"].append(df)
        #['Latency[ms]']
      elif "MapLatencyTime" in fn:
        df.columns = ["Latency[ms]"]
        df_dict["map_lat"].append(df)
        #['Time from start [ms]' ' Conversion(KF+MPs)[ms]' ' Presave[ms]' ' Total[ms]']
      elif "AtlasPublishTime" in fn:
        df.columns=["Start", "KFs+MPs Conv.", "PreSave", "Total"]
        df_dict["atlas_pub"].append(df)
        #['Time from start [ms]' ' #MPs PostLoad[ms]' ' KFs PostLoad[ms]'
        #' KFs+MPs Conversion[ms]' ' MPs Injection[ms]' ' KFs Injection[ms]'
        #' Map Conversion[ms]' ' Total[ms]']
      elif "AtlasSubscribeTime" in fn:
        df.columns=["Start", "MPs PL", "KFs PL", "KFs+MPs Conv.", "MPs Injection", "KFs Injection", "Map conv.", "Total"]
        df_dict["atlas_sub"].append(df)
        #['Latency[ms]']
      elif "AtlasLatencyTime" in fn:
        df.columns = ["Latency[ms]"]
        df_dict["atlas_lat"].append(df)


      # SLAM
        #['Time from start [ms]' ' ORB Extract[ms]' ' Pose Pred[ms]'
        #' LM Track[ms]' ' New KF[ms]' ' Total[ms]']
      elif "TrackingOverallStats" in fn:
        df.columns=["Total"]
        df_dict["tr_all"].append(df)
      elif "TrackingStats" in fn:
        df.columns=["Start", "ORB Ext.", "Pose Pred.", "LM Track.", "New KF", "Total"]
        df_dict["tr"].append(df)
        #['#Start time[ms]' ' MP culling[ms]' ' MP creation[ms]' ' LBA[ms]'
        #' KF culling[ms]' ' Total[ms]']
      elif "LocalMapTimeStats" in fn:
        df.columns=["Start", "Stereo Rect.", "MP Cul.", "MP Creat.", "LBA", "KF Cul.","Total"] #"KF Cul.", 
        df_dict["lm"].append(df)
        #['#Start time[ms]' ' LBA time[ms]' ' KF opt[#]' ' KF fixed[#]' ' MP[#]' ' Edges[#]']
      elif "LBA_Stats" in fn:
        df.columns=["Start", "Total", "KF Opt.", "KF Fix.", "MP", "Edges"]#, "Edges"]
        df_dict["lba"].append(df)
        #['#Start time[ms]' ' Total[ms]']
      elif "PR_Stats" in fn:
        df.columns=["Start", "Total"]
        df_dict["pr"].append(df)
        #['#Start time[ms]' ' Merge Maps[ms]' ' Welding BA[ms]'
        #' Merge Opt.Ess.[ms]' ' Total[ms]' ' #KFs' ' #MPs']
      elif "Merge_Stats" in fn:
        df.columns=["Start", "Merge Maps", "Welding BA", "Opt.Ess.", "Total", "#KFs", "#MPs"]
        df_dict["merge"].append(df)
        #['#Start time[ms]' ' Fusion[ms]' ' Opt.Ess.[ms]' ' Total[ms]']
      elif "LoopClosure_Stats" in fn:
        df.columns=["Start", "Fusion", "Opt.Ess.", "Total"]
        df_dict["loop"].append(df)
        #['#Start time[ms]' ' GBA[ms]' ' Update map[ms]' ' Total[ms]']
      elif "GBA_Stats" in fn:
        df.columns=["Start", "GBA", "Update Map", "Total"]
        df_dict["gba"].append(df)
        #['Time[ms]']
      elif "LostTrackStats" in fn:
        df.columns=["Start"]
        df_dict["lt"].append(df)

      # System
        #['Time from start [ms]' ' #CPU Process[pct]' ' CPU Total[pct]'
        #' VMem Process[kb]' ' VMem Current[kb]' ' VMem Total[kb]'
        #' RAM Process[kb]' ' RAM Current[kb]' ' RAM Total[kb]']']
      elif "SystemStats" in fn:
        df.columns=["Start", "#CPU Process[pct]", "CPU Total[pct]", "VMem Process[kb]", "VMem Current[kb]", "VMem Total[kb]", "RAM Process[kb]", "RAM Current[kb]", "RAM Total[kb]"]
        df_dict["cpu"].append(df)

  return df_dict


def plot_timeline(df_dict, savefig=False, plotfig=False, save_path=""):
  #kf_sub_lm, kf_pub_lm
  last_time = 0
  start_time = 0

  # Horizontal bar plot with gaps
  fig, ax = plt.subplots(4,1, sharex=True, figsize=(20, 6), gridspec_kw={'height_ratios': [1.5,1,2,2]})

  colors=['#4572ce', '#bedc9c', '#c94e4e']
  alphas=[1, 0.75,0.75]

  # ROS2+DISTRIBUTOR
  dfs=[]
  #if len(df_dict["kf_sub"]) == len(df_dict["map_sub"]):
      
  for j in range(3):
    for df_type in ["kf_pub", "kf_sub", "map_pub", "map_sub", "atlas_pub", "atlas_sub"]:
        print(f"{df_type} {j}")
        if(len(df_dict[df_type]) > j):
            dfs.append(df_dict[df_type][j])
    #dfs=[df_dict["kf_pub"][j], df_dict["kf_sub"][j], df_dict["map_pub"][j], df_dict["map_sub"][j], df_dict["atlas_pub"][j], df_dict["atlas_sub"][j]]

    for k, df in enumerate(dfs):
      times, start_time, last_time = get_times(df, start_time, last_time)
      ax[0].broken_barh(times, (k+1, 0.5), facecolors=[colors[j]], alpha=alphas[j])
    dfs = []


  labels=["KF Pub.", "KF Sub.", "Map Pub.", "Map Sub.", "Atlas Pub.", "Atlas Sub."]
  ax[0].set_yticklabels(labels, fontsize=8)
  ax[0].set_title("Distributor", rotation='vertical',x=-0.07,y=0.2, fontsize=10)
  ax[0].set_yticks([1.5,2.5,3.5,4.5,5.5,6.5])


  # ORBSLAM3
  for j in range(len(df_dict["lm"])):
    dfs=[]
    if(len(df_dict["tr"])-1 >=j):
      dfs.append(df_dict["tr"][j])
    if(len(df_dict["lm"])-1 >=j):
      dfs.append(df_dict["lm"][j])
    if(len(df_dict["lba"])-1 >=j):
      dfs.append(df_dict["lba"][j])
    if(len(df_dict["pr"])-1 >=j):
      dfs.append(df_dict["pr"][j])
    if(len(df_dict["merge"])-1 >=j):
      dfs.append(df_dict["merge"][j])
    if(len(df_dict["loop"])-1 >=j):
      dfs.append(df_dict["loop"][j])
    if(len(df_dict["gba"])-1 >=j):
      dfs.append(df_dict["gba"][j])


    for k, df in enumerate(dfs):
      times, start_time, last_time = get_times(df, start_time, last_time)
      ax[1].broken_barh(times, (k+1, 0.5), facecolors=[colors[j]], alpha=alphas[j])

  ax[1].set_title("ORB SLAM3", rotation='vertical',x=-0.07,y=0.1, fontsize=10)
  ax[1].set_yticklabels(["TR", "LM", "LBA", "PR", "Merge", "Loop", "GBA"], fontsize=8)
  ax[1].set_yticks([0.5,1.5,2.5,3.5, 4.5, 5.5, 6.5, 7.5])


  # SYSTEM
  max_cpu=0

  #starting_times=df_dict["cpu"][0].loc[:,["Start"]].to_numpy().flatten().astype(int)/10
  #values = df_dict["cpu"][0].loc[:,["CPU Total[pct]"]].to_numpy().flatten()
  #ax[2].plot(starting_times, values, c='#000000', alpha=0.5)
  

  for k, df in enumerate(df_dict["cpu"]):
    sys_np = df.to_numpy()

    times=[]
    if len(sys_np) > 0:

      starting_times=df.loc[:,["Start"]].to_numpy().flatten() #.astype(int)
      values = df.loc[:,["#CPU Process[pct]"]].to_numpy().flatten()
      #indices = values>3.0
      #starting_times = starting_times[indices]
      #values = values[indices]

      if starting_times[-1] > last_time and starting_times[-1] > 0 and starting_times[-1] < 500:
        last_time=starting_times[-1]

      if starting_times[0] < start_time and starting_times[0] > 0:
        start_time=starting_times[0]

      if values.max() > max_cpu:
        max_cpu = values.max()

    ax[2].plot(starting_times, values, c=colors[k])

    print(f"min={values.min()}, mean={np.mean(values)}, median={np.median(values)}, max={values.max()}")


  ax[2].legend(["Tracking", "Local Mapping", "Loop Closing"], fontsize=8)
  ax[2].set_title("System Util.", rotation='vertical',x=-0.07,y=0.2, fontsize=10)
  ax[2].set_xlim(start_time, last_time)



    #"VMem Process[kb]", "VMem Current[kb]", "VMem Total[kb]", "RAM Process[kb]", "RAM Current[kb]", "RAM Total[kb]"
  # MEMORY
  max_cpu=0
  for k, df in enumerate(df_dict["cpu"]):
    sys_np = df.to_numpy()

    times=[]
    if len(sys_np) > 0:

      starting_times=df.loc[:,["Start"]].to_numpy().flatten() # .astype(int)
      values = df.loc[:,["RAM Process[kb]"]].to_numpy().flatten()

      if values.max() > max_cpu:
        max_cpu = values.max()

    ax[3].plot(starting_times, values, c=colors[k])

  ax[3].legend(["Tracking", "Local Mapping", "Loop Closing"], fontsize=8)
  ax[3].set_title("Memory Util.", rotation='vertical',x=-0.07,y=0.2, fontsize=10)
  ax[3].set_xlim(start_time, last_time)

  if len(df_dict["lt"]) > 0:
      for time in (df_dict["lt"][0].loc[:,["Start"]].to_numpy().flatten()): #.astype(int):
        ax[0].axvline(x=time, ymin = 0, ymax = 7, color='#D3D3D3', linestyle= "-")
        ax[1].axvline(x=time, ymin = 0, ymax = 7, color='#D3D3D3', linestyle= "-")
        ax[2].axvline(x=time, ymin = 0, ymax = 7, color='#D3D3D3', linestyle= "-")
        ax[3].axvline(x=time, ymin = 0, ymax = 7, color='#D3D3D3', linestyle= "-")
        ax[3].annotate("Lost track", (time , max_cpu-5),xytext=(4, 5.5), textcoords='offset points', ha='left', va='bottom')


  plt.subplots_adjust(wspace=0.0, hspace=0.0)
  if savefig and os.path.exists(os.path.dirname(save_path)):
    plt.savefig(save_path)

  if not plotfig:
    plt.close()

  plt.show()



def plot_latencies(df_dict, savefig=False, plotfig=False, save_path=""):
  colors=['#4572ce', '#bedc9c', '#c94e4e']
  fig, ax = plt.subplots(1,3, figsize=(18, 3))
  for k,df in enumerate(df_dict["kf_lat"]):
    ax[0].plot(df, c=colors[k])
  ax[0].set_title("KeyFrame", fontsize=10)
  #ax[0].set_ylim(0, 50)
  for k,df in enumerate(df_dict["map_lat"]):
    ax[1].plot(df, c=colors[k])
  ax[1].set_title("Map", fontsize=10)
  #ax[1].set_ylim(0, 100)
  for k,df in enumerate(df_dict["atlas_lat"]):
    ax[2].plot(df, c=colors[k])
  ax[2].set_title("Atlas", fontsize=10)
  #ax[2].set_ylim(0, 200)

  ax[0].legend(["Tracking", "Local Mapping", "Loop Closing"], fontsize=8)
  ax[0].set_ylabel('time [ms]')
  plt.subplots_adjust(wspace=0.15, hspace=0.15)
  fig.suptitle('Latency', fontsize=12)

  if savefig and os.path.exists(os.path.dirname(save_path)):
    plt.savefig(save_path)

  if not plotfig:
    plt.close()

  plt.show()


def plot_keyframe_times(df_dict, savefig=False, plotfig=False, save_path=""):
  plot_labels = ["Tracking", "Local Mapping", "Loop Closing"]
  colors=['#4572ce', '#bedc9c', '#c94e4e']
  fig, axs = plt.subplots(3,3, sharey=False, figsize=((18,7)))

  df_arrs=[df_dict["kf_pub"], df_dict["kf_sub"], df_dict["kf_sub"]]
  df_titles=[["KF Conv.", "KF PreSave", "MPs PreSave", "Total"],
            ["KF Conv.", "Prep. Data", "MPs Conv.", "KF PostLoad", "MPs PostLoad", "KF Injection", "MPs Injection", "Total"],
            ["#New MPs", "#Update MPs"]]
  for j in range(3):
    for k,df in enumerate(df_arrs[j]):
      axs[j,k].plot(df.loc[0:df.shape[0]-5, df_titles[j]])
      axs[j,k].set_xlabel('idx')
      axs[j,k].grid()
      #axs[j,k].set_ylim(0, 100)

  axs[0,2].legend(df_titles[0], fontsize=8)
  axs[1,0].legend(df_titles[1], fontsize=8)
  axs[2,1].legend(df_titles[2], fontsize=8)

  for k in range(3):
    axs[0,k].set_title(plot_labels[k], fontsize=10)
  axs[0,0].set_ylabel('time [ms]')
  axs[1,0].set_ylabel('time [ms]')
  plt.subplots_adjust(wspace=0.15, hspace=0.15)
  fig.suptitle('KF times', fontsize=12)

  if savefig and os.path.exists(os.path.dirname(save_path)):
    plt.savefig(save_path)

  if not plotfig:
    plt.close()

  plt.show()

def plot_map_times(df_dict, savefig=False, plotfig=False, save_path=""):
  plot_labels = ["Tracking", "Local Mapping", "Loop Closing"]
  colors=['#4572ce', '#bedc9c', '#c94e4e']
  fig, axs = plt.subplots(4,3, sharey=False, figsize=((25,12)))

  df_arrs=[df_dict["map_pub"], df_dict["map_sub"], df_dict["map_sub"], df_dict["map_sub"]]
  df_titles=[["KFs+MPs Conv.", "PreSave", "Total"],
            ["MPs PL", "KFs PL", "KFs Conv.", "MPs Conv.", "KFs+MPs Conv.", "MPs Injection", "KFs Injection", "Map conv.", "Total"],
            ["#KFs", "#KFs Total"] ,
            ["#MPs", "#MPs Total"]]
  for j in range(4):
    for k,df in enumerate(df_arrs[j]):
      axs[j,k].plot(df.loc[0:df.shape[0]-5, df_titles[j]])
      axs[j,k].set_xlabel('idx')
      axs[j,k].grid()
      #axs[j,k].set_ylim(0, 300)

  axs[0,0].legend(df_titles[0], fontsize=8)
  axs[1,1].legend(df_titles[1], fontsize=8)
  axs[2,0].legend(df_titles[2], fontsize=8)
  axs[3,0].legend(df_titles[3], fontsize=8)

  for k in range(3):
    axs[0,k].set_title(plot_labels[k], fontsize=10)
  axs[0,0].set_ylabel('time [ms]')
  axs[1,0].set_ylabel('time [ms]')
  plt.subplots_adjust(wspace=0.15, hspace=0.15)
  fig.suptitle('Map times', fontsize=12)


  if savefig and os.path.exists(os.path.dirname(save_path)):
    plt.savefig(save_path)

  if not plotfig:
    plt.close()

  plt.show()

def plot_atlas_times(df_dict, savefig=False, plotfig=False, save_path=""):
  plot_labels = ["Tracking", "Local Mapping", "Loop Closing"]
  colors=['#4572ce', '#bedc9c', '#c94e4e']
  fig, axs = plt.subplots(2,3, sharey=False, figsize=((18,5)))

  df_arrs=[df_dict["atlas_pub"], df_dict["atlas_sub"]]
  df_titles=[["KFs+MPs Conv.", "PreSave", "Total"],["MPs PL", "KFs PL", "KFs+MPs Conv.", "MPs Injection", "KFs Injection", "Map conv.", "Total"]]
  for j in range(2):
    for k,df in enumerate(df_arrs[j]):
      axs[j,k].plot(df.loc[:, df_titles[j]], 'o')
      axs[j,k].set_xlabel('idx')
      axs[j,k].grid()
      #axs[j,k].set_ylim(0, 500)

  axs[0,0].legend(df_titles[0], fontsize=8)
  axs[1,1].legend(df_titles[1], fontsize=8)

  for k in range(3):
    axs[0,k].set_title(plot_labels[k], fontsize=10)
  axs[0,0].set_ylabel('time [ms]')
  axs[1,0].set_ylabel('time [ms]')
  plt.subplots_adjust(wspace=0.15, hspace=0.15)
  fig.suptitle('Atlas times', fontsize=12)

  if savefig and os.path.exists(os.path.dirname(save_path)):
    plt.savefig(save_path)

  if not plotfig:
    plt.close()

  plt.show()

def plot_slam_times(df_dict, savefig=False, plotfig=False, save_dir=""):
  colors=['#4572ce', '#bedc9c', '#c94e4e']
  if len(df_dict["tr"]) > 0 or len(df_dict["lm"]) > 0:
    plot_labels = ["Tracking", "Local Mapping", "Loop Closing"]
    fig, axs = plt.subplots(1,3, sharey=False, figsize=((18,3)))

    if len(df_dict["tr_all"]) > 0:
      axs[0].set_title("Full Tracking Time Stats", fontsize=10)
      axs[0].plot(df_dict["tr_all"][0].loc[:, ["Total"]])
      #axs[0].plot(df_dict["tr_all"][0].loc[:, ["Total"]] - df_dict["tr"][0].loc[:, ["Total"]])
      axs[0].set_xlabel('idx')
      axs[0].grid()
      axs[0].legend(["Total"], fontsize=8)

    if len(df_dict["tr"]) > 0:
      axs[1].set_title("Tracking Time Stats", fontsize=10)
      axs[1].plot(df_dict["tr"][0].loc[:, ["ORB Ext.", "Pose Pred.", "LM Track.", "New KF"]])
      axs[1].plot(df_dict["tr"][0]["ORB Ext."] + df_dict["tr"][0]["Total"])
      axs[1].set_xlabel('idx')
      axs[1].grid()
      axs[1].legend(["ORB Ext.", "Pose Pred.", "LM Track.", "New KF", "Total"], fontsize=8)

    if len(df_dict["lm"]) > 0:
      lm_idx= 1 if len(df_dict["lm"]) > 1 else 0

      axs[2].set_title("Local Mapping Time Stats", fontsize=10)
      axs[2].plot(df_dict["lm"][lm_idx].loc[:, ["MP Cul.", "MP Creat.", "LBA", "KF Cul."]])
      axs[2].set_xlabel('idx')
      axs[2].grid()
      axs[2].legend(["MP Cul.", "MP Creat.", "LBA", "KF Cul."], fontsize=8)


    if savefig and os.path.exists(save_dir):
      plt.savefig(f"{save_dir}/tr-lm-time.png")

    if not plotfig:
      plt.close()

  plt.show()

  if len(df_dict["loop"]) > 0 or len(df_dict["merge"]) > 0:
    fig, axs = plt.subplots(1,3, sharey=False, figsize=((18,3)))

    if len(df_dict["loop"]) > 0:
      lc_idx= 2 if len(df_dict["loop"]) > 1 else 0

      axs[0].set_title("Loop Closing - Loop closure Time Stats", fontsize=10)
      axs[0].plot(df_dict["loop"][lc_idx].loc[:, ["Fusion", "Opt.Ess.", "Total"]], 'o-')
      axs[0].set_xlabel('idx')
      axs[0].grid()
      axs[0].legend(["Fusion", "Opt.Ess.", "Total"], fontsize=8)

    if len(df_dict["gba"]) > 0:
      axs[1].set_title("Loop Closing - Global BA Time Stats", fontsize=10)
      axs[1].plot(df_dict["gba"][lc_idx].loc[:, ["GBA", "Update Map", "Total"]] , 'o-')
      axs[1].set_xlabel('idx')
      axs[1].grid()
      axs[1].legend(["GBA", "Update Map", "Total"], fontsize=8)

    if len(df_dict["merge"]) > 0:
      axs[2].set_title("Loop Closing - Map Merging Time Stats", fontsize=10)
      axs[2].plot(df_dict["merge"][lc_idx].loc[:, ["Merge Maps", "Welding BA", "Opt.Ess.", "Total"]] , 'o-')
      axs[2].set_xlabel('idx')
      axs[2].grid()
      axs[2].legend(["Merge Maps", "Welding BA", "Opt.Ess.", "Total"], fontsize=8)

    if savefig and os.path.exists(save_dir):
      plt.savefig(f"{save_dir}/lc-time.png")

    if not plotfig:
      plt.close()
    
    plt.show()

def calc_stats(df_dict):
  vals=np.zeros((10))

  if len(df_dict["lt"]) != 0:
    vals[0] = len(df_dict["lt"][0][(df_dict["lt"][0]['Start'] > 500)]["Start"].unique()) # Skip if lost track within first half a second (bad initialization)
  if len(df_dict["tr"]) != 0:
    vals[1] = df_dict["tr"][0]["Total"].mean()

  if len(df_dict["lm"]) > 1:
    vals[2] = df_dict["lm"][1][(df_dict["lm"][1]['Start'] > 0) & (df_dict["lm"][1]['Start'] < 500000)]["Total"].mean()
  else:
    vals[2] = df_dict["lm"][0][(df_dict["lm"][0]['Start'] > 0) & (df_dict["lm"][0]['Start'] < 500000)]["Total"].mean()

  if len(df_dict["lba"]) > 1:
    indices = df_dict["lba"][1][(df_dict["lba"][1]['KF Opt.'] > 0) & (df_dict["lba"][1]["KF Opt."] < 1000)].index
    vals[3] = df_dict["lba"][1][(df_dict["lba"][1]['KF Opt.'] > 0) & (df_dict["lba"][1]["KF Opt."] < 1000)]["Total"].mean()
    vals[4] = df_dict["lba"][1][(df_dict["lba"][1]['KF Opt.'] > 0) & (df_dict["lba"][1]["KF Opt."] < 1000)]["KF Opt."].mean()
    vals[5] = (df_dict["lba"][1].iloc[indices]["Total"] / df_dict["lba"][1].iloc[indices]["KF Opt."]).mean()
  else:
    indices = df_dict["lba"][0][(df_dict["lba"][0]['KF Opt.'] > 0) & (df_dict["lba"][0]["KF Opt."] < 1000)].index
    vals[3] = df_dict["lba"][0][(df_dict["lba"][0]['KF Opt.'] > 0) & (df_dict["lba"][0]["KF Opt."] < 1000)]["Total"].mean()
    vals[4] = df_dict["lba"][0][(df_dict["lba"][0]['KF Opt.'] > 0) & (df_dict["lba"][0]["KF Opt."] < 1000)]["KF Opt."].mean()
    vals[5] = (df_dict["lba"][0].iloc[indices]["Total"] / df_dict["lba"][0].iloc[indices]["KF Opt."]).mean()

  if len(df_dict["pr"]) > 1:
    vals[6] = df_dict["pr"][2]["Total"].mean()
  else:
    vals[6] = df_dict["pr"][0]["Total"].mean()

  if len(df_dict["merge"]) > 1:
    vals[7] = df_dict["merge"][2]["Total"].mean()
  else:
    vals[7] = df_dict["merge"][0]["Total"].mean()

  if len(df_dict["loop"]) > 1:
    vals[8] = df_dict["loop"][2]["Total"].mean()
  else:
    vals[8] = df_dict["loop"][0]["Total"].mean()

  if len(df_dict["gba"]) > 1:
    vals[9] = df_dict["gba"][2]["Total"].mean()
  else:
    vals[9] = df_dict["gba"][0]["Total"].mean()

  return vals



  #mean_df = mean_df.rename(columns=lambda c: "mean_"+str(c))
  #std_df = pd.DataFrame(df_dict["lm"][0].std().to_dict(),index=[device])
  #std_df = std_df.rename(columns=lambda c: "std_"+str(c))
  #print(mean_df)
  #print(std_df)
  #merged_df = pd.concat([mean_df, std_df], axis=1)
  #print(merged_df)

def create_radar_chart(ax, data, metrics, title):
  N = len(metrics)
  theta = np.linspace(0, 2 * np.pi, N, endpoint=False)
  theta = np.concatenate([theta, [theta[0]]])

  ax.set_title(title, y=1.15, fontsize=20)
  ax.set_theta_zero_location("N")
  ax.set_theta_direction(-1)
  ax.set_rlabel_position(90)
  ax.spines['polar'].set_zorder(1)
  ax.spines['polar'].set_color('lightgrey')

  color_palette = ['#339F00', '#0500FF', '#9CDADB', '#FF00DE', '#FF9900', '#FFFFFF']

  for idx, (i, row) in enumerate(data.iterrows()):
      values = row[metrics].values.flatten().tolist()
      values = values + [values[0]]
      ax.plot(theta, values, linewidth=1.75, linestyle='solid', label=i, marker='o', markersize=10, color=color_palette[idx % len(color_palette)])
      ax.fill(theta, values, alpha=0.50, color=color_palette[idx % len(color_palette)])
  ax.set_xticks(theta, metrics + [metrics[0]], color='black', size=12)
  #plt.yticks([0, 25, 50, 75, 100], ["0", "25", "50", "75", "100"], color="black", size=12)
  #plt.set_xticks(theta, metrics + [metrics[0]], color='black', size=12)
  plt.legend(loc='upper right', bbox_to_anchor=(1.3, 1.1))

  plt.show()

def plot_radar_chart(df_dict, metrics):
  fig, ax = plt.subplots(2,5, figsize=(16, 8), subplot_kw={'projection': 'polar'})
  k=0
  j=0
  for i, df_key in enumerate(df_dict):
    if i%5 == 0 and i != 0:
      j=0
      k+=1

    create_radar_chart(ax[k,j], df_dict[df_key], dataset_names, df_key)

    j+=1
  fig.tight_layout()

  plt.show()

def plot_table(df_dict):

  for df_key in df_dict:
    df=df_dict[df_key]
    with pd.option_context('display.precision', 1):
        # displaying the DataFrame
        ax = plt.subplot(111, frame_on=False) # no visible frame
        ax.xaxis.set_visible(False)  # hide the x axis
        ax.yaxis.set_visible(False)  # hide the y axis

        pd.plotting.table(ax, df)  # where df is your data frame

    plt.show()
    #plt.savefig('mytable.png')
    #print(df_key)
    #  display(df)

def list_arg_type(input_string):
    # Check if input_string contains whitespace characters
    if any(char.isspace() for char in input_string):
        raise ValueError("Input string should not contain whitespace characters.")

    words = input_string.split(',')
    return words

def bool_arg_type(input_string):
    # Convert input_string to lowercase for case-insensitive comparison
    lower_input = input_string.strip().lower()
    
    # Check if lower_input is "true" or "false"
    if lower_input == "true":
        return True
    elif lower_input == "false":
        return False
    else:
        raise ValueError("Input string must be 'True' or 'False'.")

def main():
    """
    Main function that runs when the script is executed.
    """
    # Create an ArgumentParser object
    parser = argparse.ArgumentParser(description="Visualize results.")

    # Add arguments
    parser.add_argument('-category', type=str, help='Dataset category [TUM,EuRoC]', required=True)
    parser.add_argument('-datasets', type=list_arg_type, help='Dataset(s) name [MH_01,room1,outdoors1,...]. Use , as separator (no whitespaces)', required=True)
    parser.add_argument('-devices', type=list_arg_type, help='Device(s) name [mac-single,mac-distributed,...]. Use , as separator (no whitespaces)', required=True)
    parser.add_argument('-plot_ros', type=bool_arg_type, default='True', help='ROS plots', required=False)
    parser.add_argument('-plot_timeline', type=bool_arg_type, default='True', help='Timeline (events) plot', required=False)
    parser.add_argument('-plot_slam', type=bool_arg_type, default='False', help='SLAM plots', required=False)
    parser.add_argument('-plot_radar', type=bool_arg_type, default='False', help='Radar plots', required=False)
    parser.add_argument('-plot_table', type=bool_arg_type, default='True', help='Plot Tables', required=False)
    parser.add_argument('-save_figs', type=bool_arg_type, default='False', help='Save figures', required=False)

    # Parse arguments
    args = parser.parse_args()
    dataset_category=args.category
    #dataset_names=["room1", "room2", "room3", "room4", "room5", "room6"]
    #dataset_names=["MH_01", "MH_02", "MH_03", "MH_04", "MH_05", "V1_01", "V1_02", "V1_03", "V2_01", "V2_02", "V2_03"]
    dataset_names=args.datasets

    devices=args.devices#, "mac-distributed"]#, "orin-single", "xavier-single", "nano-single"]
    #devices=["orin-single", "xavier-single", "nano-single"]

    #plt.style.use('ggplot')
    
    # Plot params
    mb_plot_ros=args.plot_ros
    mb_plot_timeline=args.plot_timeline
    mb_plot_slam=args.plot_slam
    mb_plot_radar=args.plot_radar
    mb_plot_stats_table=args.plot_table
    mb_save_figs=args.save_figs

    metrics=['L.T.', 'TR', 'LM', 'LBA', 'LBA #KFs', 'LBA kf/ms', 'P.R.','Merge','L.C.','GBA']
    df_stats_slam_dict = {}
    df_stats_ds_dict = {}

# init slam stats dict
# SLAM metrics as key and datasets as values for each dataframe
# e.g.    |MH_01|MH_02|...
#    orin |  0  |  0  |...
    for m in metrics:
        df_stats_slam_dict[m]=pd.DataFrame(columns=dataset_names)

# init dataset stats dict
# Datasets as key and SLAM metrics as values for each dataframe
# e.g.    |lt|tr|...
#    orin |0 | 0|...
    for ds in dataset_names:
        df_stats_ds_dict[ds]=pd.DataFrame(columns=metrics)


    for device in devices:
# Single / Distributed device
        if "distributed" in device:
            single_device=False
        else:
            single_device=True

        for dataset_name in dataset_names:

            print(f' ------- Device={device}, dataset={dataset_name}, category={dataset_category} ------- ')

#data_path = f"/content/drive/MyDrive/Tuni/2024/DistSLAM/{dataset_name}/{rate_label}"
            data_path = f"/root/results/{dataset_category}/{dataset_name}/monocular"
            if os.path.exists(f'{data_path}/plots') is False :
                os.mkdir(f"{data_path}/plots")

            df_dict = read_data(data_path)

            plot_timeline(df_dict, savefig=mb_save_figs, plotfig=mb_plot_timeline, save_path=f"{data_path}/plots/events.png")

#######################
#         ROS
#######################
            #if not single_device:
            plot_latencies(df_dict, savefig=mb_save_figs, plotfig=mb_plot_ros, save_path=f"{data_path}/plots/latency.png")
            plot_keyframe_times(df_dict, savefig=mb_save_figs, plotfig=mb_plot_ros, save_path=f"{data_path}/plots/kf-times.png")
            plot_map_times(df_dict, savefig=mb_save_figs, plotfig=mb_plot_ros, save_path=f"{data_path}/plots/map-times.png")
            plot_atlas_times(df_dict, savefig=mb_save_figs, plotfig=mb_plot_ros, save_path=f"{data_path}/plots/atlas-times.png")

#######################
#         SLAM
#######################
            plot_slam_times(df_dict, savefig=mb_save_figs, plotfig=mb_plot_slam, save_dir=f"{data_path}/plots")

            vals = calc_stats(df_dict)
            for idx, key in enumerate(df_stats_slam_dict):
                df_stats_slam_dict[key].at[device, dataset_name] = vals[idx]

            df_stats_ds_dict[dataset_name].loc[device] = vals

            if mb_plot_radar:
                plot_radar_chart(df_dict=df_stats_slam_dict, metrics=dataset_names)
            if mb_plot_stats_table:
                plot_table(df_dict=df_stats_ds_dict)






    # Use the arguments
    print(f"Dataset: {args.datasets}")

# If this script is executed, run the main function.
if __name__ == "__main__":
    main()
