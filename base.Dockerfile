# Образ на основе которого будет создан контейнер
FROM --platform=linux/amd64 dolfinx/dolfinx:stable

# Изменение рабочего пользователя
USER root

# Выбор рабочей директории
WORKDIR /

ENV \ 
    # Задание директорий 
    WORK_DIRECTORY=/workspace \
    # Выбор time zone
    DEBIAN_FRONTEND=noninteractive \
    TZ=Europe/Moscow

# Копирование файлов проекта
COPY ./requirements.txt /tmp/
COPY ./entrypoint.sh /

RUN \
    # --------------------------------------------------------------------------
    # Базовая настройка операционной системы
    # --------------------------------------------------------------------------
    # Установка пароль пользователя root 
    echo "root:root" | chpasswd && \
    # Замена ссылок на зеркало (https://launchpad.net/ubuntu/+archivemirrors)
    sed -i 's/htt[p|ps]:\/\/archive.ubuntu.com\/ubuntu\//http:\/\/mirror.truenetwork.ru\/ubuntu/g' /etc/apt/sources.list && \
    # Обновление путей
    apt --yes update && \
    # Установка timezone
    apt install --no-install-recommends --yes tzdata && \
    cp /usr/share/zoneinfo/${TZ} /etc/localtime && \
    echo ${TZ} > /etc/timezone && \
    # Установка языкового пакета
    apt install --no-install-recommends --yes locales && \
    sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && \
    locale-gen  && \
    # --------------------------------------------------------------------------
    # --------------------------------------------------------------------------
    # Установка базовых пакетов
    # --------------------------------------------------------------------------
    # gcc, g++, make
    apt install --no-install-recommends --yes build-essential && \
    apt install --no-install-recommends --yes ssh && \
    apt install --no-install-recommends --yes curl && \
    # --------------------------------------------------------------------------
    # --------------------------------------------------------------------------
    # Настройка базовых сервисов
    # --------------------------------------------------------------------------
    mkdir /run/sshd && \
    service ssh start && \
    # Allow Root login
    sed -i 's/^#\(PermitRootLogin\) .*/\1 yes/' /etc/ssh/sshd_config && \
    # SSH login fix
    sed -i 's/^\(UsePAM yes\)/# \1/' /etc/ssh/sshd_config && \
    # --------------------------------------------------------------------------
    # --------------------------------------------------------------------------
    # Установка NodeJs
    # --------------------------------------------------------------------------
    # Скачивание Bash-скрипта установки
    curl -sL https://deb.nodesource.com/setup_19.x -o /tmp/nodesource_setup.sh && \
    # Выполнение скрипта
    bash /tmp/nodesource_setup.sh && \
    # Удаление скрипта
    rm /tmp/nodesource_setup.sh* && \
    # Установка NodeJs
    apt install --no-install-recommends --yes nodejs && \
    # Smoke test
    node -v && \
    # Обновление версии npm
    npm install --global npm && \
    # Smoke test
    npm -v && \
    # --------------------------------------------------------------------------
    # --------------------------------------------------------------------------
    # Установка пакетов Python
    # --------------------------------------------------------------------------
    python3.10 -m pip install --upgrade pip && \
    python3.10 -m pip install --no-cache-dir --use-pep517 jupyterlab==3.6.1 && \
    python3.10 -m pip install --no-cache-dir --use-pep517 nbconvert && \
    python3.10 -m pip install --no-cache-dir --use-pep517 --requirement /tmp/requirements.txt && \
    # --------------------------------------------------------------------------
    # --------------------------------------------------------------------------
    # Подготовка директорий
    # --------------------------------------------------------------------------
    # Рабочая директория
    mkdir -p ${WORK_DIRECTORY} && \
    chmod -R a+rwx ${WORK_DIRECTORY} && \
    # --------------------------------------------------------------------------
    # --------------------------------------------------------------------------
    # Настройка прав доступа скопированных файлов/директорий
    # --------------------------------------------------------------------------
    # Директория/файл entrypoint
    chown -R ${USER}:${GID} /entrypoint.sh && \
    chmod -R a+x /entrypoint.sh && \
    # --------------------------------------------------------------------------
    # --------------------------------------------------------------------------
    # Очистка кэша
    # --------------------------------------------------------------------------
    apt --yes autoremove && \
    rm -rf /var/lib/apt/lists/*
    # --------------------------------------------------------------------------

# Точка входа
ENTRYPOINT ["/bin/bash", "/entrypoint.sh"]
CMD []
