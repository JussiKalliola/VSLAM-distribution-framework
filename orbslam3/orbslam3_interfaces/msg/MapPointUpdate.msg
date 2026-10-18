

##################################################
#   This is minified version of MP message
#   which should be used if just update is needed
##################################################

string system_id

uint64 mn_id
string m_str_hex_id

int32 n_obs

int64 mp_host_kf_id

uint32 mn_origin_map_id

# Position in absolute coordinates
geometry_msgs/Vector3 m_world_pos

# Keyframes observing the point and associated index in keyframe
# This is captured by backup observations
#KeyValuePair[] m_observations # std::map<KeyFrame*, std::tuple<int,int>> m_observations

# For save relation without pointer, this is necessary for save/load function
IntTuple[] m_backup_observations_id1 # std::map<long unsignet int, int> m_backup_observations_id1 # maybe do another msg type with uint64, int and make this as array
IntTuple[] m_backup_observations_id2 # std::map<long unsigned int, int> m_backup_observations_id2

# Mean viewing direction
geometry_msgs/Vector3 m_normal_vector

# Best Descriptor to fast matching
sensor_msgs/Image m_descriptor

# Refernce KeyFrame
int64 m_backup_ref_kf_id

# Tracking counters
int32 mn_visible
int32 mn_found

# Bad flag (we do not currently erase MapPoint from memory)
bool mb_bad

# For save relation without pointer, this is necessary for save/load function
string m_backup_replaced_id

# Scale invariance distances
float32 mf_min_distance
float32 mf_max_distance

int64 mp_map_id

uint16 mn_last_module
