FROM hashicorp/terraform:0.12.24

# ---
FROM ubuntu:19.10
RUN apt-get update

# AWS
RUN apt-get install -y awscli

# UTILS
RUN apt-get install -y curl
RUN apt-get install -y jq
RUN apt-get install -y less
RUN apt-get install -y iproute2

# TERRAFORM
COPY --from=0 /bin/terraform /bin/terraform

# # KUBECTL
# RUN apt-get install -y gnupg2                                                                                     && \
#     apt-get install -y apt-transport-https                                                                        && \
#     curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -                                 && \
#     echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | tee -a /etc/apt/sources.list.d/kubernetes.list && \
#     apt-get update                                                                                                && \
#     apt-get install -y kubectl

# # GIT
# RUN apt-get install -y git

# NODEJS
RUN curl -sL https://deb.nodesource.com/setup_14.x | bash
RUN apt-get install -y nodejs

# YARN
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt update  
RUN apt-get install -y yarn

# SETUP USER TO SHARE DIRECTORIES
ARG USERTOADD
ARG DOCKERGROUPID

RUN groupadd --gid ${DOCKERGROUPID} docker
RUN useradd              \
    --create-home        \
    --user-group         \
    --shell /bin/bash    \
    --groups root,docker \
    ${USERTOADD}

ENV USER ${USERTOADD}
