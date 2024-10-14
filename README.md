## Описание проекта

Этот проект нацелен на развертывание веб-сервера Nginx с использованием Docker, Docker Compose и Ansible. В нем настроена аутентификация по SSH, развертывание статического контента и управление конфигурацией через Ansible роли.

### Структура файлов и директорий:

- **Dockerfile**: Содержит инструкции для создания кастомного образа с веб-сервером Nginx и поддержкой SSH-аутентификации.
- **docker-compose.yml**: Используется для определения сервиса `static_server` с настройками портов и монтирования директории для статического контента.
- **roles**: Каталог с Ansible ролями для установки и настройки Nginx, управления пользователями и SSH конфигурацией.
- **ansible.cfg**: Настройки Ansible, включая использование SSH, указание пользователя и порта для соединения.
- **playbook.yml**: Основной playbook, который использует роли для настройки сервера.

---

### 1. **Dockerfile**:

Этот файл создает кастомный образ на основе `ubuntu:24.04`, устанавливает sudo, Git и OpenSSH, настраивает пользователя и включает аутентификацию по ключам.

```Dockerfile
FROM ubuntu:24.04

RUN apt-get update && \
    apt-get install -yy openssh-server git && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    useradd -m -s /bin/bash ansible && \
    mkdir -p /run/sshd /home/ansible/.ssh && \
    echo 'ansible ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers && \
    chown ansible:ansible /home/ansible/.ssh && \
    chmod 700 /home/ansible/.ssh && \
    sed -i 's/^#PubkeyAuthentication.*/PubkeyAuthentication yes/' /etc/ssh/sshd_config

COPY id_rsa.pub /home/ansible/.ssh/authorized_keys
RUN chown ansible:ansible /home/ansible/.ssh/authorized_keys && chmod 600 /home/ansible/.ssh/authorized_keys

EXPOSE 80 22
CMD ["/bin/bash", "-c", "/usr/sbin/sshd && if [ $? -eq 0 ]; then tail -f /dev/null; else echo 'SSHD failed to start'; fi"]
```

### 2. **docker-compose.yml**:

Файл docker-compose определяет сервис `static_server`, который мапит порты 80 и 222.

```yaml
version: '3'
services:
  static_server:
    build: .
    ports:
      - "80:80"
      - "222:22"
    restart: always
```

### 3. **Ansible roles**:

- **install_nginx**: Устанавливает и настраивает Nginx.
- **packages_list**: Управляет установкой необходимых пакетов.
- **shell**: Выполняет команды оболочки.
- **ssh_config**: Настраивает конфигурацию SSH.
- **static_content_deploy**: Отвечает за развертывание статического контента в директории `/images`.
- **users**: Управление пользователями.

### 4. **ansible.cfg**:

Этот файл конфигурации Ansible задает параметры для подключения по SSH и работы с пользователем `ansible`.

```ini
[defaults]
ansible_connection=ssh
ansible_user=ansible
ansible_port=222
host_key_checking=False
```

### 5. **playbook.yml**:

Основной playbook использует все роли для настройки сервера и выполнения задач.

```yaml
---
- hosts: static_server
  become: true
  vars_files:
    - vars/users.yml
    - vars/packages_list.yml
    - vars/nginx.yml
  roles:
    - users
    - shell
    - ssh_config
    - packages_list
    - install_nginx
    - static_content_deploy
```

---

## Инструкция по запуску

```
необходимо положить в корень проекта свой открытый ключ id_rsa.pub
```

1. **Сборка и запуск контейнера**:
   ```bash
   docker-compose up -d
   ```

2. **Подключение по SSH**:
   Используйте порт 222 для подключения к серверу по SSH:
   ```bash
   ssh -p 222 ansible@localhost
   ```

3. **Развертывание с помощью Ansible**:
   Убедитесь, что у вас настроен доступ по SSH к контейнеру, и выполните playbook:
   ```bash
   ansible-playbook -i ansible/inventory.ini ansible/playbook.yml
   ```

4. **Handlers**:
   В хендлерах используется не service модуль потому,  в докере нет systemd.