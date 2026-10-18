
std_msgs/Header header

# This is to identify messages between omnet and slam
string omnet_id
float64 send_time

bool mb_process_data

bool mb_first_batch

string system_id

uint16 from_module_id

uint64[] ms_bad_maps
#KeyFrame[] mvp_keyframe_origins           # vector<KeyFrame*> mvpKeyFrameOrigins;
uint64[] mv_backup_keyframe_origins_id    # vector<unsigned long int> mvBackupKeyFrameOriginsId;
uint64 mp_first_region_kf_id               # KeyFrame* mpFirstRegionKF;
                                          # std::mutex mMutexMapUpdate;

# This avoid that two points are created simultaneously in separate threads (id conflict)
                                          # std::mutex mMutexPointCreation;

bool mb_fail                              # bool mbFail;

# Size of the thumbnail (always in power of 2)
int32 thumb_width                         # static const int THUMB_WIDTH = 512;
int32 thumb_height                        # static const int THUMB_HEIGHT = 512;

uint64 n_next_id                          # static long unsigned int nNextId;

# DEBUG: show KFs which are used in LBA
uint64[] ms_opt_kfs                       # std::set<long unsigned int> msOptKFs;
uint64[] ms_fixed_kfs                     # std::set<long unsigned int> msFixedKFs;

# protected:

uint32 mn_id                              # long unsigned int mnId;

MapPoint[] msp_map_points                 # std::set<MapPoint*> mspMapPoints;
KeyFrameUpdate[] msp_keyframes                  # std::set<KeyFrame*> mspKeyFrames;

# Save/load, the set structure is broken in libboost 1.58 for ubuntu 16.04, a vector is serializated
string[] mvp_backup_map_points_ids          # std::vector<MapPoint*> mvpBackupMapPoints;
uint64[] mvp_backup_keyframes_ids           # std::vector<KeyFrame*> mvpBackupKeyFrames;

uint64[] mvp_erased_keyframe_ids
string[] mvp_erased_mappoint_ids

string[] mvp_updated_map_points_ids          # std::vector<MapPoint*> mvpBackupMapPoints;
uint64[] mvp_updated_keyframes_ids           # std::vector<KeyFrame*> mvpBackupKeyFrames;
#KeyFrame mp_kf_initial                    # KeyFrame* mpKFinitial;
#KeyFrame mp_kf_lower_id                   # KeyFrame* mpKFlowerID;

int64 mn_backup_kf_initial_id            # unsigned long int mnBackupKFinitialID;
int64 mn_backup_kf_lower_id              # unsigned long int mnBackupKFlowerID;

string[] mvp_reference_map_points_id       # std::vector<MapPoint*> mvpReferenceMapPoints;

bool mb_imu_initialized                   # bool mbImuInitialized;

int32 mn_map_change                       # int mnMapChange;
int32 mn_map_change_notified              # int mnMapChangeNotified;
 
uint64 mn_init_kf_id                      # long unsigned int mnInitKFid;
uint64 mn_max_kf_id                       # long unsigned int mnMaxKFid;
# long unsigned int mnLastLoopKFid;

# Index related to a big change in the map (loop closure, global BA)
int64 mn_big_change_idx                   # int mnBigChangeIdx;


# View of the map in aerial sight (for the AtlasViewer)
                                          # GLubyte* mThumbnail;

bool m_is_in_use                          # bool mIsInUse;
bool m_has_thumbnail                      # bool mHasTumbnail;
bool m_bad                                # bool mbBad = false;

bool mb_is_inertial                       # bool mbIsInertial;
bool mb_imu_ba1                           # bool mbIMU_BA1;
bool mb_imu_ba2                           # bool mbIMU_BA2;

# Mutex
# std::mutex mMutexMap;

