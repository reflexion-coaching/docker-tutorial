# Tutoriel : Docker

Site officiel de Docker : https://docs.docker.com/

Tutoriel OpenClassRoom : https://openclassrooms.com/fr/courses/7162856-gerez-du-code-avec-git-et-github

Tutoriel officiel : https://docs.github.com/en/get-started

Pour ce tutoriel, je prendrai l'exemple de l'installation et le configuration d'un containeur MySQL. 

## Les containeurs

Avant de parler de Docker, il faut aborder la notion de **containeur**. 

Malheureusement, il est difficile de définir simplement un containeur. Une définition simple mais erronée est qu'*un containeur est une machine virtuelle légère*. Une définition plus correcte mais compliquée est qu'*un containeur est un système de fichier qui contient la structure de fichiers qui correspond à celle de la distribution sur laquelle il est basé*.

Un bon exemple du livre *Mastering Ubuntu Server* : *Un conteneur basé sur Ubuntu Server, par exemple, aura la même disposition de système de fichiers qu'une installation Ubuntu Server réelle sur une VM ou un matériel physique. Imaginez que vous copiez tous les fichiers et dossiers d'une installation Ubuntu, que vous les placez tous dans un seul répertoire séparé et que le contenu binaire du système de fichiers soit exécuté comme un programme, sans qu'un système d'exploitation réel ne soit exécuté.*

**En résumé, un containeur contient tous les fichiers nécessaires à la création d'un environnement basé sur un programme (MySQL, Node.js, Python... ) ou une distribution (Windows, IOS, Ubuntu, ...).** 

Par exemple : dans le cas du développement d'une base de données MySQL, une approche classique serait de télécharger le programme MySQL sur les ordinateurs de toute l'équipe, s'assurer que toutes les versions soient compatibles, effectuer le développement en local et ensuite, re-créer les mêmes conditions sur un serveur. Dans le cas d'un développement avec containeur, un containeur MySQL est téléchargé et modifié pour convenir aux besoins de l'équipe, ce containeur est ensuite partagé à l'équipe pour le développement et enfin, déployé sur le serveur.

## Utilités

Les containeurs ont plusieurs utilités :

* Résoudre les problèmes d'interopérabilité : peu importe l'ordinateur ou le serveur utilisé, un containeur fonctionnera toujours de la même manière.

* Faciliter le déploiement : sur les serveurs, les différents micro-services d'une application fonctionnent très souvent dans des containeurs. En effectuant le développement directement avec des containeurs, le CI&CD est facilité.

* Moins d'applications installées : pas besoin d'installer MySQL, Node.js, python ... directement sur l'ordinateur. Il suffit d'utiliser les containeurs de ces applications. 

Par contre, la préparation de l'environnement de travail prend plus de temps. C'est comme les raccourcis de clavier : au début, c'est un peu laborieux et la souris semble plus pratique mais une fois maitrisés, les raccourcis permettent un gain de temps et d'efficacité. 

## Docker

A l'heure actuelle, Docker est le service de containeurs dominant sur le marché. 

D'un point de vue technique, Docker est écrit en **Go** et utilises la technologie des espaces de noms (`namespaces`) pour créer les environnements isolés (les containeurs).

## L'architecture de Docker 

Docker utilise une architecture client-serveur. Un *service* (daemon) écoute les requêtes envoyées par le *client*  via une *REST API* :

* **Le service ou daemon Docker (appelé, `dockerd`)** écoute les requêtes de l'API et gère les images, les containeurs, le réseau et le volume.

* **Le client Docker (appelé, `docker`)** permet aux utilisateurs d'interagir avec le service via l'API.

* **L'application Docker Desktop** inclut dockerd, docker, Docker Compose, Docker Content Trust et Kubernetes.

* **Un répertoire Docker** stocke les images Docker en ligne. **Docker Hub** est le répertoire Docker le plus couramment utilisé.

* **Une image** contient des instructions pour créer un containeur Docker. Par exemple : pour créer sur notre ordinateur un containeur Docker MySQL, on télécharge depuis Docker Hub l'image de MySQL. Cette image sera ensuite exécutée sur notre ordinateur pour créer effectivement le containeur.

