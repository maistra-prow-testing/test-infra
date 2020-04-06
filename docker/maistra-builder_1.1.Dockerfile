FROM centos:8.1.1911

# ENV container docker
# RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == \
# systemd-tmpfiles-setup.service ] || rm -f $i; done); \
# rm -f /lib/systemd/system/multi-user.target.wants/*;\
# rm -f /etc/systemd/system/*.wants/*;\
# rm -f /lib/systemd/system/local-fs.target.wants/*; \
# rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
# rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
# rm -f /lib/systemd/system/basic.target.wants/*;\
# rm -f /lib/systemd/system/anaconda.target.wants/*;
# VOLUME [ "/sys/fs/cgroup" ]
# ENTRYPOINT ["/usr/sbin/init"]

ENV PATH /usr/local/go/bin:/go/bin:${PATH}

# Install dependencies
COPY scripts /tmp/scripts
WORKDIR /tmp/scripts
RUN chmod -R +x /tmp/scripts/ 
RUN /tmp/scripts/install_base.sh
RUN /tmp/scripts/install_go_13.sh
RUN /tmp/scripts/install_helm.sh
RUN /tmp/scripts/install_shellcheck.sh
RUN /tmp/scripts/install_kubectl.sh
RUN /tmp/scripts/install_docker.sh

RUN rm -rf /tmp/scripts

# Set CI variable which can be checked by test scripts to verify
# if running in the continuous integration environment.
ENV CI prow

# Install the magic wrapper.
ADD ./wrapdocker /usr/local/bin/wrapdocker
RUN chmod +x /usr/local/bin/wrapdocker

# Define additional metadata for our image.
VOLUME /var/lib/docker
ENTRYPOINT ["wrapdocker"]
