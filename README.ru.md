<!-- omit in toc -->
# pgbouncer formula

Формуля для установки и настройки pgbouncer

* [Использование](#использование)
* [Доступные стейты](#доступные-стейты)
  * [pgbouncer](#pgbouncer)
  * [pgbouncer.repo](#pgbouncerrepo)
  * [pgbouncer.repo.install](#pgbouncerrepoinstall)
  * [pgbouncer.repo.clean](#pgbouncerrepoclean)
  * [pgbouncer.install](#pgbouncerinstall)
  * [pgbouncer.binary.install](#pgbouncerbinaryinstall)
  * [pgbouncer.binary.clean](#pgbouncerbinaryclean)
  * [pgbouncer.package.install](#pgbouncerpackageinstall)
  * [pgbouncer.package.clean](#pgbouncerpackageclean)
  * [pgbouncer.config](#pgbouncerconfig)
  * [pgbouncer.config.clean](#pgbouncerconfigclean)
  * [pgbouncer.service](#pgbouncerservice)
  * [pgbouncer.service.install](#pgbouncerserviceinstall)
  * [pgbouncer.service.clean](#pgbouncerserviceclean)

## Использование

* Создаем pillar с данными, см. `pillar.example` для качестве примера, привязываем его к хосту в pillar top.sls.
* Применяем стейт на целевой хост `salt 'pgbouncer-01*' state.sls pgbouncer saltenv=base pillarenv=base`.
* Применить формулу к хосту в state top.sls, для выполнения оной при запуске `state.highstate`.

## Доступные стейты

### pgbouncer

Мета стейт, выполняет все необходимое для настройки сервиса на отдельном хосте.

### pgbouncer.repo

Вызывает [pgbouncer.repo.install](#pgbouncerrepoinstall)

### pgbouncer.repo.install

Стейт для настройки официального репозитория

* [APT](https://wiki.postgresql.org/wiki/Apt)
* [YUM](https://wiki.postgresql.org/wiki/YUM_Installation)

### pgbouncer.repo.clean

Стейт для удаления репозитория.

### pgbouncer.install

Вызывает стейт для установки pgbouncer в зависимости от значения пиллара `use_upstream`:

* `package` или `repo`: установка из пакетов `pgbouncer.package.install`
* ~~`binary` или `archive`: установка из архива `pgbouncer.binary.install`~~  
  `binary` метод не актуален для `pgbouncer`

### pgbouncer.binary.install

~~Установка pgbouncer из архива~~

### pgbouncer.binary.clean

~~Удаление pgbouncer установленного из архива~~

### pgbouncer.package.install

Установка pgbouncer из пакетов

### pgbouncer.package.clean

Удаление pgbouncer установленного из пакетов

### pgbouncer.config

Создает конфигурационные файлы. Запускает сервис.

### pgbouncer.config.clean

Удаляет конфигурационные файлы. НЕ вызывается при запуске `pgbouncer.clean`, единственный вариант запуска данного стейта - ручной вызов.

```bash
salt minion_id state.sls pgbouncer.config.clean
```

### pgbouncer.service

Управляет состоянием сервиса pgbouncer, в зависимости от значений пилларов `pgbouncer.service.status`, `pgbouncer.service.on_boot_state`.

### pgbouncer.service.install

Устанавливает файл сервиса pgbouncer, на данный момент поддерживается только одна система инициализации - `systemd`.

### pgbouncer.service.clean

Останавливает сервис, выключает запуск сервиса при старте ОС, удаляет юнит файл `systemd`.