* **Un Dockerfile** est un fichier définissant les étapes de création d'une image. Chaque instruction crée une couche/noeud (layer) dans l'image. Lorsque que le fichier est modifié, seules les couches modifiées sont reconstruites. Toujours pour une application MySQL, un Dockerfile contiendrait par exemple les instructions à propos de la version de MySQL à télécharger, la configuration des mots de passe et identifiants, la localisation des volumes de stockage, ... 

* **Un containeur** est une instance d'une image. Attention, quand un containeur est effacé, les changements sont également effacés. Un nouveau containeur de la même image ne contiendra pas les modifications réalisées dans un précédent containeur. 

## Installation 

Le lien et les explications de téléchargement de Docker sont disponibles sur leur site officiel à l'adresse : https://docs.docker.com/desktop/. Le tutoriel d'installation est compréhensible :) 

**(Optionnel)** Pour stocker quelques images dans leur répertoire officiel, Docker Hub propose une version gratuite. La configuration se fait à partir de https://docs.docker.com/docker-hub/. 


## Exemple

Cet exemple suit l'installation et la configuration d'une base de données MySQL via Docker. 

### 1. Lancement de Docker

La manière la plus simple de lancer Docker est de lancer l'application Docker Desktop. Attention, le lancement de Docker peut varier en fonction du sytème d'exploitation. 

### 2. Téléchargement d'une image depuis DockerHub

C'est parti, téléchargeons une image de MySQL. 

La première chose à faire est de vérifier sur DockerHub l'existence d'une image valide de MySQL. Dans notre cas, l'image existe et les informations de configuration sont disponibles sur : https://hub.docker.com/_/mysql. 

Ensuite, il suffir de lancer `docker pull` en ligne de commande :

```
$ docker pull mysql

Using default tag: latest
latest: Pulling from library/mysql
0bb5c0c24818: Pull complete 
cbb3106fbb5a: Pull complete 
550536ae1d5e: Pull complete 
33f98928796e: Pull complete 
a341087cff11: Pull complete 
0e26ac5b33f6: Pull complete 
c883b83a7112: Pull complete 
873af5c876c6: Pull complete 
8fe8ebd061d5: Pull complete 
7ac2553cf6b4: Pull complete 
ad655e218e12: Pull complete 
Digest: sha256:96439dd0d8d085cd90c8001be2c9dde07b8a68b472bd20efcbe3df78cff66492
Status: Downloaded newer image for mysql:latest
docker.io/library/mysql:latest
```

Ici, Docker a téléchargé la dernière version (`Using default tag: latest`) de l'image de MySQL disponible. L'image est visible dans l'application Docker Desktop sous l'onglet *Images*.

### 3. Création d'un containeur à partir d'une image

On va créer un containeur depuis notre image. Bien que minimaliste, ce containeur aura déjà une petite configuration :

* un nom : les containeurs peuvent être nommer. Dans notre cas, son nom sera `mysql-tutorial`. 

* un mot de passe : pour l'utilisateur root de notre base, le mot de passe sera `tutorial`.

Lancons la commande :

``` 
$ docker run --name mysql-tutorial -e MYSQL_ROOT_PASSWORD=tutorial -d mysql:latest

ddfec0e72a523d9aebaaaf1168c6cc0efd58260f285eea77fc788455c8b540de
```

Super ! La chaine de caractère est l'ID de notre nouveau containeur (le `-d` est pour *detached mode*).

Pour afficher les informations sur les containeurs installés et actifs sur notre machine, on utilise la commande `docker ps` :

```
$ docker ps

CONTAINER ID   IMAGE          COMMAND                  CREATED              STATUS              PORTS                 NAMES
ddfec0e72a52   mysql:latest   "docker-entrypoint.s…"   About a minute ago   Up About a minute   3306/tcp, 33060/tcp   mysql-tutorial
```

Toutes les colonnes sont assez explicites sauf **Ports**. Elle correspond au mappage des ports containeur - machine. Il est possible de rediriger les données arrivant sur un port de notre ordinateur vers un containeur.

### 4. Jouer avec les containeurs et les images

Voici quelques commandes utiles : 

