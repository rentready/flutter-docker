FROM rentready/android-sdk:tools

# https://docs.flutter.dev/development/tools/sdk/releases
ARG FLUTTER_SDK_VERSION

ENV FLUTTER_SDK_PACKAGE=flutter_linux_${FLUTTER_SDK_VERSION}-stable.tar.xz
ENV FLUTTER_SDK_DOWNLOAD_BASE_URL=https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/${FLUTTER_SDK_PACKAGE}

ENV FLUTTER_HOME=/opt/flutter
ENV PATH=${PATH}:${FLUTTER_HOME}/bin:${FLUTTER_HOME}/bin/cache/dart-sdk/bin

RUN curl -fsSL https://dl-ssl.google.com/linux/linux_signing_key.pub | gpg --dearmor -o /etc/apt/keyrings/google-chrome.gpg
RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/google-chrome.gpg] http://dl.google.com/linux/chrome/deb/ stable main" | \
    tee /etc/apt/sources.list.d/google-chrome.list

RUN apt-get update \
    && apt-get install -y --no-install-recommends --no-install-suggests \
        sudo \
        bash \
        curl \
        file \
        git \
        zip \
        unzip \
        xz-utils \
        clang \
        cmake \
        ninja-build \
        pkg-config \
        libgtk-3-dev \
        liblzma-dev \
        libglu1-mesa \
        google-chrome-stable \
        build-essential \
        ruby-full \
        bundler \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN yes | sdkmanager --install \
    "build-tools;34.0.0" \
    "build-tools;33.0.3" \
    "build-tools;32.0.0" \
    "build-tools;31.0.0" \
    "platforms;android-34" \
    "platforms;android-33" \
    "platforms;android-32" \
    "platforms;android-31" \
    "platform-tools" \
    "tools"

RUN set -x \
    && curl -fsSL -o /tmp/${FLUTTER_SDK_PACKAGE} ${FLUTTER_SDK_DOWNLOAD_BASE_URL} \
    && mkdir -p ${FLUTTER_HOME} \
    && tar -xf /tmp/${FLUTTER_SDK_PACKAGE} --strip-components=1 -C ${FLUTTER_HOME} \
    && rm -rf /tmp/*

RUN set -x \
    && git config --global --add safe.directory ${FLUTTER_HOME} \
    && flutter config \
            --no-analytics \
            --enable-android \
            --enable-linux-desktop \
            --enable-web \
            --enable-ios \
    && flutter precache --universal --linux --web --ios \
    && yes | flutter doctor --android-licenses \
    && flutter --version

COPY Gemfile /Gemfile

RUN bundle install