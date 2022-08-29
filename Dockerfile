FROM ubuntu:latest

# 设置时区
ARG TZ=Asia/Shanghai
ENV TZ ${TZ}

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

USER root
RUN apt-get update && apt-get install -y \
    zsh \
    vim \
    wget \
    curl \
    git-core \
    sudo \
    openjdk-11-jdk

#install zsh for root
RUN git clone https://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh \
    && cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc \
    && git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions \
    && git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting \
    && sed -i 's/^plugins=(/plugins=(zsh-autosuggestions zsh-syntax-highlighting /' ~/.zshrc \
    && chsh -s /bin/zsh

RUN adduser --gecos '' --disabled-password me && \
  echo "me ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/nopasswd

USER me
# oh my zsh
RUN git clone https://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh \
    && cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc \
    && git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions \
    && git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting \
    && sed -i 's/^plugins=(/plugins=(zsh-autosuggestions zsh-syntax-highlighting /' ~/.zshrc \
    && sudo chsh -s /bin/zsh


# git config
RUN git config --global --add pull.rebase false \
    && git config --global --add user.name beimengyeyu \
    && git config --global --add user.email me@beimengyeyu.com \
    && git config --global core.editor vim \
    && git config --global init.defaultBranch master \
    && git config --global alias.pullall '!git pull && git submodule update --init --recursive'

# node env
ENV NODE_VERSION 16.14.2
ENV NVM_DIR ~/.nvm
RUN mkdir -p $NVM_DIR && \
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash \
        && . $NVM_DIR/nvm.sh \
        && nvm install $NODE_VERSION \
        $$ nvm alias default $NODE_VERSION \
        && nvm use default
RUN echo 'export NVM_DIR=~/.nvm' >> ~/.zshrc && \
    echo '[ -s "$NVM_DIR/nvm.sh" ] && \
    . "$NVM_DIR/nvm.sh"' >> ~/.zshrc

RUN echo fs.inotify.max_user_watches=524288 | sudo tee -a /etc/sysctl.conf && sudo sysctl -p

