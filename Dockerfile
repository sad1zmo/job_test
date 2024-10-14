FROM ubuntu:24.04

RUN apt-get update && \
    apt-get install -yy openssh-server git sudo && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    useradd -m -s /bin/bash ansible && \
    mkdir -p /run/sshd /home/ansible/.ssh && \
    echo 'ansible ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers && \
    chown ansible:ansible /home/ansible/.ssh && \
    chmod 700 /home/ansible/.ssh && \
    sed -i '/^#*PubkeyAuthentication/c\PubkeyAuthentication yes' /etc/ssh/sshd_config

COPY id_rsa.pub /home/ansible/.ssh/authorized_keys

RUN chown ansible:ansible /home/ansible/.ssh/authorized_keys && \
    chmod 600 /home/ansible/.ssh/authorized_keys

EXPOSE 80 22

CMD ["/bin/bash", "-c", "/usr/sbin/sshd && if [ $? -eq 0 ]; then tail -f /dev/null; else echo 'SSHD failed to start'; fi"]


