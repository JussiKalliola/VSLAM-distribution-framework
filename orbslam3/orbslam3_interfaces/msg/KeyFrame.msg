std_msgs/Header header

string system_id

string omnet_id
float64 send_time
bool mb_process_data

uint16 mn_target # 0=nowhere, 1=tracking, 2=LM, 3=LC
uint16 from_module_id # 0=idle, 1=tracking, 2=LM, 3=LC

bool mb_lc_done

# Public 1
bool b_imu

# public 2
uint64 n_next_id
uint64 mn_id
uint64 mn_frame_id #const

float64 m_time_stamp #const

# Grid (to speed up feature matching)
int32 mn_grid_cols #const
int32 mn_grid_rows #const
float32 mf_grid_element_width_inv # const
float32 mf_grid_element_height_inv # const

# Variables used by the tracking
uint64 mn_track_reference_for_frame
uint64 mn_fuse_target_for_kf

# Variables used by the local mapping
uint64 mn_ba_local_for_kf
uint64 mn_ba_fixed_for_kf

# Number of optimizations by BA (amount of iterations in BA)
uint64 mn_number_of_opt

# Variables used by the keyframe database
uint64 mn_loop_query
int32 mn_loop_words
float32 m_loop_score
uint64 mn_reloc_query
int32 mn_reloc_words
float32 mn_reloc_score
uint64 mn_merge_query
int32 mn_merge_words
float32 m_merge_score
uint64 mn_place_recognition_query
int32 mn_place_recognition_words
float32 m_place_recognition_score

bool mb_current_place_recognition

# Variables used by loop closing
geometry_msgs/Pose m_tcw_gba #Sophus::SE3f mTcwGBA;
geometry_msgs/Pose m_tcw_bef_gba #Sophus::SE3f mTcwBefGBA;
geometry_msgs/Vector3 m_vwb_gba
geometry_msgs/Vector3 m_vwb_bef_gba
IMUBias m_bias_gba #IMU::Bias mBiasGBA;
uint64 mn_ba_global_for_kf

# Variables used by merging
geometry_msgs/Pose m_tcw_merge #Sophus::SE3f mTcwMerge;
geometry_msgs/Pose m_tcw_bef_merge #Sophus::SE3f mTcwBefMerge;
geometry_msgs/Pose m_twc_bef_merge #Sophus::SE3f mTwcBefMerge;
geometry_msgs/Vector3 m_vwb_merge
geometry_msgs/Vector3 m_vwb_bef_merge
IMUBias m_bias_merge #IMU::Bias mBiasMerge;
uint64 mn_merge_corrected_for_kf
uint64 mn_merge_for_kf
float32 mf_scale_merge
uint64 mn_ba_local_for_merge

float32 mf_scale

# Calibration parameters
float32 fx
float32 fy
float32 cx
float32 cy
float32 invfx
float32 invfy
float32 mbf 
float32 mb 
float32 m_th_depth # const
sensor_msgs/Image m_dist_coef

# Number of KeyPoints
int32 n #const

# KeyPoints, stereo coordinate and descriptors (all associated by an index)
KeyPoint[] mv_keys #const std::vector<cv::KeyPoint> mvKeys;
KeyPoint[] mv_keys_un #const std::vector<cv::KeyPoint> mvKeysUn;
float32[] mvu_right #const std::vector<float> mvuRight; // negative value for monocular points
float32[] mv_depth #const std::vector<float> mvDepth; // negative value for monocular points
sensor_msgs/Image m_descriptors #const cv::Mat mDescriptors;

# BoW
BowVector[] m_bow_vec #DBoW2::BowVector mBowVec;
BowFeatureVector[] m_feat_vec #DBoW2::FeatureVector mFeatVec;

# Pose relative to parent (this is computed when bad flag is activated)
geometry_msgs/Pose m_tcp #Sophus::SE3f mTcp;

# Scale
int32 mn_scale_levels #const int mnScaleLevels;
float32 mf_scale_factor #const float mfScaleFactor;
float32 mf_log_scale_factor #const float mfLogScaleFactor;
float32[] mv_scale_factors #const std::vector<float> mvScaleFactors;
float32[] mv_level_sigma2  #const std::vector<float> mvLevelSigma2;
float32[] mv_inv_level_sigma2 #const std::vector<float> mvInvLevelSigma2;

# Image bounds and calibration
int32 mn_min_x #const int mnMinX;
int32 mn_min_y #const int mnMinY;
int32 mn_max_x #const int mnMaxX;
int32 mn_max_y #const int mnMaxY;

# Preintegrated IMU measurements from previous keyframe
#KeyFrame m_prev_kf
#KeyFrame m_next_kf

IMUPreintegrated mp_imu_preintegrated #IMU::Preintegrated* mpImuPreintegrated;
#IMU::Calib mImuCalib;

uint32 mn_origin_map_id

string m_name_file

int32 mn_dataset

