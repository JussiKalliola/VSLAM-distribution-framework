float32[16] m_cap_tcw         # Sophus::SE3<float> mTcw represented as a 4x4 transformation matrix
float32[9] m_rwc          # Eigen::Matrix<float,3,3> mRwc represented as a 3x3 rotation matrix
float32[3] m_ow           # Eigen::Matrix<float,3,1> mOw represented as a 3-element vector
float32[9] m_rcw          # Eigen::Matrix<float,3,3> mRcw represented as a 3x3 rotation matrix
float32[3] m_tcw          # Eigen::Matrix<float,3,1> mtcw represented as a 3-element vector
bool mb_has_pose           # mbHasPose represented as a boolean

# Sophus::SE3<float> mTlr and mTrl - Unable to directly represent in a ROS 2 message

float32[9] m_rlr          # Eigen::Matrix<float,3,3> mRlr represented as a 3x3 rotation matrix
float32[3] m_tlr          # Eigen::Vector3f mtlr represented as a 3-element vector

float32[3] m_vw           # Eigen::Vector3f mVw represented as a 3-element vector
bool mb_has_velocity       # mbHasVelocity represented as a boolean

# Vocabulary, ORBextractor, and other pointers - Unable to directly represent in a ROS 2 message

float64 m_time_stamp       # double mTimeStamp represented as a floating-point number

float32[9] m_k            # cv::Mat mK represented as a 3x3 float matrix
float32[9] m_k_p           # Eigen::Matrix3f mK_ represented as a 3x3 float matrix
float32 fx              # static float fx represented as a floating-point number
float32 fy              # static float fy represented as a floating-point number
float32 cx              # static float cx represented as a floating-point number
float32 cy              # static float cy represented as a floating-point number
float32 invfx           # static float invfx represented as a floating-point number
float32 invfy           # static float invfy represented as a floating-point number
float32[5] dist_coef    # cv::Mat mDistCoef represented as a 5-element float array

float32 mbf             # float mbf represented as a floating-point number
float32 mb              # float mb represented as a floating-point number
float32 th_depth        # float mThDepth represented as a floating-point number

int32 n                 # int N represented as an integer number

# std::vector<cv::KeyPoint> mvKeys, mvKeysRight - Unable to directly represent in a ROS 2 message


# Corresponding stereo coordinate and depth for each keypoint.
# std::vector<MapPoint*> mvpMapPoints;
# "Monocular" keypoints have a negative value.
float32[] mvu_right     # std::vector<float> mvuRight;
float32[] mv_depth      # std::vector<float> mvDepth;

# Bag of Words Vector structures.
                        # DBoW2::BowVector mBowVec;
                        # DBoW2::FeatureVector mFeatVec;

# ORB descriptor, each row associated to a keypoint.
                        #cv::Mat mDescriptors, mDescriptorsRight;

# MapPoints associated to keypoints, NULL pointer if no association.
# Flag to identify outlier associations.
bool[] mvb_outlider    #std::vector<bool> mvbOutlier;
int32 mn_close_mps     #int mnCloseMPs;

# Keypoints are assigned to cells in a grid to reduce matching complexity when projecting MapPoints.
float32 mf_grid_element_width_inv     #static float mfGridElementWidthInv;
float32 mf_gird_element_height_inv    #static float mfGridElementHeightInv;
                                      #std::vector<std::size_t> mGrid[FRAME_GRID_COLS][FRAME_GRID_ROWS];

                                      #IMU::Bias mPredBias;

# IMU bias
                                      #IMU::Bias mImuBias;

# Imu calibration
                                      #IMU::Calib mImuCalib;

# Imu preintegration from last keyframe
                                      # IMU::Preintegrated* mpImuPreintegrated;
KeyFrame mp_last_keyframe             #KeyFrame* mpLastKeyFrame;

# Pointer to previous frame
                                      #Frame* mpPrevFrame;
                                      #IMU::Preintegrated* mpImuPreintegratedFrame;

#Current and Next Frame id.
uint64 n_next_id                      #static long unsigned int nNextId;
uint64 mn_id                          #long unsigned int mnId;

# Reference Keyframe. 
KeyFrame mp_reference_kf              #KeyFrame* mpReferenceKF;

# Scale pyramid info.
int32 mn_scale_levels                 #int mnScaleLevels;
float32 mf_scale_factor               #float mfScaleFactor;
float32 mg_log_scale_factor           #float mfLogScaleFactor;
float32[] mv_scale_factors            #vector<float> mvScaleFactors;
float32[] mv_inv_scale_factors        #vector<float> mvInvScaleFactors;
float32[] mv_level_sigma_two          #vector<float> mvLevelSigma2;
float32[] mv_inv_level_sigma_two      #vector<float> mvInvLevelSigma2;

# Undistorted Image Bounds (computed once).
float32 mn_min_x                      #static float mnMinX;
float32 mn_max_x                      #static float mnMaxX;
float32 mn_min_y                      #static float mnMinY;
float32 mn_max_y                      #static float mnMaxY;

bool mb_initial_computations          #static bool mbInitialComputations;

                                      #map<long unsigned int, cv::Point2f> mmProjectPoints;
                                      #map<long unsigned int, cv::Point2f> mmMatchedInImage;

string m_name_file                    #string mNameFile;

int32 mn_dataset                      #int mnDataset;

#ifdef REGISTER_TIMES
float64 m_time_orb_ext                #double mTimeORB_Ext;
float64 m_time_stereo_match           #double mTimeStereoMatch;
#endif



# ------------------------------------------------------------------------------------------
# private:

# Undistort keypoints given OpenCV distortion parameters.
# Only for the RGB-D case. Stereo must be already rectified!
# (called in the constructor).
#void UndistortKeyPoints();

# Computes image bounds for the undistorted image (called in the constructor).
# void ComputeImageBounds(const cv::Mat &imLeft);

# Assign keypoints to the grid for speed up feature matching (called in the constructor).
# void AssignFeaturesToGrid();

bool mb_is_set                      #bool mbIsSet;

bool mb_imu_pre_integrated          #bool mbImuPreintegrated;

                                    # std::mutex *mpMutexImu;




# ----------------------------------------------------------------------------------------------
# public:
                                    #GeometricCamera* mpCamera, *mpCamera2;

#Number of KeyPoints extracted in the left and right images
int32 n_left                        #int Nleft, Nright;
int32 n_right
#Number of Non Lapping Keypoints
int32 mono_left                     #int monoLeft, monoRight;
int32 mono_right

#For stereo matching
int32[] mv_left_to_right_match      #std::vector<int> mvLeftToRightMatch, mvRightToLeftMatch;
int32[] mv_right_to_left_match

# For stereo fisheye matching
                                    #static cv::BFMatcher BFmatcher;

# Triangulated stereo observations using as reference the left camera. These are
# computed during ComputeStereoFishEyeMatches
                                    #std::vector<Eigen::Vector3f> mvStereo3Dpoints;

# Grid for the right image
                                    #std::vector<std::size_t> mGridRight[FRAME_GRID_COLS][FRAME_GRID_ROWS];


# Stereo fisheye
# void ComputeStereoFishEyeMatches();

# bool isInFrustumChecks(MapPoint* pMP, float viewingCosLimit, bool bRight = false);

# Eigen::Vector3f UnprojectStereoFishEye(const int &i);

                                    # cv::Mat imgLeft, imgRight;

                                    # Sophus::SE3<double> T_test;
