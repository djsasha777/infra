# 1s-server




# Helpers:


sudo docker build --tag djsasha777/1s-server:7 .

sudo docker push djsasha777/1s-server:7

sudo docker image rm djsasha777/1s-web-server -f 

sudo docker build --tag djsasha777/1s-web-server:2 . 

sudo docker push djsasha777/1s-web-server:2