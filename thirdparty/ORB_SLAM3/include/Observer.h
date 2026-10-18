#pragma once

#ifndef OBSERVER_H
#define OBSERVER_H

#include <set>
#include <string>
#include <vector>

#include "Thirdparty/Sophus/sophus/geometry.hpp"
#include "Thirdparty/Sophus/sophus/sim3.hpp"

#include <Eigen/Core>
#include <Eigen/Geometry>
#include <Eigen/Dense>

#include <ImuTypes.h>
//#include "KeyFrame.h"
//#include "Map.h"

namespace ORB_SLAM3
{
class KeyFrame;
class MapPoint;
class Map;

class Distributor {
  public:
        virtual void OnKeyframeAdded(KeyFrame* orb_slam_kf) = 0;
        virtual void OnKeyframeAdded(KeyFrame* orb_slam_kf, std::set<std::string> new_mp_ids) = 0;
        //virtual void onMapAdded(Map* pM) = 0;
        virtual void OnNewMap(ORB_SLAM3::Map* orb_slam_map) = 0;
        virtual void OnNewKeyFrame(ORB_SLAM3::KeyFrame* orb_slam_kf) = 0;
        virtual void OnNewMapPoint(ORB_SLAM3::MapPoint* orb_slam_mp) = 0;
        virtual void OnLocalMapUpdated(Map* orb_slam_map, int kf_batch_size) = 0;
        virtual void OnGlobalMapUpdated(bool is_merged, bool is_loop_closure, std::vector<unsigned long int> merged_map_ids) = 0;
        //virtual void onChangeLMActive(bool bActive) = 0;
        virtual void OnInterruptBA(const bool is_ba_interrupted) = 0;
        virtual void OnLocaLmappingIsBusy(const bool is_local_mapping_busy) = 0;
        virtual void OnLMResetRequested() = 0;
        virtual void OnLMStopRequest(const bool is_local_mapping_stopped) = 0;
        virtual void OnActiveMapReset(unsigned long int map_id) = 0;
        
        virtual int KeyFramesInQueue() = 0;
        virtual int MapsInQueue() = 0;
        virtual double GetCurrentTime() = 0;


        // Task module related
        virtual int GetTaskModule() = 0;

        virtual int GetWorkerNumber() = 0;
        virtual void RemoveWorker(unsigned int worker_module_id) = 0;

        virtual ~Distributor() {}
};

}// namespace ORB_SLAM

#endif // OBSERVER_H
