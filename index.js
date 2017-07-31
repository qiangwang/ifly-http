var express = require('express');
var app = express();
var shell = require('shelljs');
var md5 = require('md5');
var minimist = require('minimist')

var argv = minimist(process.argv.slice(2));
if (!argv.appId) {
    throw 'Usage: index.js --appId 讯飞语音appId'
}

var exec = function (cmd) {
    return new Promise(function (resolve, reject) {
        shell.exec(cmd.source, function (code, stdout, stderr) {
            if (code != 0) {
                reject(cmd);
                return;
            }

            resolve(stdout);
        });
    });
};

app.get('/audioToText', function (req, res) {
    var audioUrl = req.query.audioUrl;
    if (!audioUrl || audioUrl.length == 0) {
        res.json({error: '音频地址不能为空'});
        return;
    }

    var audioId = md5(audioUrl);

    var audioPath = '/tmp/' + audioId;
    var wavPath = '/tmp/' + audioId + '.wav';
    var textPath = '/tmp/' + audioId + '.txt';

    var cmds = {
        download: {
            name: '音频下载',
            source: 'curl "' + audioUrl + '" -o ' + audioPath
        },
        toWav: {
            name: '音频转码',
            source: 'ffmpeg -i ' + audioPath + ' -ac 1 -ar 16000 -acodec pcm_s16le -y ' + wavPath
        },
        toText: {
            name: '音频听写',
            source: 'java -Djava.library.path="/data/app" -jar /opt/ifly-cli/Cli.jar audioToText --appId ' + argv.appId + ' -i ' + wavPath + ' -o ' + textPath
        },
        readText: {
            name: '文本读取',
            source: 'cat ' + textPath
        }
    };

    exec(cmds.download).then(function (stdout) {
        return exec(cmds.toWav);
    }).then(function (stdout) {
        return exec(cmds.toText);
    }).then(function (stdout) {
        return exec(cmds.readText);
    }).then(function (stdout) {
        res.json({text: stdout});
    }).catch(function (cmd) {
        res.json({error: cmd.name + '失败'});
    });
});

app.listen(9000, function () {
    console.log('listening on port 9000');
});
