
##################################################
#   This is minified version of KF message
#   which should be used if just update is needed
##################################################


std_msgs/Header header

bool mb_process_data

string system_id

uint16 mn_target # 0=nowhere, 1=tracking, 2=LM, 3=LC
uint16 from_module_id # 0=idle, 1=tracking, 2=LM, 3=LC
uint16 mn_last_module

bool mb_lc_done

uint64 mn_id

# Variables used by the keyframe database
uint64 mn_reloc_query
int32 mn_reloc_words
float32 mn_reloc_score
uint64 mn_place_recognition_query
int32 mn_place_recognition_words
float32 m_place_recognition_score

bool mb_current_place_recognition


#float32 mf_scale

# Pose relative to parent (this is computed when bad flag is activated)
geometry_msgs/Pose m_tcp #Sophus::SE3f mTcp;

uint32 mn_origin_map_id

geometry_msgs/Pose m_tcw #Sophus::SE3<float> mTcw;
geometry_msgs/Quaternion m_rcw #Eigen::Matrix3f mRcw;

# MapPoints associated to keypoints
MapPoint[] mvp_map_points #std::vector<MapPoint*> mvpMapPoints;
# For save relation without pointer, this is necessary for save/load function
string[] mv_backup_map_points_id #std::vector<long long int> mvBackupMapPointsId;

uint64[] mvp_ordered_connected_keyframes_id #std::vector<KeyFrame*> mvpOrderedConnectedKeyFrames;

int32[] mv_ordered_weights #std::vector<int> mvOrderedWeights;

IntTuple[] m_backup_connected_keyframe_id_weights 

# For save relation without pointer, this is necessary for save/load function
int64 m_backup_parent_id #long long int mBackupParentId;
uint64[] mv_backup_childrens_id #std::vector<long unsigned int> mvBackupChildrensId;

# Bad flags
bool mb_not_erase #bool mbNotErase;
bool mb_to_be_erased #bool mbToBeErased;
bool mb_bad #bool mbBad;    

uint64 mp_map_id
bool b_new_map_created

# Backup variables for inertial
int64 m_backup_prev_kf_id #long long int mBackupPrevKFId;
int64 m_backup_next_kf_id #long long int mBackupNextKFId;
