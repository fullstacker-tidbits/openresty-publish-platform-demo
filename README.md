# OpenResty Publish Platform Demo

To run the app, simply run the following command:

```
$ docker-compose up
```

To bootstrap the data, just execute `init.sql`.
If you have a MySQL command line client, run:

```
$ mysql -h0.0.0.0 -uroot -papp app < init.sql
```
