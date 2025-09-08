#!/bin/bash

# Запрос переменных у пользователя
read -p "Введите name: " name
read -p "Введите ip: " ip
read -p "Введите port: " port

file="values.yaml"

# Проверка, существует ли запись с таким name
exists=$(yq e ".acmeSubdomain[] | select(.name == \"$name\")" $file)

if [ -n "$exists" ]; then
  # Если существует, заменяем запись с именем $name на новые значения
  yq e -i "(.acmeSubdomain[] | select(.name == \"$name\")) |= {name: \"$name\", ip: \"$ip\", port: $port}" $file
  echo "Запись с name='$name' обновлена."
else
  # Если не существует, добавляем новую запись в список
  yq e -i ".acmeSubdomain += [{name: \"$name\", ip: \"$ip\", port: $port}]" $file
  echo "Новая запись с name='$name' добавлена."
fi
