
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
from copy import deepcopy

import matplotlib
matplotlib.use( 'TKAgg' )
import matplotlib.pyplot as plt

import pandas as pd
import os

from evo.core import metrics
from evo.core.units import Unit

from evo.tools import log
log.configure_logging(verbose=True, debug=True, silent=False)

from evo.tools import file_interface
from evo.core import sync
from evo.tools import pandas_bridge

import pprint
import copy

import re
from pathlib import Path
from typing import Dict, Tuple, List



def calculate_atlas_pub_metrics(atlas_file_path):
    df = pd.read_csv(atlas_file_path)
    df.columns=["Start", "KFs+MPs Conv.", "PreSave", "Total"]
    start_times = df.loc[:,["Start"]].to_numpy().flatten()
    total_times = df.loc[:,["Total"]].to_numpy().flatten()
    total_times = total_times[(total_times > 0.0) & (total_times < 200.0)]

    frequencies = []
    if len(start_times) > 0:
        first_time = start_times[0]
        for start_time in start_times: 
            time_ms = start_time - first_time
            if time_ms == 0:
                continue
            frequencies.append(time_ms) 
            first_time = start_time

    atlas_pub_stats={
            "mean_total": np.mean(total_times),
            "mean_fr": np.mean(frequencies),
            "std_fr": np.std(frequencies)
            }

    return atlas_pub_stats



def calculate_map_pub_metrics(map_file_path):
    df = pd.read_csv(map_file_path)
    df.columns=["Start", "KFs+MPs Conv.", "PreSave", "Total"]
    start_times = df.loc[:,["Start"]].to_numpy().flatten()
    total_times = df.loc[:,["Total"]].to_numpy().flatten()
    total_times = total_times[(total_times > 0.0) & (total_times < 10000.0)]

    frequencies = []
    if len(start_times) > 0:
        first_time = start_times[0]
        for start_time in start_times: 
            time_ms = start_time - first_time
            if time_ms == 0:
                continue
            frequencies.append(time_ms) 
            first_time = start_time

    map_pub_stats={
            "mean_total": np.mean(total_times),
            "mean_fr": np.mean(frequencies),
            "std_fr": np.std(frequencies)
            }

    return map_pub_stats


def calculate_kf_sub_metrics(kf_file_path):
    df = pd.read_csv(kf_file_path)
    df.columns = ["Start", "KF Conversion[ms]", "Prep data[ms]", "MPs Conversion[ms]", "KF PostLoad[ms]", "MPs PostLoad[ms]", "KF Injection[ms]", "MPs Injection[ms]", "Total", "#KFs", "#MPS", "#New MPs", "#Update MPs"]
    start_times = df.loc[:,["Start"]].to_numpy().flatten()
    total_times = df.loc[:,["Total"]].to_numpy().flatten()
    total_times = total_times[(total_times > 0.0) & (total_times < 10000.0)]


    kf_sub_stats={
            "mean_total": np.mean(total_times),
            }

    return kf_sub_stats


def calculate_kf_pub_metrics(kf_file_path):
    df = pd.read_csv(kf_file_path)
    df.columns = ["Start", "KF Conv.", "KF PreSave", "MPs PreSave", "Total"]
    start_times = df.loc[:,["Start"]].to_numpy().flatten()
    total_times = df.loc[:,["Total"]].to_numpy().flatten()
    total_times = total_times[(total_times > 0.0) & (total_times < 10000.0)]

    frequencies = []
    if len(start_times) > 0:
        first_time = start_times[0]
        for start_time in start_times: 
            time_ms = start_time - first_time
            if time_ms == 0:
                continue
            frequencies.append(time_ms) 
            first_time = start_time

    kf_pub_stats={
            "mean_total": np.mean(total_times),
            "mean_fr": np.mean(frequencies),
            "std_fr": np.std(frequencies)
            }

    return kf_pub_stats


def calculate_cpu_util(cpu_file_path):
    df = pd.read_csv(cpu_file_path)
    df.columns=["Start", "#CPU Process[pct]", "CPU Total[pct]", "VMem Process[kb]", "VMem Current[kb]", "VMem Total[kb]", "RAM Process[kb]", "RAM Current[kb]", "RAM Total[kb]"]
    values = df.loc[:,["#CPU Process[pct]"]].to_numpy().flatten()
    cpu_th=0.4
    if "TR" in cpu_file_path:
        cpu_th = 20.0

    values = values[(values > cpu_th)]
    print(len(values))

    cpu_stats={
            "min": np.min(values),
            "mean": np.mean(values),
            "median": np.median(values),
            "max": np.max(values),
            "std": np.std(values)
            }
    print(cpu_stats)
    return cpu_stats


