# Preintegration of Imu measurements
float32 d_t
Matrix c    # Eigen::Matrix<float,15,15> C;
Matrix info # Eigen::Matrix<float,15,15> Info;
Matrix nga  # Eigen::DiagonalMatrix<float,6> Nga, NgaWalk;
Matrix nga_walk

# Values for the original bias (when integration was computed)
IMUBias b
Matrix d_r # Eigen::Matrix3f dR;
geometry_msgs/Vector3 d_v 
geometry_msgs/Vector3 d_p # Eigen::Vector3f dV, dP; 
Matrix j_rg
Matrix j_vg 
Matrix j_va 
Matrix j_pg
Matrix j_pa # Eigen::Matrix3f JRg, JVg, JVa, JPg, JPa;
geometry_msgs/Vector3 avg_a
geometry_msgs/Vector3 avg_w # Eigen::Vector3f avgA, avgW;

# Updated bias 
IMUBias bu
# Dif between original and updated bias
# This is used to compute the updated values of the preintegration
Matrix db
