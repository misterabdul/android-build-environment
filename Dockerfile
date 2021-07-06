FROM frolvlad/alpine-glibc:alpine-3.13_glibc-2.33

LABEL author "Abdul Pasaribu <abdoelrachmad@gmail.com>"

# Update current packages
RUN apk update

# Install all necessary packages
RUN apk add libstdc++ \
  openjdk11 \
  git \
  curl \
  openssh \
  rsync

# Increase Java heap size
ENV JAVA_OPTS "-Xms4096m -Xmx4096m"

# Create android builder ci user account
RUN adduser -g 'Android Builder CI' \
  -s '/bin/sh' \
  -D "android-builder-ci"

# Use that user
USER android-builder-ci
WORKDIR /home/android-builder-ci
SHELL ["/bin/sh","-c","-l"]

# Set the android sdk root path
ENV ANDROID_SDK_ROOT /home/android-builder-ci/Android/Sdk

# Download the latest sdk manager command line tools
RUN wget -q https://dl.google.com/android/repository/commandlinetools-linux-7302050_latest.zip

# Verify the command line tools
RUN echo "7a00faadc0864f78edd8f4908a629a46d622375cbe2e5814e82934aebecdb622  commandlinetools-linux-7302050_latest.zip" | sha256sum -c

# Extract the command line tools
RUN mkdir -p ~/Android/Sdk/cmdline-tools && \
  unzip -q commandlinetools-linux-7302050_latest.zip -d ~/Android/Sdk/cmdline-tools && \
  mv ~/Android/Sdk/cmdline-tools/cmdline-tools ~/Android/Sdk/cmdline-tools/latest && \
  rm commandlinetools-linux-7302050_latest.zip && \
  echo "alias sdkmanager='~/Android/Sdk/cmdline-tools/latest/bin/sdkmanager'" >> ~/.profile

# Acceptt all license
RUN yes | sdkmanager --licenses 1>/dev/null

# Install the android sdk
RUN sdkmanager --install \
  "platform-tools" \
  "platforms;android-30" \
  "build-tools;30.0.3" \
  "ndk-bundle" \
  "cmake;3.18.1" \
  "extras;google;google_play_services"

# Create project directory
RUN mkdir AndroidProject
WORKDIR /home/android-builder-ci/AndroidProject
RUN echo "sdk.dir=$ANDROID_SDK_ROOT" > local.properties

# Set the entrypoint
ENTRYPOINT ["/bin/sh","-l"]
