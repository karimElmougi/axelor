FROM debian:11.11

RUN DEBIAN_FRONTEND=noninteractive apt-get -y update && \
  apt-get -y upgrade && \
  apt-get install -y git openjdk-11-jdk nodejs yarn

RUN mkdir -p ~/.ssh && ssh-keyscan github.com >> ~/.ssh/known_hosts

ARG VERSION=v8.2.2
RUN git clone --depth 1 --branch ${VERSION} https://github.com/axelor/open-suite-webapp
WORKDIR /open-suite-webapp

# Use HTTPS for cloning git submodules
RUN sed -i 's|git@github.com:|https://github.com/|g' .gitmodules
RUN sed -i 's/\.git//g' .gitmodules

RUN git submodule init
RUN git submodule update
RUN git submodule foreach git checkout ${VERSION}

RUN sed -i 's|localhost:5432|postgres:5432|g' src/main/resources/axelor-config.properties
RUN sed -i 's/db.default.password = \*\*\*\*\*/db.default.password = axelor/g' src/main/resources/axelor-config.properties

RUN ./gradlew --no-daemon -x test build

CMD ["./gradlew", "--no-daemon", "run"]