* `docker ps` - liste tous les containeurs installés et actifs sur notre machine :

    ```
    $ docker ps
    CONTAINER ID   IMAGE          COMMAND                  CREATED              STATUS              PORTS                 NAMES
    ddfec0e72a52   mysql:latest   "docker-entrypoint.s…"   About a minute ago   Up About a minute   3306/tcp, 33060/tcp   mysql-tutorial
    ```

* `docker stop + ID` - arrête un containeur sans le supprimer :

    ```
    $ docker stop ddfe
    ddfe
    ```
* `docker ps -a ` - liste tous les containeurs installés (actif ou non) :

    ``` 
    $ docker ps -a
    CONTAINER ID   IMAGE          COMMAND                  CREATED          STATUS                     PORTS     NAMES
    ddfec0e72a52   mysql:latest   "docker-entrypoint.s…"   18 minutes ago   Exited (0) 5 minutes ago             mysql-tutorial
    ```

* `docker container start + ID` - relance un containeur à l'arrêt :

    ```
    $ docker container start ddf
    ddf
    ```

* `docker rm + ID` - supprime un containeur :

    ```
    $ docker stop ddf
    ddf

    $ docker rm ddf
    ddf
    ```

* `docker images` - affiche les images Docker téléchargées sur notre ordinateur : 

    ```
    $ docker images
    REPOSITORY   TAG       IMAGE ID       CREATED      SIZE
    mysql        latest    3842e9cdffd2   6 days ago   538MB
    ```

* `docker rmi + ID image` - supprime une image de notre ordinateur :

    ```
    $ docker rmi 3842e
    Untagged: mysql:latest
    Untagged: mysql@sha256:96439dd0d8d085cd90c8001be2c9dde07b8a68b472bd20efcbe3df78cff66492
    Deleted: sha256:3842e9cdffd239649671beaec03b363b52f7b050fbb4a8869c052438408d6d2e
    Deleted: sha256:1f42c1dd3cbbd4976bb03a3e9cda08a64f92c4b35c85406dd61fc675c06fea06
    Deleted: sha256:615793330ac611559cd6f0a464f0159eb05ad3876198859c92daf53cb4c57ea0
    Deleted: sha256:2d47d08d92e7cee9b5a2a163c37440e9bcf29574c7d603a04254a6c8f6fd2bbb
    Deleted: sha256:8b7fff5815c437619ff2e5406208d21648a27812d480bcc342a0e32020003ef5
    Deleted: sha256:08a8548130ba2c821ff7389faf3a4d60abbd3a6e7b20060231be0fbd2bb16136
    Deleted: sha256:86aabdd0cece68ff3ee220072a3b85142e25cb5c18b628d22f4657bae56ccb11
    Deleted: sha256:e09dc4db3864b796c659b92bae0babfbf09dfa3f70163dc7cd677fabf5e94ef2
    Deleted: sha256:b6d2c75cfbe18df23ef09649426dcb28e7d8790907c72b8beaf83362ac527f04
    Deleted: sha256:bbbfc22ec9c4b1de66375e8c68b7ffb14964a27a1757cacb2fd9d5eed3fb2f2e
    Deleted: sha256:01ea25af332b46ae9cb51ca97f77a6ae8f73c9efab5c4d3484ed9709c792fc60
    Deleted: sha256:4d0c6342b0f59879b314fbfd16867ed6a92583ad06e7f649e53de722af0f2156
    ```

* `docker run` - lance un containeur. Si l'image n'est pas présente sur l'ordinateur, elle sera automatiquement téléchargée : 

    ```
    $ docker run --name mysql-tutorial -e MYSQL_ROOT_PASSWORD=tutorial -d mysql:latest
    Unable to find image 'mysql:latest' locally
    latest: Pulling from library/mysql
    0bb5c0c24818: Pull complete 
    cbb3106fbb5a: Pull complete 
    550536ae1d5e: Pull complete 
    33f98928796e: Pull complete 
    a341087cff11: Pull complete 
    0e26ac5b33f6: Pull complete 
    c883b83a7112: Pull complete 
    873af5c876c6: Pull complete 
    8fe8ebd061d5: Pull complete 
    7ac2553cf6b4: Pull complete 
    ad655e218e12: Pull complete 
    Digest: sha256:96439dd0d8d085cd90c8001be2c9dde07b8a68b472bd20efcbe3df78cff66492
    Status: Downloaded newer image for mysql:latest
    261024f6e06d57b9c3c01a6732d2f056d865286771713cf67752f818ca38b011
    ```

