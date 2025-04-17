Докер знаю очень поверхностно, изучать его времени не хватило, пришлось опять просить помощи у китайского бота.
Файл билдится, проверял.

1) Соберите образ: docker build -t kafka-4.0-kraft .
2) Запустите контейнер: docker run -d --name kafka -p 9092:9092 kafka-4.0-kraft
3) Создайте тестовый топик: docker exec kafka kafka-topics.sh --create --topic test --bootstrap-server localhost:9092 --partitions 1 --replication-factor 1

Это решение работает с Kafka 4.0+ в режиме KRaft
