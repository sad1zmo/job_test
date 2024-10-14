Для шифрования чуствительных данных можно использовать ansible-vault:

ansible-vault create vars/main.yml
ansible-vault edit vars/main.yml
ansible-playbook -i inventory.ini playbook.yml --ask-vault-pass

пример файл main1.yml