### 5. Utiliser le containeur

Il existe plusieurs moyens d'interagir avec un containeur : 1) en ligne de commande 2) en ligne de commande via Docker Desktop et 3) pour notre base de données, avec un logiciel classique d'administration de base de données (ici, dBeaver).

#### 5.1. Ligne de commande
Pour le moment, notre containeur est en mode *détaché* (flag `-d`). Pour intergir avec le containeur, on utilise la commande `docker exec` avec les drapeaux `-i` pour interactif et `t` pour allouer un pseudo terminal suivi de l'ID du containeur. Dans un terminal, on lance donc :

```
$ docker exec -it 26102 mysql -u root -p
Enter password: 
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 8
Server version: 8.0.31 MySQL Community Server - GPL

Copyright (c) 2000, 2022, Oracle and/or its affiliates.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> 
```

CQFD :) Le mot de passe à rentrer est celui défini lors de la commande `docker run` (ici : "tutorial"). La documentation sur la commande `docker exec` est disponible sur  https://docs.docker.com/engine/reference/commandline/exec/.

Notre terminal est maintenant celui du containeur MySQL. On peut maintenant interagir en ligne de commande avec notre base de donnes. Par exemple : la liste des base de données est :

```
mysql> SHOW databases;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| performance_schema |
| sys                |
+--------------------+
4 rows in set (0.01 sec)
```

Pour sortir du terminal MySQL, il suffit d'appuyer sur ctrl + D. 

#### 5.2 Ligne de commande via Docker Desktop

Dans l'exemple précédent, la commande `docker exec` a envoyé le reste de la commande (à savoir : `mysql -u root -p`) au terminal du containeur pour ouvrir le terminal spécifique de MySQL. 

Docker Desktop propose un terminal permettant d'interagir avec le containeur sans envoyer une commande (`mysql -u root -p`). Il suffit d'aller dans l'onglet **Containers / Apps** et de cliquer sur le bouton représentant la **CLI** (Command Line Interface). Ensuite, la commande `mysql -u root -p tutorial` indique à Docker Desktop d'ouvir un terminal MySQL :) A nouveau, nous avons accès à la base de données en ligne de commande. 

#### 5.3 Via une application 

Pour se connecter via une application de management de base de données, il est nécessaire de configurer le **mappage des ports**. Les containeurs Docker ont leur propre réseau "DNS" pour communiquer entre eux. Afin de communiquer depuis une application extérieure à Docker, il faut lier (*to map*) un port de notre machine à un de notre containeur Docker. 

Dans notre exemple, on va lier le port 33060 de notre machine au port 33060 du containeur. Pour ce faire, on rajoute simplement `-p 33060:33060` à notre commande `run` :

```
$ docker stop 26
$ docker rm 26

$ docker run --name mysql-tutorial -p 3306:3306 -e MYSQL_ROOT_PASSWORD=tutorial -d mysql:latest 
cca18f17e33c3bf6900e87d9ec22726bc7ffee7f7efae42d0b2be3f55cd3032b
```

La colonne **PORTS** a bien été modifiée :

```
$ docker ps -a
CONTAINER ID   IMAGE          COMMAND                  CREATED              STATUS              PORTS                                                  NAMES
cca18f17e33c   mysql:latest   "docker-entrypoint.s…"   About a minute ago   Up About a minute   0.0.0.0:3306->3306/tcp, :::3306->3306/tcp, 33060/tcp   mysql-tutorial
```

