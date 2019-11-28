FROM ubuntu:20.04

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && \ 
    apt-get install libgl1-mesa-dev -y && \
    apt-get install zip -y && \
    apt install wget -y

RUN apt-get install openjdk-8-jre -y

RUN mkdir androidEmulator

WORKDIR /androidEmulator

RUN wget https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip && \
    unzip sdk-tools-linux-4333796.zip && \
    export sdkmanager=/androidEmulator/android-sdk-linux/tools

COPY ./run_tests.sh .

CMD bash ./run_tests.sh