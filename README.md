#讯飞语音HTTP服务

`HTTP接口` `docker` 目前仅支持语音转文字，包含流程：音频下载 -> 音频转码 -> 音频听写

##运行

```
#先将你的libmsc64.so拷贝到此目录
#调整docker-compose.yml中的appId跟libmsc64.so对应

docker-compose up
```
