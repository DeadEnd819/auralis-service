# Базовый CUDA образ
FROM nvidia/cuda:12.1.1-base-ubuntu22.04

# Системные зависимости
RUN apt-get update && apt-get install -y \
  python3 python3-pip git wget curl unzip ffmpeg \
  portaudio19-dev \
  && rm -rf /var/lib/apt/lists/*

# Обновляем pip
RUN python3 -m pip install --upgrade pip

# PyTorch с поддержкой CUDA
RUN pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121

# Устанавливаем дополнительные зависимости
RUN pip install gradio ebooklib beautifulsoup4

# Клонируем Auralis
RUN git clone https://github.com/astramind-ai/Auralis.git /app/Auralis

# Устанавливаем пакет Auralis в editable-режиме
WORKDIR /app/Auralis
RUN pip install -e .

# Копируем актуальный gradio_example.py из проекта (если ты используешь свой вариант)
WORKDIR /app
COPY gradio_app.py /app/Auralis/examples/gradio_app.py

# Томы и порт
VOLUME ["/app/models", "/app/data"]
EXPOSE 7860

# Настройки окружения
ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=compute,utility
ENV HUGGINGFACE_TOKEN=""

# Запуск Gradio-приложения
CMD ["python3", "/app/Auralis/examples/gradio_app.py"]