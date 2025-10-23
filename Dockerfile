# syntax=docker/dockerfile:1.4

FROM nvidia/cuda:12.1.1-base-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive

# ===============================
# 1. Системные зависимости
# ===============================
RUN apt-get update && apt-get install -y --no-install-recommends \
  python3 python3-pip git wget curl unzip ffmpeg portaudio19-dev \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# ===============================
# 2. Установка Python-зависимостей
# ===============================
COPY requirements.txt /tmp/requirements.txt

RUN --mount=type=cache,target=/root/.cache/pip \
  python3 -m pip install --upgrade pip setuptools wheel && \
  python3 -m pip install --no-cache-dir --prefer-binary \
  --extra-index-url https://download.pytorch.org/whl/cu121 \
  -r /tmp/requirements.txt

# ===============================
# 3. Установка Auralis
# ===============================
RUN --mount=type=cache,target=/root/.cache/pip \
  python3 -m pip install --no-cache-dir git+https://github.com/astramind-ai/Auralis.git@main#egg=Auralis

# ===============================
# 4. Копирование приложения
# ===============================
COPY gradio_app.py /app/gradio_app.py

# ===============================
# 5. Томы, порты и окружение
# ===============================
VOLUME ["/app/models", "/app/data"]
EXPOSE 7860

ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=compute,utility
ENV HUGGINGFACE_TOKEN=""

# ===============================
# 6. Команда запуска
# ===============================
CMD ["python3", "/app/gradio_app.py"]