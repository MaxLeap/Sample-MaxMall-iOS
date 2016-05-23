# Sample-MaxMall-iOS

使用步骤：

1、在maxleap.cn中创建app，记录appid和clientkey。

2、更换PrefixHeader.pch文件中以下宏定义为1中的的appid和clientkey：

	#define kMaxLeap_Application_ID 		CONFIGURE(@"your_app_id")
	#define kMaxLeap_Client_Key 			CONFIGURE(@"your_client_key")

3、程序中需要使用支付宝、微信或者银联支付，需要在MaxLeap后台的“应用设置”-“支付设置”中，设置支付宝、微信支付和银联支付的商户信息。

4、更新Info.plist文件中URL Types中支付宝和微信对应的设置。