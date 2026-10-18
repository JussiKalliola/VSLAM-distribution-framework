#IMU measurement (gyro, acc, and timestamp)
geometry_msgs/Vector3 acc
geometry_msgs/Vector3 gyro
float64 timestamp

# Bias
geometry_msgs/Vector3 bias_gyro
geometry_msgs/Vector3 bias_acc

# Calibration 
geometry_msgs/Pose m_tcb
geometry_msgs/Pose m_tbc
# Eigen::DiagonalMatrix<float,6> cov
# Eigen::DiagonalMatrix<float,6> cov_walk
bool mb_is_set

# Integration of 1 gyro measurement
float32 delta_t # integration time
# Eigen::Matrix3f delta_r
# Eigen::Matrix3f right_j # right jacobian

# Preintegration of Imu measurements
float32 d_t
# Eigen::Matrix<float,15,15> C;
# Eigen::Matrix<float,15,15> Info;
# Eigen::DiagonalMatrix<float,6> Nga, NgaWalk;

# Values for the original bias (when integration was computed)
# Bias b;
# Eigen::Matrix3f dR;
# Eigen::Vector3f dV, dP;
# Eigen::Matrix3f JRg, JVg, JVa, JPg, JPa;
geometry_msgs/Vector3 avg_a # Eigen::Vector3f avgA, avgW;
geometry_msgs/Vector3 avg_w

# private
# Bias bu
# Dif between original and updated bias
# This is used to compute the updated values of the preintegration
# Eigen::Matrix<float,6,1> db;
Integrable[] mv_measurements
