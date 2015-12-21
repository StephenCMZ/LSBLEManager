//
//  STBLEManager.m
//  STBLEManager
//
//  Created by StephenChen on 15/6/3.
//  Copyright (c) 2015年 Lansion. All rights reserved.
//

#import "STBLEManager.h"

@implementation STBLEManager

static NSString *_serviceUUID;
static NSString *_outputCharacteristicUUID;
static NSString *_inputCharacteristicUUID;

static CBPeripheral *_peripheral;//连接的设备信息
static CBCharacteristic *_inputCharacteristic;//连接的设备特征（通道）输入
static CBCharacteristic *_outPutcharacteristic;//连接的设备特征（通道）输出
static CBService *_service;//当前服务

static CBCentralManager *_centralManager;
static STBLEManager *_instance;

NSMutableArray *_mPeripherals;//找到的设备
BOOL _isReConnect = NO;

static enum STBLConnectStatue _connectStatue;

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
                     andInputCharacteristicUUID:(NSString *)inputcharacteristicUUID{
    
    if (serviceUUID == nil || (outputcharacteristicUUID == nil || inputcharacteristicUUID == nil)){
        
        if (_instance != nil) {
            return _instance;
        }
        
        return nil;
    }
    
    if (_instance != nil) {
        return _instance;
    } else {
        
        _instance = [[STBLEManager alloc] init];
        
        _connectStatue = STBLConnectStatue_connect_dis;
        
        _serviceUUID = serviceUUID;
        _outputCharacteristicUUID = outputcharacteristicUUID;
        _inputCharacteristicUUID = inputcharacteristicUUID;
        
        _isReConnect = NO;
        _centralManager = [[CBCentralManager alloc]initWithDelegate:_instance queue:nil];
        
    }
    
    return _instance;
}


/**
 *  查找设备
 *
 *  @param peripherals 设备信息
 */
- (void)scanDevice{
    
    NSLog(@"搜索设备");
    if (_centralManager) {
        [_centralManager stopScan];
        _mPeripherals = [[NSMutableArray alloc]init];
        [_centralManager scanForPeripheralsWithServices:nil options:nil];
        if (self.delegate) {
            _connectStatue = STBLConnectStatue_connect_search;
            [self.delegate updateConnectStatue:_connectStatue];
        }
    }
}

/**
 *  停止查找设备
 *
 */
- (void)stopScanningDevice{
    NSLog(@"停止搜索设备");
    if (_centralManager) {
        [_centralManager stopScan];
    }
}

/**
 *  找到设备
 */
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI{
    
    NSLog(@"decice %@",peripheral);
//    NSLog(@"advertisementData %@",advertisementData);
//    NSLog(@"%@",RSSI);
    
    if (![_mPeripherals containsObject:peripheral]) {
        [_mPeripherals addObject:peripheral];
        if (self.delegate) {
            [self.delegate updatePeripheral:[_mPeripherals copy]];
        }
    }
    
    if (_isReConnect) {
        [self connectDevice];
        _isReConnect = NO;
    }
}


/**
 *  连接设备
 *
 *  @param peripheral    设备信息
 */
-(void)connectDeviceWithCBPeripheral:(CBPeripheral *)peripheral{
    
    if (peripheral == nil) {
        if (self.delegate) {
            _connectStatue = STBLConnectStatue_connect_fail;
            [self.delegate updateConnectStatue:_connectStatue];
        }
        return;
    }
    
    if (self.delegate) {
        _connectStatue = STBLConnectStatue_connect_device;
        [self.delegate updateConnectStatue:_connectStatue];
    }
    
    _peripheral = peripheral;
    [self connectDevice];
}

/**
 * 连接设备
 */
-(void)connectDevice{
    [_centralManager stopScan];
    _centralManager.delegate = self;
    [_centralManager connectPeripheral:_peripheral options:nil];
}

/**
 * 连接成功
 */
