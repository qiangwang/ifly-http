FROM openjdk:7-jdk

RUN wget http://mirrors.163.com/.help/sources.list.jessie -O /etc/apt/sources.list \
    && apt-get update

RUN apt-get install -y --no-install-recommends ffmpeg

RUN curl -sL https://deb.nodesource.com/setup_8.x | bash - \
    && apt-get install -y --no-install-recommends nodejs

RUN apt-get install -y --no-install-recommends zip unzip

ENV GRADLE_VERSION 3.4
RUN mkdir /opt/gradle \
    && wget https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip \
    && unzip -d /opt/gradle gradle-${GRADLE_VERSION}-bin.zip \
    && ln -s /opt/gradle/gradle-${GRADLE_VERSION}/bin/gradle /bin/gradle \
    && rm gradle-${GRADLE_VERSION}-bin.zip

RUN mkdir /opt/ifly-cli \
    && wget https://github.com/qiangwang/ifly-cli/archive/v1.0.zip \
    && unzip v1.0.zip \
    && rm v1.0.zip \
    && cd ifly-cli-1.0 \
    && gradle build \
    && cp build/libs/ifly-cli.jar /opt/ifly-cli/Cli.jar \
    && cp -r binLib /opt/ifly-cli \
    && cd .. \
    && rm -r ifly-cli-1.0

COPY . /data/app/

WORKDIR /data/app/

RUN npm install

RUN cp ./clean.sh /etc/cron.daily/ifly-clean.sh