uint64[] mvp_loop_cand_kfs_id
uint64[] mvp_merge_cand_kfs_id
#KeyFrame[] mvp_loop_cand_kfs #std::vector <KeyFrame*> mvpLoopCandKFs;
#KeyFrame[] mvp_merge_cand_kfs #std::vector <KeyFrame*> mvpMergeCandKFs;


# ------------------------------------------------------------------------
# protected

geometry_msgs/Pose m_tcw #Sophus::SE3<float> mTcw;
geometry_msgs/Quaternion m_rcw #Eigen::Matrix3f mRcw;
geometry_msgs/Pose m_twc #Sophus::SE3<float> mTwc;
geometry_msgs/Quaternion m_rwc #Eigen::Matrix3f mRwc;

# IMU position
geometry_msgs/Vector3 m_owb #Eigen::Vector3f mOwb;
# Velocity (Only used for inertial SLAM)
geometry_msgs/Vector3 m_vw #Eigen::Vector3f mVw;
bool mb_has_velocity

# Transformation matrix between cameras in stereo fisheye
geometry_msgs/Pose m_tlr #Sophus::SE3<float> mTlr;
geometry_msgs/Pose m_trl #Sophus::SE3<float> mTrl;

# Imu bias
IMUBias m_imu_bias #IMU::Bias mImuBias;

# MapPoints associated to keypoints
MapPoint[] mvp_map_points #std::vector<MapPoint*> mvpMapPoints;
# For save relation without pointer, this is necessary for save/load function
string[] mv_backup_map_points_id #std::vector<long long int> mvBackupMapPointsId;

# BoW
#KeyFrameDatabase mp_key_frame_db #KeyFrameDatabase* mpKeyFrameDB;
#ORBVocabulary* mpORBvocabulary;

# Grid over the image to speed up feature matching
Grid3D m_grid #std::vector< std::vector <std::vector<size_t> > > mGrid;

#std::map<KeyFrame*,int> mConnectedKeyFrameWeights;
uint64[] mvp_ordered_connected_keyframes_id #std::vector<KeyFrame*> mvpOrderedConnectedKeyFrames;

int32[] mv_ordered_weights #std::vector<int> mvOrderedWeights;

# For save relation without pointer, this is necessary for save/load function
#std::map<long unsigned int, int> mBackupConnectedKeyFrameIdWeights;
IntTuple[] m_backup_connected_keyframe_id_weights 

# Spanning Tree and Loop Edges
bool mb_first_connection #bool mbFirstConnection;
#KeyFrame mp_parent #KeyFrame* mpParent;
#KeyFrame[] msp_childrens #std::set<KeyFrame*> mspChildrens;
#KeyFrame[] msp_loop_edges #std::set<KeyFrame*> mspLoopEdges;
#KeyFrame[] msp_merge_edges #std::set<KeyFrame*> mspMergeEdges;

# For save relation without pointer, this is necessary for save/load function
int64 m_backup_parent_id #long long int mBackupParentId;
uint64[] mv_backup_childrens_id #std::vector<long unsigned int> mvBackupChildrensId;
uint64[] mv_backup_loop_edges_id #std::vector<long unsigned int> mvBackupLoopEdgesId;
uint64[] mv_backup_merge_edges_id #std::vector<long unsigned int> mvBackupMergeEdgesId;

# Bad flags
bool mb_not_erase #bool mbNotErase;
bool mb_to_be_erased #bool mbToBeErased;
bool mb_bad #bool mbBad;    

#float32 m_half_baseline #float mHalfBaseline; // Only for visualization

#Map mp_map #Map* mpMap;
uint64 mp_map_id
bool b_new_map_created

# Backup variables for inertial
int64 m_backup_prev_kf_id #long long int mBackupPrevKFId;
int64 m_backup_next_kf_id #long long int mBackupNextKFId;
IMUPreintegrated m_backup_imu_preintegrated #IMU::Preintegrated mBackupImuPreintegrated;

# Backup for Cameras
uint32 mn_backup_id_camera 
uint32 mn_backup_id_camera2 #unsigned int mnBackupIdCamera, mnBackupIdCamera2;

# Calibration
Matrix m_k_calib # Eigen::Matrix3f mK_;


uint16 mn_last_module

# Mutex
#std::mutex mMutexPose; // for pose, velocity and biases
#std::mutex mMutexConnections;
#std::mutex mMutexFeatures;
#std::mutex mMutexMap;

# public
#GeometricCamera* mpCamera, *mpCamera2;

# Indexes of stereo observations correspondences
int32[] mv_left_to_right_match
int32[] mv_right_to_left_match #std::vector<int> mvLeftToRightMatch, mvRightToLeftMatch;

#Sophus::SE3f GetRelativePoseTrl();
#Sophus::SE3f GetRelativePoseTlr();

# KeyPoints in the right image (for stereo fisheye, coordinates are needed)
KeyPoint[] mv_keys_right #const std::vector<cv::KeyPoint> mvKeysRight;

int32 n_left
int32 n_right #const int NLeft, NRight;

# Not needed for monocular. Check how to take nulls into consideration
#Grid3D m_grid_right #std::vector< std::vector <std::vector<size_t> > > mGridRight;