def calculate_LBA_stats(file_path):
    df = pd.read_csv(file_path)
    df.columns=["Start", "LBA time", "KF opt", "KF fix", "MP", "Edges"]
    start_times = df.loc[:,["Start"]].to_numpy().flatten()
    lba_times = df.loc[:,["LBA time"]].to_numpy().flatten()
    lba_opt_kf = df.loc[:,["KF opt"]].to_numpy().flatten()
    lba_edges = df.loc[:,["Edges"]].to_numpy().flatten()

    f = (start_times > 0.) & (start_times< 10000000)

    # Filter based on the start time
    lba_times = lba_times[f]
    lba_edges = lba_edges[f]
    lba_opt_kf = lba_opt_kf[f]

    # filter based on value
    lba_times = [(lba_times >= 0) & (lba_times <= 10000)]
    lba_edges = [(lba_edges >= 0) & (lba_edges <= 10000)]
    lba_opt_kf = [(lba_opt_kf >= 0) & (lba_opt_kf <= 10000)]
    
    if len(lba_times) == 0:
        return {}

    lba_stats={
            "mean_times": np.mean(lba_times),
            "mean_edges": np.mean(lba_edges),
            "mean_opt_kf": np.mean(lba_opt_kf),
            }
    return lba_stats


def calculate_latency(file_path):
    df = pd.read_csv(file_path)
    df.columns=["latency"]
    values = df.loc[:,["latency"]].to_numpy().flatten()

    #values = values[(values > 0.)]
    
    if len(values) == 0:
        return {}

    latency_stats={
            "min": np.min(values),
            "mean": np.mean(values),
            "median": np.median(values),
            "max": np.max(values),
            "std": np.std(values)
            }
    return latency_stats

def calculate_ape(ref_file_path, est_file_path):
    traj_ref = file_interface.read_tum_trajectory_file(ref_file_path)
    traj_est = file_interface.read_tum_trajectory_file(est_file_path)

    traj_est_info = deepcopy(traj_est.get_infos())
    traj_ref_info = deepcopy(traj_ref.get_infos())

    max_diff = 0.01
    traj_ref, traj_est = sync.associate_trajectories(traj_ref, traj_est, max_diff)

    traj_est_aligned = copy.deepcopy(traj_est)
    traj_est_aligned.align(traj_ref, correct_scale=True, correct_only_scale=False)
    
    pose_relation = metrics.PoseRelation.translation_part
    
    data = (traj_ref, traj_est_aligned) 

    ape_metric = metrics.APE(pose_relation)
    ape_metric.process_data(data)

    ape_stats = ape_metric.get_all_statistics()
    pprint.pprint(ape_stats)
    return ape_stats, traj_est_info, traj_ref_info

MEAN_STD_PATTERN = re.compile(
    r"""
    ^\s*
    (?P<name>[^:\n]+?)              # label before colon
    \s*:\s*
    (?P<mean>                       # mean
        nan
        | [-+]?(?:\d+(?:\.\d*)?|\.\d+)(?:[eE][-+]?\d+)? 
    )
    \s*
    (?:                             # separator between mean and std
         \$\s*\\pm\s*\$             # $ \pm $
       | \\pm                       # \pm
       | ±                          # literal U+00B1
       | \+/-| \+\/-                # +/- variants
    )
    \s*
    (?P<std>                        # std
        nan
        | [-+]?(?:\d+(?:\.\d*)?|\.\d+)(?:[eE][-+]?\d+)? 
    )
    (?:\s*[a-zA-Z%µμ/]+)?           # optional units like ms, %, µs
    \s*$
    """,
    re.IGNORECASE | re.VERBOSE,
)
INT_PATTERN = re.compile(r"^(?P<name>[^:\n]+):\s*(?P<val>[-+]?\d+)\s*$", re.IGNORECASE)
DASH_LINE_PATTERN = re.compile(r"^-{3,}\s*$")

def _clean(s: str) -> str:
    return re.sub(r"\s+", " ", s.strip())

