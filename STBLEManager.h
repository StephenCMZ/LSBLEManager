//
//  STBLEManager.h
//  STBLEManager
//
//  Created by StephenChen on 15/6/3.
//  Copyright (c) 2015年 Lansion. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "BLEKeys.h"
#import "YzfBluetoothData.h"

//蓝牙状态
enum STBLStatue{
    STBLStatue_unknown = 0, //未知
    STBLStatue_resetting, //重置中
    STBLStatue_unsupport, //不支持
    STBLStatue_unlawful, //非法
    STBLStatue_colsed, //关闭
    STBLStatue_opened //开启
};

//蓝牙连接状态
enum STBLConnectStatue{
    STBLConnectStatue_connect_fail = 10, //失败
    STBLConnectStatue_connect_dis, //断开
    STBLConnectStatue_connect_search,//搜索中
    STBLConnectStatue_connect_device,//找到设备
    STBLConnectStatue_connect_ing, //连接中
    STBLConnectStatue_service_fail, //发现服务失败
    STBLConnectStatue_service_ing, //发现服务
    STBLConnectStatue_characteristics_fail, //发现特征（通道）失败
    STBLConnectStatue_characteristics_ing //发现特征（通道）
};


@protocol STBLEManagerDelegate <NSObject>
- (void)updatePeripheral:(NSArray *)peripherals;
- (void)updateStatue:(enum STBLStatue)statue;
- (void)updateConnectStatue:(enum STBLConnectStatue)connectStatue;
- (void)receivedMessage:(NSData*)msg;
@end


// 蓝牙使用步骤 ： 1，扫描蓝牙 2，连接蓝牙 3，发现蓝牙服务 4，发现该服务包含的特征（通道）5，握手(连接) 6，利用特征发送或接收消息

@interface STBLEManager : NSObject<CBCentralManagerDelegate,CBPeripheralDelegate>

@property (weak, nonatomic) id<STBLEManagerDelegate> delegate;

/**
 *  初始化
 *
 *  @param serviceUUID              服务UUID
 *  @param outputcharacteristicUUID 写出特征UUID
 *  @param inputcharacteristicUUID  读入特征UUID
 *
 *  @return STBLEManager
 */
+ (instancetype)initSTBLEManagerWithServiceUUID:(NSString *)serviceUUID
                   andOutputCharacteristicUUID:(NSString *)outputcharacteristicUUID
                    andInputCharacteristicUUID:(NSString *)inputcharacteristicUUID;


/**
 *  查找设备
 *
 *  @param peripherals 设备信息
 */
- (void)scanDevice;

/**
 *  停止查找设备
 *
 */
- (void)stopScanningDevice;

/**
 *  连接设备
 *
 *  @param peripheral    设备信息
 */
- (void)connectDeviceWithCBPeripheral:(CBPeripheral *)peripheral;

/**
 *  断开连接
 */
- (void)disconnectDevice;

/**
 * 重新连接
 */
- (void)reConnectDevice;

/**
 * 重新发现服务
 */
- (void)reDiscoverServices;

/**
 * 重新发现特征（通道）
 */
- (void)reDiscoverCharacteristics;

/**
 *  发送消息
 *
 *  @param msg  消息
 */
- (void)sendMsg:(NSData* )msg;

/**
 *  获取蓝牙连接状态
 */
- (enum STBLConnectStatue)getConnectStatue;

/**
 *  清空蓝牙管理
 */
- (void)stopBLEManager;

@end
