# LSBLEManager
一个简易的蓝牙管理器

##### 使用步骤：
- 将`LSBluetoothManager.h`和`LSBluetoothManager.m`拖入项目中
- 导入`LSBluetoothManager.h`
- 设置代理并获取蓝牙管理器
```
    @interface ConnectDeviceViewController ()<LSBluetoothManagerDelegate>
    LSBluetoothManager *bleManager = [LSBluetoothManager shareBLEManager]; 
    bleManager.delegate = self;
```
- 查找蓝牙
```
	// 查找蓝牙设备
	[bleManager scanDevice];

	// 查找到设备回调
	- (void)updateDevices:(NSArray *)devices{
		// devices 为 CBPeripheral 集合
	} 
```
- 连接蓝牙
```
	//连接蓝牙
	[_bleManager connectDeviceWithCBPeripheral:peripheral
                                andServiceUUID:SERVICEUUID
                   andOutputCharacteristicUUID:OUTPUTUUID
                    andInputCharacteristicUUID:INPUTUUID];

     // 连接状态回调
	- (void)updateStatue:(BLESTATUE)statue{}
```
- 收发数据
```
	//收到数据回调
	- (void)revicedMessage:(NSData *)msg{}
	//发送数据
	NSData data = [NSData dataWithBytes:@"89" length:1];
	[bleManager sendMsg:data];
```