def _to_float(x: str) -> float:
    return float('nan') if x.lower() == 'nan' else float(x)

def parse_exec_file(path: str | Path) -> Dict[str, pd.DataFrame]:
    """
    Parse an ExecMean-<MODE>.txt file and extract requested metrics.

    Returns:
      {
        'means':  DataFrame(index='metric', columns=['mean','std']),
        'counts': DataFrame(index='metric', columns=['value'])
      }
    """
    path = Path(path)
    text = path.read_text(encoding="utf-8", errors="ignore")
    lines = [line.rstrip() for line in text.splitlines()]

    section = None
    means_rows: List[Tuple[str, float, float]] = []
    counts_rows: List[Tuple[str, int]] = []

    def add_mean(name: str, mean: float, std: float):
        means_rows.append((name, mean, std))

    def add_count(name: str, val: int):
        counts_rows.append((name, val))

    for raw in lines:
        line = raw.strip()
        if not line:
            continue

        if DASH_LINE_PATTERN.match(line):
            section = None
            continue

        # track section based on known headings
        low = line.lower()
        if low.startswith("tracking"): section = "Tracking"; continue
        if low.startswith("local mapping"): section = "Local Mapping"; continue
        if low.startswith("lba complexity"): section = "LBA complexity"; continue
        if low.startswith("map complexity"): section = "Map complexity"; continue
        if low.startswith("place recognition"): section = "Place Recognition"; continue
        if low.startswith("loop closing"): section = "Loop Closing"; continue
        if low.startswith("map merging"): section = "Map Merging"; continue
        if low.startswith("full gba"): section = "Full GBA"; continue

        m = MEAN_STD_PATTERN.match(line)
        if m:
            name = _clean(m.group("name"))
            if name.lower().startswith("number of kfs"):
                add_mean(f"KFs - {section or '(unknown section)'}", _to_float(m.group("mean")), 0.0)
            elif name.lower().startswith("number of mps"):
                add_mean(f"MPs - {section or '(unknown section)'}", _to_float(m.group("mean")), 0.0)
            else:
                mean = _to_float(m.group("mean"))
                std = _to_float(m.group("std"))
                add_mean(name, mean, std)
            continue

        mi = INT_PATTERN.match(line)
        if mi:
            name = _clean(mi.group("name"))
            val = int(mi.group("val"))
            # "Numb exec" counters belong to their current section
            if name.lower().startswith("numb exec"):
                add_count(f"Numb exec - {section or '(unknown section)'}", val)
            elif name.lower().startswith("number of kfs"):
                add_count(f"KFs - {section or '(unknown section)'}", val)
            elif name.lower().startswith("number of mps"):
                add_count(f"MPs - {section or '(unknown section)'}", val)
            else:
                add_count(name, val)
            continue

    # keep only the mean±std metrics you asked for
    mean_keys_map = {
        "ORB Extraction": ["ORB Extraction"],
        "Pose Prediction": ["Pose Prediction"],
        "LM Track": ["LM Track"],
        "New KF decision": ["New KF decision"],
        "Total Tracking": ["Total Tracking"],
        "KF Insertion": ["KF Insertion"],
        "MP Culling": ["MP Culling"],
        "MP Creation": ["MP Creation"],
        "LBA": ["LBA"],
        "KF Culling": ["KF Culling"],
        "Total Local Mapping": ["Total Local Mapping"],
        "LBA Edges": ["LBA Edges"],
        "LBA KF optimized": ["LBA KF optimized"],
        "LBA KF fixed": ["LBA KF fixed"],
        "LBA MP": ["LBA MP"],
        "Database Query": ["Database Query"],
        "SE3 estimation": ["SE3 estimation"],
        "Total Place Recognition": ["Total Place Recognition"],
        "Loop Fusion": ["Loop Fusion"],
        "Essential Graph": ["Essential Graph"],
        "KFs - Loop Closing": ["KFs - Loop Closing"],
        "MPs - Loop Closing": ["MPs - Loop Closing"],
        "Total Loop Closing": ["Total Loop Closing"],
        "Merge Maps": ["Merge Maps"],
        "Welding BA": ["Welding BA"],
        "Optimization Ess.": ["Optimization Ess."],
        "KFs - Map Merging": ["KFs - Map Merging"],
        "MPs - Map Merging": ["MPs - Map Merging"],
        "Total Map Merging": ["Total Map Merging"],
        "GBA": ["GBA"],
        "Map Update": ["Map Update"],
        "KFs - Full GBA": ["KFs - Full GBA"],
        "MPs - Full GBA": ["MPs - Full GBA"],
        "Total Full GBA": ["Total Full GBA"],
    }

    means_dict = { _clean(n): (m, s) for (n, m, s) in means_rows }
    filtered_means = []
    for target, variants in mean_keys_map.items():
        for v in variants:
            if v in means_dict:
                filtered_means.append((target, *means_dict[v]))
                break
            else:
                filtered_means.append((target, float('nan'), float('nan')))
    means_df = pd.DataFrame(filtered_means, columns=["metric", "mean", "std"]).set_index("metric")

    # and the counters you asked for
    counts_needed_aliases = {
        "LBA executions": ["LBA executions"],
        "LBA aborts": ["LBA aborts"],
        "KFs in map": ["KFs in map"],
        "MPs in map": ["MPs in map"],
        "#Times lost track": ["#Times lost track", "#times lost track", "Times lost track"],
        "Numb exec - Loop Closing": ["Numb exec - Loop Closing"],
        "Numb exec - Local Mapping": ["Numb exec - Local Mapping"],
        "Numb exec - Full GBA": ["Numb exec - Full GBA", "Numb exec - GBA"],
        "Numb exec - Map Merging": ["Numb exec - Map Merging"],
    }
    counts_dict = { _clean(n): v for (n, v) in counts_rows }
    filtered_counts = []
    for target, variants in counts_needed_aliases.items():
        for v in variants:
            if v in counts_dict:
                filtered_counts.append((target, counts_dict[v]))
                break
        else:
            filtered_counts.append((target, float('nan')))
    counts_df = pd.DataFrame(filtered_counts, columns=["metric", "value"]).set_index("metric")


    return {"means": means_df, "counts": counts_df}


