<!--
 * @Author: chriswoodcn
 * @Email: chriswoodcn@aliyun.com
 * @Date: 2023-11-02 15:06:49
 * @LastEditors: chriswoodcn
 * @LastEditTime: 2023-11-09 12:53:16
 * @Description: 
 * 
 * Copyright (c) 2023 by chriswoodcn, All Rights Reserved. 
-->
# 3dtile 本地部署资源
## 部署
~~~shell
# cd 到server目录下
npm install http-server -g
http-server -a localhost -p 8003 --cors=http://localhost
~~~
## 导入
```text
url写法 http://localhost:8003/(server dir path to tileset.json)/tileset.json
```