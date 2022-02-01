# docker-compose環境構築

## 開発環境
- Windows10
- IntelliJIDE
- Docker for Windows
- MySQL8.0

## 作業内容
- docker-composeを利用して、MySQLイメージをコンテナで起動

## 1. docker-composeでMySQL構築

1. docker-composeのバ‐ジョン確認
```terminal
>docker-compose --version
docker-compose version 1.24.1, build 4667896b
```

2. ディレクトリの作成
```ディレクトリ
prototype-docker/
             ├ docker/
             |       └ mysql/
             |              ├ conf.d/
             |              |       └ my.cnf
             |              ├ initdb.d/
             |              |         ├ schema.sql
             |              |         └ testdata.sql
             |              └ Dockerfile
             └ docker-compose.yml 
```


3. Dockerfileの作成

Dockerfileにイメージのビルド内容を記述します。
```dockerfile
FROM mysql:8.0
# 指定の場所にログを記録するディレクトリを作る
RUN mkdir /var/log/mysql
# 指定の場所にログを記録するファイルを作る
RUN touch /var/log/mysql/mysqld.log
```

4. docker-compose.ymlの作成

docker-compose.ymlにTBA
```yml
version: '3.3'
services:
  db:
    build: ./docker/mysql
    image: mysql:8.0
    restart: always
    environment:
      MYSQL_DATABASE: prototype
      MYSQL_USER: user
      MYSQL_PASSWORD: password
      MYSQL_ROOT_PASSWORD: password
      TZ: 'Asia/Tokyo'
    ports:
      - "3306:3306"
    volumes:
      - ./docker/mysql/initdb.d:/docker-entrypoint-initdb.d
      - ./docker/mysql/conf.d:/etc/mysql/conf.d
```

5. my.confの作成

my.confに、独自のMySQLの設定を記述します。
```conf
[mysqld]
# mysqlサーバー側が使用する文字コード
character-set-server=utf8mb4
# テーブルにTimeStamp型のカラムをもつ場合、推奨
explicit-defaults-for-timestamp=1
# 実行したクエリの全ての履歴が記録される（defaultではOFF）
general-log=1
# ログの出力先
general-log-file=/var/log/mysql/mysqld.log

[client]
# mysqlのクライアント側が使用する文字コード
default-character-set=utf8mb4
```

6. schema.sqlの作成

初期化するテーブル定義のDDLを記述します。

```sql
create TABLE IF NOT EXISTS `prototype`.`users` (
  `id` INT NOT NULL AUTO_INCREMENT COMMENT 'ユーザーID'
  , `mail` VARCHAR (256) NOT NULL COMMENT 'メールアドレス'
  , `gender` SMALLINT (1) NOT NULL COMMENT '性別'
  , `password` VARCHAR (256) NOT NULL COMMENT 'パスワード'
  , `birthdate` DATE NOT NULL COMMENT '生年月日'
  , `create_user_id` INT NULL COMMENT '作成者ID'
  , `create_timestamp` TIMESTAMP NULL COMMENT '作成日時'
  , PRIMARY KEY (`id`)
  , UNIQUE INDEX `mail_UNIQUE` (`mail`)
) ENGINE = Innodb
, DEFAULT character set utf8
, COMMENT = 'ユーザー'
;
```

7. testdata.sqlの作成

初期化したテーブルに投入するデータのDMLを記述します。
```sql
INSERT INTO users(mail, gender, password, birthdate, create_user_id, create_timestamp)
VALUES
 ('test@gmail.com', 1, '暗号化したパスワード', '1991/01/01', 0, current_timestamp);
```

8. docker-composeコマンドの実行

ディレクトリ構成と各種ファイルの作成が完了したら、docker-composeコマンドを実行します。

```terminal
> docker-compose up -d #コンテナの起動
Creating prototype-docker_db_1 ... done

>docker-compose ps #存在するコンテナの一覧とその状態を表示
        Name                      Command             State                 Ports
-----------------------------------------------------------------------------------------------
prototype-docker_db_1   docker-entrypoint.sh mysqld   Up      0.0.0.0:3306->3306/tcp, 33060/tcp
```

9. 初期化クエリ実行確認

schema.sqlとtestdata.sqlの実行結果を確認します。

```
>docker exec -it prototype-docker_db_1 bash
root@aabd0f319f85:/# mysql -u user -p
Enter password:
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 24
Server version: 8.0.18 MySQL Community Server - GPL

Copyright (c) 2000, 2019, Oracle and/or its affiliates. All rights reserved.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.
mysql> show tables from prototype;
+---------------------+
| Tables_in_prototype |
+---------------------+
| users               |
| users_history       |
+---------------------+
2 rows in set (0.00 sec)
```