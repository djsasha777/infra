#!/bin/bash

# Запрос переменных у пользователя
read -p "Введите name: " name
read -p "Введите ip: " ip
read -p "Введите port: " port

file="values.yaml"

# Проверка, существует ли запись с таким name
exists=$(yq e ".acmeSubdomain[] | select(.name == \"$name\")" $file)

if [ -n "$exists" ]; then
  # Обновляем ip и port по отдельности
  yq e -i "(.acmeSubdomain[] | select(.name == \"$name\") | .ip) = \"$ip\"" $file
  yq e -i "(.acmeSubdomain[] | select(.name == \"$name\") | .port) = $port" $file
  echo "Запись с name='$name' обновлена."
else
  # Добавляем новую запись
  yq e -i ".acmeSubdomain += [{name: \"$name\", ip: \"$ip\", port: $port}]" $file
  echo "Новая запись с name='$name' добавлена."
fi