Pour utiliser un outil de management de base de données (par exemple : dBearver est téléchargeable à https://dbeaver.io/download/), il suffit de remplir les champs de connexion avec les données suivantes : 

* Server Host : localhost
* Port : 3306
* Nom d'utilisateur : root
* Mot de passe : tutorial
* allowPublicKeyRetrieval : TRUE (optionnel, dans l'onglet **Propriétés du pilote**)

### 6. Creation d'image avec Dockerfile

Jusque maintenant nous avons utilisé une image MySQL officielle et écrit les instructions Docker en ligne de commande. Pour uun travail en groupe, il serait pratique de configurer les images avant de les partager et de créer les containeurs ! A cet effet, Docker a mis au point les **Dockerfiles**, des fichiers de configuration d'images. 

Pour les utiliser, on crée un fichier nommé `Dockerfile` dans un dossier prévu à cet effet. Par exemple, j'ai créé un dossier **docker-tutorial** qui ne contient que ce fichier et un `README.md` de GitHub :

```
$ touch Dockerfile
$ touch README.md
```

Bien, maintenant écrivons quelques lignes dans le `Dockerfile` :

```
# syntax=docker/dockerfile:1

FROM mysql:latest

ENV MYSQL_ROOT_PASSWORD=tutorial
ENV MYSQL_DATABASE=reflexion-coaching
ENV MYSQL_USER=user1
ENV MYSQL_PASSWORD=password

EXPOSE 3306 33060
```

Ce Dockerfile est minimaliste : il crée une image d'une instance MySQL avec comme mot de passe ROOT *tutorial*, expose les ports (par défaut) 3306 et 33060 et crée un utilisateur `user1` qui aura tous les droits sur la base `reflexion-coaching`. Pour construire cette image, on lance :

```
docker build -t mysql-tutorial-image .
```

Une nouvelle image nommée `mysql-tutorial-image` est apparue sur notre ordinateur :

```
$ docker images 
REPOSITORY       TAG       IMAGE ID       CREATED      SIZE
mysql            latest    3842e9cdffd2   6 days ago   538MB
mysql-tutorial-image   latest    b07957a9892e   6 days ago   538MB
```

Super ! Pour lancer un containeur avec cette nouvelle image, on utilise :

```
$ docker run --name mysql-tutorial -p 3306:3306 -d mysql-tutorial-image
255ec24ccce17fac41b0553574386787c807ac26102c1ef5ade8bb55ac8ed76e

$ docker ps
CONTAINER ID   IMAGE            COMMAND                  CREATED          STATUS          PORTS                                                  NAMES
255ec24ccce1   mysql-tutorial-image   "docker-entrypoint.s…"   54 seconds ago   Up 52 seconds   0.0.0.0:3306->3306/tcp, :::3306->3306/tcp, 33060/tcp   mysql-tutorial
```

Parfait ! Vérifions que le mot de passe a bien été créé automatiquement :

```
$ docker exec -it 255 mysql -u root -p 
Enter password: tutorial
```

CQFD ! Les Dockerfiles sont très pratiques pour améliorer la configuration de base des images. Leurs utilisations sont très fréquentes avec des images Node.js ou Python car il est possible d'installer toutes les dépendances nécessaires et les variables d'environnement.

Malheureusement, on ne peut pas configurer le mappage des ports via un DockerFile car cela concerne un containeur et pas l'image. C'est pourquoi, nous allons parler des fichiers **`Docker Compose`**. 


## 7. Docker Compose

Les fichiers `Docker Compose` sont des fichiers de configuration d'environnement Docker. Ces fichiers permettent de gérer notre réseau / architecture de containeurs. 

### 7.1. Docker Compose basique

Bien, commençons par créer un fichier `docker-compose.yml` dans notre dossier :

```
touch docker-compose.yml
```

Maintenant écrivons quelques lignes d'un docker-compose.yml minimaliste :

```
version: "3.8"

services:
  mysql:
    build: .
```

Les lignes de ce docker-compose.yml signifient :

* `version: "3.8"` : la version des fichiers au format Compose. La version 3.8 est actuellement la plus à jour. 

* `services` : les fichiers Compose permettent de définir un réseau de containeurs Les différents containeurs créent une liste de services. 

* `mysql` : notre service s'appelle *mysql*.

* `build: .` : l'image est construite à partir du Dockerfile dans ce dossier (`.`). Si le Dockerfile etait dans un autre dossier, on aurait du préciser son chemin. 

Ensuite, pour créer l'image et lancer le containeur, on exécute :

```
docker-compose up -d --build
```

Excellent, notre image est créée et notre containeur aussi :) 

``` 
$ docker images
REPOSITORY              TAG       IMAGE ID       CREATED      SIZE
docker-tutorial_mysql   latest    12c010cb4c4f   7 days ago   538MB

$ docker ps
CONTAINER ID   IMAGE                   COMMAND                  CREATED          STATUS         PORTS                 NAMES
203873b87901   docker-tutorial_mysql   "docker-entrypoint.s…"   10 seconds ago   Up 7 seconds   3306/tcp, 33060/tcp   docker-tutorial_mysql_1
```

Pour mettre notre réseau de containeur à l'arrêt (même si, dans ce cas, notre réseau ne contient qu'un containeur), on exécute la commande `docker-compose down`. Cette commande stoppe et supprime tous les containeurs du réseau.