-(void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral{
    
    if (self.delegate) {
        _connectStatue = STBLConnectStatue_connect_ing;
        [self.delegate updateConnectStatue:_connectStatue];
    }
    
    [peripheral setDelegate:self];
//    [peripheral discoverServices:@[[CBUUID UUIDWithString:_serviceUUID]]];//开始查找服务
    [peripheral discoverServices:nil];
    
}

/**
 * 发现服务
 */
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error{
    
    if (error){
        NSLog(@"发现服务： %@ 错误： %@", peripheral.name, [error localizedDescription]);
        
        if (self.delegate) {
            _connectStatue = STBLConnectStatue_service_fail;
            [self.delegate updateConnectStatue:_connectStatue];
        }
        
        return;
    }
    
    NSLog(@"发现服务：%@",peripheral.services);
    
    for (CBService *service in peripheral.services) {
        if ([service.UUID isEqual:[CBUUID UUIDWithString:_serviceUUID]]) {

            if (self.delegate) {
                _connectStatue = STBLConnectStatue_service_ing;
                [self.delegate updateConnectStatue:_connectStatue];
            }
        
            _service = service;
            [peripheral discoverCharacteristics:nil forService:service];//开始查找特征
        }
        
    }
}

/**
 * 发现特征
 */
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error{
    
    if (error){
        if (self.delegate) {
            _connectStatue = STBLConnectStatue_characteristics_fail;
            [self.delegate updateConnectStatue:_connectStatue];
        }
        NSLog(@"发现特征： %@ 错误: %@", peripheral.name, [error localizedDescription]);
        return;
    }
    
    NSLog(@"发现特征：%@",service.characteristics);
    
    for (CBCharacteristic *characteristic in service.characteristics){
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:_outputCharacteristicUUID]]) {
            if (self.delegate) {
                _connectStatue = STBLConnectStatue_characteristics_ing;
                [self.delegate updateConnectStatue:_connectStatue];
            }
            _outPutcharacteristic = characteristic;
        }else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:_inputCharacteristicUUID]]) {
            _peripheral.delegate = self;
            _inputCharacteristic = characteristic;
            [_peripheral setNotifyValue:YES forCharacteristic:_inputCharacteristic];//开启通道监听
        }
    }
}


#pragma mark - 发送接收 -

/**
 *  发送消息
 *
 *  @param msg  消息
 */
-(void)sendMsg:(NSData* )msg{
    
    NSLog(@"msg %@",msg);
    
    if (msg == nil || _outPutcharacteristic == nil) {
        //        _writeStatue(@"-1");
        return;
    }
    _peripheral.delegate = self;
    [_peripheral writeValue:msg forCharacteristic:_outPutcharacteristic type:CBCharacteristicWriteWithResponse];
}


/**
 * 接收数据
 */
-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    
    if (error) {
        //        _writeStatue(@"-1");
        NSLog(@"接收数据错误：%@",[error localizedDescription]);
        return;
    }
    
    NSLog(@"接收到的数据：%@",characteristic.value);
    
    if (characteristic.value != nil) {
        //        _writeStatue([[NSString alloc]initWithData:characteristic.value encoding:NSUTF8StringEncoding]);
    }
    
    [self.delegate receivedMessage:characteristic.value];
}


#pragma mark - 连接状态处理 -

/**
 * 手机蓝牙状态 0，未知 1，重置中 2，不支持 3，非法 4，关闭 5，开启
 */
-(void)centralManagerDidUpdateState:(CBCentralManager *)central{
    NSLog(@"手机蓝牙状态为 %d", (int)central.state);
    
    _connectStatue = STBLConnectStatue_connect_dis;
    
    if (self.delegate) {
        [self.delegate updateStatue:(int)central.state];
    }
}

/**
 * 蓝牙断开
 */
-(void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    if (self.delegate) {
        _connectStatue = STBLConnectStatue_connect_dis;
        [self.delegate updateConnectStatue:_connectStatue];
    }
}

/**
 *  断开连接
 */
-(void)disconnectDevice{
    if (_peripheral != nil) {
        [_centralManager cancelPeripheralConnection:_peripheral];
    }
}

/**
 * 重新连接
 */
-(void)reConnectDevice{
    if (_peripheral != nil) {
        [_centralManager cancelPeripheralConnection:_peripheral];
    }
}

/**
 * 重新发现服务
 */
-(void)reDiscoverServices{
    if (_peripheral == nil || _serviceUUID == nil) {
        if (self.delegate) {
            _connectStatue = STBLConnectStatue_service_fail;
            [self.delegate updateConnectStatue:_connectStatue];
        }
        return;
    }
    
    [_peripheral setDelegate:self];
    [_peripheral discoverServices:@[[CBUUID UUIDWithString:_serviceUUID]]];//开始查找服务
}

/**
 * 重新发现特征（通道）
 */
-(void)reDiscoverCharacteristics{
    if (_peripheral == nil ||  (_outputCharacteristicUUID == nil || _inputCharacteristicUUID == nil) || _service == nil) {
        if (self.delegate) {
            _connectStatue = STBLConnectStatue_characteristics_fail;
            [self.delegate updateConnectStatue:_connectStatue];
        }
        return;
    }
    
    [_peripheral discoverCharacteristics:nil forService:_service];//开始查找特征
}

/**
 *  获取蓝牙连接状态
 */
- (enum STBLConnectStatue)getConnectStatue{
    return _connectStatue;
}

/**
 *  清空蓝牙管理
 */
- (void)stopBLEManager{
    [self stopScanningDevice];
    _instance = nil;
}
