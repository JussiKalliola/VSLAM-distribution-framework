string system_id

# public

uint64 mn_id
string m_str_hex_id

uint64 n_next_id

int64 mn_first_kf_id
int64 mn_first_frame
int32 n_obs

# Variables used by the tracking
#float32 m_track_proj_x
#float32 m_track_proj_y
#float32 m_track_depth
#float32 m_track_depth_r
#float32 m_track_proj_xr
#float32 m_track_proj_yr
#bool mb_track_in_view
#bool mb_track_in_view_r
#int32 mn_track_scale_level
#int32 mn_track_scale_level_r
#float32 m_track_view_cos
#float32 m_track_view_cos_r
#uint64 mn_track_reference_for_frame
#uint64 mn_last_frame_seen

# Variables used by local mapping
#uint64 mn_ba_local_for_kf
#uint64 mn_fuse_candidate_for_kf

# Variables used by loop closing
#uint64 mn_loop_point_for_kf
#uint64 mn_corrected_by_kf
#uint64 mn_corrected_referece
#geometry_msgs/Vector3 m_pos_gba
#uint64 mn_ba_global_for_kf
#uint64 mn_ba_local_for_merge

# Variables used by merging
#geometry_msgs/Vector3 m_pos_merge
#geometry_msgs/Vector3 m_normal_vector_merge

# For inverse depth optimization
float64 m_inv_depth
float64 m_init_u
float64 m_init_v
#KeyFrame mp_host_kf
int64 mp_host_kf_id

# std::mutex m_global_mutex

uint32 mn_origin_map_id

# Protected
# Position in absolute coordinates
geometry_msgs/Vector3 m_world_pos

# Keyframes observing the point and associated index in keyframe
KeyValuePair[] m_observations # std::map<KeyFrame*, std::tuple<int,int>> m_observations

# For save relation without pointer, this is necessary for save/load function
IntTuple[] m_backup_observations_id1 # std::map<long unsignet int, int> m_backup_observations_id1 # maybe do another msg type with uint64, int and make this as array
IntTuple[] m_backup_observations_id2 # std::map<long unsigned int, int> m_backup_observations_id2

# Mean viewing direction
geometry_msgs/Vector3 m_normal_vector

# Best Descriptor to fast matching
#sensor_msgs/Image m_descriptor

# Refernce KeyFrame
#KeyFrame mp_ref_kf
int64 m_backup_ref_kf_id

# Tracking counters
int32 mn_visible
int32 mn_found

# Bad flag (we do not currently erase MapPoint from memory)
bool mb_bad
#MapPoint mp_replaced

# For save relation without pointer, this is necessary for save/load function
string m_backup_replaced_id

# Scale invariance distances
float32 mf_min_distance
float32 mf_max_distance

int64 mp_map_id
#Map mp_map

uint16 mn_last_module

# mutex
# std::mutex m_mutex_pos
# std::mutex m_mutex_features
# std::mutex m_mutex_map


#Map mp_map
#MapPoint mp_replaced
