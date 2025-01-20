# Use an official CUDA image as the base
FROM nvidia/cuda:11.8.0-base-ubuntu18.04

# Set environment variables
ENV LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    PYTHONUNBUFFERED=1 \
    TZ=America/Fortaleza

ENV LD_LIBRARY_PATH /root/.mujoco/mujoco210/bin:${LD_LIBRARY_PATH}
ENV LD_LIBRARY_PATH /usr/local/nvidia/lib64:${LD_LIBRARY_PATH}

# Set up CUDA paths for PyTorch
ENV LD_LIBRARY_PATH=/usr/local/cuda/lib64:$LD_LIBRARY_PATH \
    CUDA_HOME=/usr/local/cuda

# Set environment variables for pyenv
ENV PYENV_ROOT=/root/.pyenv
ENV PATH=$PYENV_ROOT/bin:$PATH
ENV MUJOCO_GL="egl"

# Create a working directory
WORKDIR /workspace
COPY requirements.txt .

# Install system dependencies
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    build-essential \
    python3 \
    python3-dev \
    python3-venv \
    python3-pip \
    libgl1-mesa-glx \
    libgl1-mesa-dev \
    wget \
    git \
    curl \
    git \
    libgl1-mesa-dev \
    libgl1-mesa-glx \
    libglew-dev \
    libosmesa6-dev \
    software-properties-common \
    net-tools \
    vim \
    virtualenv \
    wget \
    xpra \
    xserver-xorg-dev \
    patchelf \
    libffi-dev \
    build-essential \
    zlib1g-dev \
    libffi-dev \
    libssl-dev \
    libbz2-dev \
    libreadline-dev \
    libsqlite3-dev \
    liblzma-dev \
    libncurses-dev \
    tk-dev \
    ffmpeg \
    libosmesa6-dev \
    libgl1-mesa-glx \
    libglfw3 \
    xvfb \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN curl https://pyenv.run | bash

# Initialize pyenv
RUN echo 'eval "$(pyenv init --path)"' >> /root/.bashrc
RUN echo 'eval "$(pyenv init -)"' >> /root/.bashrc
RUN /bin/bash -c "source /root/.bashrc"

# Install Python 3.9.13 using pyenv
RUN pyenv install 3.9.13
RUN pyenv global 3.9.13

RUN mkdir -p /root/.mujoco \
    && wget https://mujoco.org/download/mujoco210-linux-x86_64.tar.gz -O mujoco.tar.gz \
    && tar -xf mujoco.tar.gz -C /root/.mujoco \
    && rm mujoco.tar.gz

RUN /root/.pyenv/shims/pip install torch==2.5.0 torchvision==0.20.0 torchaudio==2.5.0 --index-url https://download.pytorch.org/whl/cu118
RUN /root/.pyenv/shims/pip install -r requirements.txt
RUN /root/.pyenv/shims/pip install "cython<3"
RUN /root/.pyenv/shims/python -c "import gym; gym.make('HalfCheetah-v2')"
RUN /root/.pyenv/shims/pip install numpy"==1.26.4"
# Default command to run in the container
CMD ["bash"]