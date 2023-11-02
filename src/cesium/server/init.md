# 3dtile 本地部署资源
## 部署
~~~shell
# cd 到server目录下
npm install http-server -g
http-server -a localhost -p 8003 --cors=http://localhost:5173/
~~~
## 导入
```text
url写法 http://localhost:8003/(server dir path to tileset.json)/tileset.json
```