### 7.2. Docker Compose avancé

Nous allons maintenant améliorer la configuration de notre containeur. Commençons par arriver au même niveau qu'avec les lignes de commandes en rajoutant un mappage des ports et un nom au containeur :

```
version: "3.8"

services:
  mysql:
    build: .
    container_name: mysql-tutorial
    ports:
    - 3306:3306
    - 33060:33060
```

On relance notre réseau :

```
$ docker-compose down

$ docker-compose up -d --build
```

Vérifions maintenant que le containeur possède les mêmes caractéristiques qu'en ligne de commande :

```
$ docker ps
CONTAINER ID   IMAGE                   COMMAND                  CREATED         STATUS         PORTS                                                                                      NAMES
1a7a04141919   docker-tutorial_mysql   "docker-entrypoint.s…"   9 seconds ago   Up 4 seconds   0.0.0.0:3306->3306/tcp, :::3306->3306/tcp, 0.0.0.0:33060->33060/tcp, :::33060->33060/tcp   mysql-tutorial
```

CQFD !

## 8. Exécuter un script SQL au démarrage (spécifique MySQL)

Il serait intéressant de configurer notre base de données au démarrage du containeur. Pour ce tutoriel, la configuration de la base de données est simplement la création d'une nouvelle table *Users*.

Nous allons nous servir de la documentation MySQL - Docker (https://hub.docker.com/_/mysql) :

*When a container is started for the first time, a new database with the specified name will be created and initialized with the provided configuration variables. Furthermore, it will execute files with extensions .sh, .sql and .sql.gz that are found in /docker-entrypoint-initdb.d. Files will be executed in alphabetical order. **You can easily populate your mysql services by mounting a SQL dump into that directory and provide custom images with contributed data.** SQL files will be imported by default to the database specified by the MYSQL_DATABASE variable.*

En résumé, ce paragraphe signifie qu'il faut placer nos fichiers SQL dans le dossier Docker `/docker-entrypoint-initdb.d`. Pas de problème, cela peut être fait via les **volumes** ! Commençons par créer notre fichier de configuration `database-configuration.sql` dans le dossier `sql-scripts`:

```
CREATE TABLE Users (
    PersonID int,
    LastName varchar(255),
);
```

Ce petit script crée simplement une table dans la base de données *reflexion-coaching* (comme indiqué dans la documentation). Maintenant, indiquons à Docker de lier `/docker-entrypoint-initdb.d` avec `sql-scripts/` grâce aux volumes :

```
version: "3.8"

services:
  mysql:
    build: .
    container_name: mysql-tutorial
    ports:
    - 3306:3306
    - 33060:33060
    volumes:
    - "./sql-scripts:/docker-entrypoint-initdb.d"

```

Après avoir supprimé les images et containeurs précédents, il suffit de relancer le réseau et de vérifier que la table a bien été créée :

```
$ docker-compose down

$ docker-compose up -d --build
...
Starting mysql-tutorial ... done

$ docker images
REPOSITORY              TAG       IMAGE ID       CREATED      SIZE
docker-tutorial_mysql   latest    537560ebad80   7 days ago   538MB

$ docker ps
CONTAINER ID   IMAGE                   COMMAND                  CREATED          STATUS         PORTS                                                                                      NAMES
558b3b762294   docker-tutorial_mysql   "docker-entrypoint.s…"   41 seconds ago   Up 3 seconds   0.0.0.0:3306->3306/tcp, :::3306->3306/tcp, 0.0.0.0:33060->33060/tcp, :::33060->33060/tcp   mysql-tutorial

$ docker exec -it 55 mysql -u user1 -p 
Enter password: password

mysql> SHOW databases;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| performance_schema |
| reflexion-coaching |
+--------------------+
3 rows in set (0.01 sec)

mysql> USE reflexion-coaching;
Database changed

mysql> show tables;
+------------------------------+
| Tables_in_reflexion-coaching |
+------------------------------+
| Users                        |
+------------------------------+
1 row in set (0.01 sec)
```

Excellent ! En résumé, on a une instance MySQL :
* accesible aux ports 3306 et 33060
* configurée avec une base de données *reflexion-coaching* spécifique au projet
* un utilisateur spécifique 
* un début de schéma de données avec la table *Users*.


## 9. Persistance des données

Le problème majeur avec les containeurs est que dès qu'ils sont supprimés, les données sont supprimées également. Par-exemple, si je crée une nouvelle table *Address* :

```
mysql> CREATE TABLE Addresses (
    AddressID int,
    Address varchar(255)
);
Query OK, 0 rows affected (0.04 sec)

mysql> show tables;
+------------------------------+
| Tables_in_reflexion-coaching |
+------------------------------+
| Addresses                      |
| Users                        |
+------------------------------+
2 rows in set (0.00 sec)
```

et que je quitte mon containeur (`ctrl+D`) et supprime mon containeur (`docker-compose down`), ma nouvelle table de données sera perdue. On peut en faire l'expérience en relançant le docker-compose :

```
$ docker-compose up -d --build     

$ docker ps
CONTAINER ID   IMAGE                   COMMAND                  CREATED         STATUS         PORTS                                                                                      NAMES
537b37847a01   docker-tutorial_mysql   "docker-entrypoint.s…"   7 seconds ago   Up 2 seconds   0.0.0.0:3306->3306/tcp, :::3306->3306/tcp, 0.0.0.0:33060->33060/tcp, :::33060->33060/tcp   mysql-tutorial

$ docker exec -it 53 mysql -u user1 -p 
Enter password: 

mysql> USE reflexion-coaching;
Database changed

mysql> show tables;
+------------------------------+
| Tables_in_reflexion-coaching |
+------------------------------+
| Users                        |
+------------------------------+
1 row in set (0.01 sec)
```

Mince, la table *Adresses* a bien été supprimée ! Ce n'est pas pratique ... 

Pour faire persister les données, nous pouvons à nouveau utiliser la technique des volumes liés. Commençons par créer un dossier **data** qui contiendra les données de base `mkdir data`. Ensuite, lions notre nouveau dossier avec l'endroit où le containeur MySQL stocke les données `/var/lib/mysql`.

```
version: "3.8"

services:
  mysql:
    build: .
    container_name: mysql-tutorial
    ports:
    - 3306:3306
    - 33060:33060
    volumes:
    - "./sql-scripts:/docker-entrypoint-initdb.d"
    - "./data:/var/lib/mysql"
```

C'est reparti :

```
$ docker-compose up -d --build 
```

Une première observation, le contenu du dossier **data** a changé :  

```
ls -l ./data
total 199656
-rw-r-----    1 tigrou  staff    196608 23 nov 16:15 #ib_16384_0.dblwr
-rw-r-----    1 tigrou  staff   8585216 23 nov 16:13 #ib_16384_1.dblwr
drwxr-x---   34 tigrou  staff      1088 23 nov 16:13 #innodb_redo
drwxr-x---   12 tigrou  staff       384 23 nov 16:13 #innodb_temp
-rw-r-----    1 tigrou  staff        56 23 nov 16:13 auto.cnf
-rw-r-----    1 tigrou  staff   3024430 23 nov 16:13 binlog.000001
-rw-r-----    1 tigrou  staff       157 23 nov 16:13 binlog.000002
-rw-r-----    1 tigrou  staff        32 23 nov 16:13 binlog.index
-rw-------    1 tigrou  staff      1680 23 nov 16:13 ca-key.pem
-rw-r--r--    1 tigrou  staff      1112 23 nov 16:13 ca.pem
-rw-r--r--    1 tigrou  staff      1112 23 nov 16:13 client-cert.pem
-rw-------    1 tigrou  staff      1676 23 nov 16:13 client-key.pem
-rw-r-----    1 tigrou  staff      5603 23 nov 16:13 ib_buffer_pool
-rw-r-----    1 tigrou  staff  12582912 23 nov 16:13 ibdata1
-rw-r-----    1 tigrou  staff  12582912 23 nov 16:13 ibtmp1
drwxr-x---    8 tigrou  staff       256 23 nov 16:13 mysql
-rw-r-----    1 tigrou  staff  31457280 23 nov 16:13 mysql.ibd
lrwxr-xr-x    1 tigrou  staff        27 23 nov 16:13 mysql.sock -> /var/run/mysqld/mysqld.sock
drwxr-x---  112 tigrou  staff      3584 23 nov 16:13 performance_schema
-rw-------    1 tigrou  staff      1676 23 nov 16:13 private_key.pem
-rw-r--r--    1 tigrou  staff       452 23 nov 16:13 public_key.pem
drwxr-x---    3 tigrou  staff        96 23 nov 16:13 reflexion@002dcoaching
-rw-r--r--    1 tigrou  staff      1112 23 nov 16:13 server-cert.pem
-rw-------    1 tigrou  staff      1676 23 nov 16:13 server-key.pem
drwxr-x---    3 tigrou  staff        96 23 nov 16:13 sys
-rw-r-----    1 tigrou  staff  16777216 23 nov 16:15 undo_001
-rw-r-----    1 tigrou  staff  16777216 23 nov 16:15 undo_002
```

Excellent ! Ces fichiers sont les fichiers utiles à la construction de nos bases de données. Le dossier `reflexion@002dcoaching` contient notamment les informations sur la base de données *reflexion-coaching*. Maintenant, créons à nouveau une nouvelle table *Addresses* :

```
$ docker ps 
CONTAINER ID   IMAGE                   COMMAND                  CREATED         STATUS         PORTS                                                                                      NAMES
4f5ee52f2417   docker-tutorial_mysql   "docker-entrypoint.s…"   9 minutes ago   Up 9 minutes   0.0.0.0:3306->3306/tcp, :::3306->3306/tcp, 0.0.0.0:33060->33060/tcp, :::33060->33060/tcp   mysql-tutorial

$ docker exec -it 4f5 mysql -u user1 -p 
Enter password: 

mysql> USE reflexion-coaching;
Database changed

mysql> CREATE TABLE Addresses (
    AddressID int,
    Address varchar(255)
);

mysql> SHOW tables;
+------------------------------+
| Tables_in_reflexion-coaching |
+------------------------------+
| Addresses                    |
| Users                        |
+------------------------------+
2 rows in set (0.00 sec)
```

Parfait ! La nouvelle table a été créée et le contenu dossier `/data/reflexion@002dcoaching` a été modifié. 

Maintenant, supprimons le containeur, créons-en un nouveau et vérifions si la table *Addresses* est toujours présente. 

```
$ docker-compose down

$ docker-compose up -d --build  

$ docker ps
CONTAINER ID   IMAGE                   COMMAND                  CREATED         STATUS         PORTS                                                                                      NAMES
07fb2c76b59d   docker-tutorial_mysql   "docker-entrypoint.s…"   8 seconds ago   Up 3 seconds   0.0.0.0:3306->3306/tcp, :::3306->3306/tcp, 0.0.0.0:33060->33060/tcp, :::33060->33060/tcp   mysql-tutorial

$ docker exec -it 07 mysql -u user1 -p 
Enter password: 

mysql> USE reflexion-coaching;
Database changed

mysql> show tables;
+------------------------------+
| Tables_in_reflexion-coaching |
+------------------------------+
| Addresses                    |
| Users                        |
+------------------------------+
2 rows in set (0.00 sec)
```

CQFD ! Les données ont résisté à la suppression du containeur :)

Pour le moment, nous pouvons arrêter le tutoriel ici. Il restera à voir comment créer un véritable réseau d'applications et le CI&CD. 