def calculate_dataset_means(df: pd.DataFrame) -> pd.DataFrame:
    # Identify numeric columns only
    numeric_cols = df.select_dtypes(include=[np.number]).columns

    new_rows = []
    for dataset, group in df.groupby("dataset", sort=False):
        new_rows.append(group)

        # Compute means only for numeric cols
        mean_vals = group[numeric_cols].mean()

        # Build a row with NaN/default for non-numeric cols
        mean_row = {col: None for col in df.columns}
        mean_row.update(mean_vals.to_dict())

        # Special handling for dataset name
        mean_row["dataset"] = f"{dataset}"
        mean_row["idx"] = "mean"

        new_rows.append(pd.DataFrame([mean_row], columns=df.columns))

    return pd.concat(new_rows, ignore_index=True)


def main():
    """
    Main function that runs when the script is executed.
    """
    # Create an ArgumentParser object
    parser = argparse.ArgumentParser(description="Visualize results.")

    # Add arguments
    parser.add_argument('-results', type=str, help='Dataset path', required=True)
    parser.add_argument('-gt', type=str, help='Ground truth path', required=True)
    parser.add_argument('-output', type=str, help='Save path', required=False)
    parser.add_argument('-latency_output', type=str, help='Latency Save path', required=False)
    parser.add_argument('-slam_output', type=str, help='Slam Save path', required=False)

    # Parse arguments
    args = parser.parse_args()
    results_path=args.results
    gt_path=args.gt
    save_path=args.output
    latency_save_path=args.latency_output
    slam_save_path=args.slam_output
        
    dataset_dirs =[name for name in os.listdir(results_path) if os.path.isdir(os.path.join(results_path, name))] 
    gt_dirs=[name for name in os.listdir(gt_path) if os.path.isdir(os.path.join(gt_path, name))]

    dataset_dirs = sorted(dataset_dirs, key=lambda x: int(re.search(r'(\d+)$', x).group()))

    results_vec=[]
    latency_vec=[]
    slam_vec=[]
    #print(dataset_dirs)
    #print(gt_dirs)

    for idx, est_dir in enumerate(dataset_dirs):
        root_name=est_dir.split("-")[0]
        if(len(est_dir.split("-")) > 1):
            experiment_idx = est_dir.split("-")[1]
        else:
            experiment_idx=0

        gt_filepath = os.path.join(gt_path, root_name, "gt.txt")
        
        est_dir = os.path.join(results_path, est_dir, "monocular")
        est_filepath = os.path.join(est_dir, "Trajectory-TR.txt")
        if not os.path.isfile(est_filepath):
            continue
        ape_stats, est_traj_info, ref_traj_info = calculate_ape(gt_filepath, est_filepath)

        device_dirs =[name for name in os.listdir(est_dir) if os.path.isdir(os.path.join(est_dir, name))] 

        results_dict={
                "full_name": est_dir,
                "dataset": root_name,
                "idx": experiment_idx,
                "gt_duration": ref_traj_info["duration (s)"],
                "gt_length": ref_traj_info["path length (m)"],
                "est_duration": est_traj_info["duration (s)"],
                "est_length": est_traj_info["path length (m)"],
                "duration_succes": round(est_traj_info["duration (s)"] / ref_traj_info["duration (s)"],2), 
                "ape_mean_traj": ape_stats["mean"],
                "ape_min_traj": ape_stats["min"],
                "ape_max_traj": ape_stats["max"],
                "ape_rmse_traj": ape_stats["rmse"],
                "ape_std_traj": ape_stats["std"],
                }

        latency_dict={
                "full_name": est_dir,
                "dataset": root_name,
                "idx": experiment_idx,
                }
        slam_dict={
                "full_name": est_dir,
                "dataset": root_name,
                "idx": experiment_idx,
                }

        for kf_traj in ["TR", "LM", "LC"]:
            est_filepath = os.path.join(est_dir, f"KeyFrameTrajectory-{kf_traj}.txt")
            if os.path.isfile(est_filepath):
                ape_stats, _, _ = calculate_ape(gt_filepath, est_filepath)
                results_dict[f"ape_mean_{kf_traj}_kf_traj"] = ape_stats["mean"]
                results_dict[f"ape_min_{kf_traj}_kf_traj"] = ape_stats["min"]
                results_dict[f"ape_max_{kf_traj}_kf_traj"] = ape_stats["max"]
                results_dict[f"ape_rmse_{kf_traj}_kf_traj"] = ape_stats["rmse"]
                results_dict[f"ape_std_{kf_traj}_kf_traj"] = ape_stats["std"]

            kf_pub_filepath = os.path.join(est_dir, kf_traj, f"KeyFramePublishTime-{kf_traj}.txt")
            if os.path.isfile(kf_pub_filepath):
                kf_pub_stats = calculate_kf_pub_metrics(kf_pub_filepath)
                results_dict[f"kf_pub_mean_total_{kf_traj}"] = kf_pub_stats["mean_total"]
                results_dict[f"kf_pub_mean_freq_{kf_traj}"] = kf_pub_stats["mean_fr"]
                results_dict[f"kf_pub_std_freq_{kf_traj}"] = kf_pub_stats["std_fr"]


            kf_sub_filepath = os.path.join(est_dir, kf_traj, f"KeyFrameSubscribeTime-{kf_traj}.txt")
            if os.path.isfile(kf_sub_filepath):
                kf_sub_stats = calculate_kf_sub_metrics(kf_sub_filepath)
                results_dict[f"kf_sub_mean_total_{kf_traj}"] = kf_sub_stats["mean_total"]

            map_pub_filepath = os.path.join(est_dir, kf_traj, f"MapPublishTime-{kf_traj}.txt")
            if os.path.isfile(map_pub_filepath):
                map_pub_stats = calculate_map_pub_metrics(map_pub_filepath)
                results_dict[f"map_pub_mean_total_{kf_traj}"] = map_pub_stats["mean_total"]
                results_dict[f"map_pub_mean_freq_{kf_traj}"] = map_pub_stats["mean_fr"]
                results_dict[f"map_pub_std_freq_{kf_traj}"] = map_pub_stats["std_fr"]


            atlas_pub_filepath = os.path.join(est_dir, kf_traj, f"AtlasPublishTime-{kf_traj}.txt")
            if os.path.isfile(atlas_pub_filepath):
                atlas_pub_stats = calculate_map_pub_metrics(atlas_pub_filepath)
                results_dict[f"atlas_pub_mean_total_{kf_traj}"] = atlas_pub_stats["mean_total"]
                results_dict[f"atlas_pub_mean_freq_{kf_traj}"] = atlas_pub_stats["mean_fr"]
                results_dict[f"atlas_pub_std_freq_{kf_traj}"] = atlas_pub_stats["std_fr"]


            #lba_filepath = os.path.join(est_dir, kf_traj, f"LBA_Stats-{kf_traj}.txt")
            #if os.path.isfile(lba_filepath):
            #    lba_stats = calculate_LBA_stats(lba_filepath)
            #    if lba_stats:
            #        slam_dict["lba_mean_times"] = lba_stats["mean_times"]
            #        slam_dict["lba_mean_edges"] = lba_stats["mean_edges"]
            #        slam_dict["lba_mean_opt_kf"] = lba_stats["mean_opt_kf"]

            exec_filepath = os.path.join(est_dir, kf_traj, f"ExecMean-{kf_traj}.txt")
            if(os.path.isfile(exec_filepath)):
                exec_results_dict = parse_exec_file(exec_filepath) #means, count

                if exec_results_dict:
                    exec_means_df = exec_results_dict["means"]
                    for metric, row in exec_means_df.iterrows():
                            mean_val = row["mean"]
                            std_val = row["std"]
                            if not mt.isnan(mean_val):
                                slam_dict[f"{metric}_mean_{kf_traj}"] = mean_val
                                slam_dict[f"{metric}_std_{kf_traj}"] = std_val

                    exec_counts_df = exec_results_dict["counts"]
                    for metric, row in exec_counts_df.iterrows():
                            val = row["value"]
                            if not mt.isnan(val) and val != 0:
                                slam_dict[f"{metric}_{kf_traj}"] = val


            for domain in ["KeyFrame", "Map", "Atlas"]:
                latency_filepath = os.path.join(est_dir, kf_traj, f"{domain}LatencyTime-{kf_traj}.txt")

                if os.path.isfile(latency_filepath):
                    latency_stats = calculate_latency(latency_filepath)
                    
                    if not latency_stats:
                        continue

                    latency_dict[f"{domain}-{kf_traj}_latency_min"] = latency_stats["min"]
                    latency_dict[f"{domain}-{kf_traj}_latency_mean"] = latency_stats["mean"]
                    latency_dict[f"{domain}-{kf_traj}_latency_std"] = latency_stats["std"]
                    latency_dict[f"{domain}-{kf_traj}_latency_max"] = latency_stats["max"]


        for device_dir in device_dirs:
            if device_dir in ["TR", "LM", "LC"]:
                cpu_file_path = os.path.join(est_dir, device_dir, f"SystemStats-{device_dir}.txt")
                if not os.path.isfile(cpu_file_path):
                    continue
                print(cpu_file_path)
                cpu_stats = calculate_cpu_util(cpu_file_path)

                results_dict[f"{device_dir}_cpu_min"] = cpu_stats["min"]
                results_dict[f"{device_dir}_cpu_mean"] = cpu_stats["mean"]
                results_dict[f"{device_dir}_cpu_max"] = cpu_stats["max"]
                results_dict[f"{device_dir}_cpu_median"] = cpu_stats["median"]
                results_dict[f"{device_dir}_cpu_std"] = cpu_stats["std"]
                

        slam_vec.append(slam_dict)
        latency_vec.append(latency_dict)
        results_vec.append(results_dict)

    # Creates DataFrame.
    df = pd.DataFrame(results_vec)
    df = calculate_dataset_means(df) 
    #df = df.set_index("full_name")
    #df = df.sort_index()

    # Creates DataFrame.
    latency_df = pd.DataFrame(latency_vec)
    latency_df = calculate_dataset_means(latency_df) 
    #latency_df = latency_df.set_index("full_name")
    #latency_df = latency_df.sort_index()


    slam_df = pd.DataFrame(slam_vec)
    slam_df = calculate_dataset_means(slam_df) 
    #slam_df = slam_df.set_index("full_name")
    #slam_df = slam_df.sort_index()
    # Print the data
    #print(df)

    if save_path:
        print(f"saving stats to path={save_path}")
        df.to_csv(save_path, index=False)
    if latency_save_path:
        print(f"saving latency stats to path={latency_save_path}")
        latency_df.to_csv(latency_save_path, index=False)
    if slam_save_path:
        print(f"saving slam stats to path={slam_save_path}")
        slam_df.to_csv(slam_save_path, index=False)


    



# If this script is executed, run the main function.
if __name__ == "__main__":
    main()
