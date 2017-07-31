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

ENV IFLY_CLI_VERSION 0.1
RUN mkdir /opt/ifly-cli \
    && wget https://github.com/qiangwang/ifly-cli/archive/${IFLY_CLI_VERSION}.zip \
    && unzip ${IFLY_CLI_VERSION}.zip \
    && rm ${IFLY_CLI_VERSION}.zip \
    && cd ifly-cli-${IFLY_CLI_VERSION} \
    && gradle build \
    && cp build/libs/ifly-cli.jar /opt/ifly-cli/Cli.jar \
    && cd .. \
    && rm -r ifly-cli-${IFLY_CLI_VERSION}

COPY . /data/app/

WORKDIR /data/app/

RUN npm install

RUN cp ./clean.sh /etc/cron.daily/ifly-clean.sh
