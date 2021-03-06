# s2i-insights-compliance
FROM registry.access.redhat.com/ubi8/ruby-26

LABEL maintainer="Daniel Lobato Garcia <dlobatog@redhat.com>"

# TODO: Rename the builder environment variable to inform users about application you provide them
ENV INSIGHTS_COMPLIANCE 0.4.2
ENV RAILS_ENV=production RAILS_LOG_TO_STDOUT=true

# TODO: Set labels used in OpenShift to describe the builder image
LABEL io.k8s.description="Base image for Red Hat Insights Compliance" \
      io.k8s.display-name="Compliance base image" \
      io.openshift.expose-services="8080:http" \
      io.openshift.tags="builder,compliance"

# Install dependencies and clean cache to make the image cleaner
USER root
RUN rpm -ivh https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm && \
    yum install -y hostname && \
    yum clean all -y
RUN mkdir /jemalloc-stable && cd /jemalloc-stable &&\
    wget https://github.com/jemalloc/jemalloc/releases/download/3.6.0/jemalloc-3.6.0.tar.bz2 &&\
    tar -xjf jemalloc-3.6.0.tar.bz2 && cd jemalloc-3.6.0 && ./configure --prefix=/usr && make && make install &&\
    cd / && rm -rf /jemalloc-stable
RUN mkdir /jemalloc-new && cd /jemalloc-new &&\
    wget https://github.com/jemalloc/jemalloc/releases/download/5.2.0/jemalloc-5.2.0.tar.bz2 &&\
    tar -xjf jemalloc-5.2.0.tar.bz2 && cd jemalloc-5.2.0 && ./configure --prefix=/usr --with-install-suffix=5.2.0 && make build_lib && make install_lib &&\
    cd / && rm -rf /jemalloc-new
USER 1001

# Copy the S2I scripts to /usr/libexec/s2i, since openshift/base-centos7 image
# sets io.openshift.s2i.scripts-url label that way, or update that label
COPY ./s2i/bin/ /usr/libexec/s2i

CMD ["run"]
