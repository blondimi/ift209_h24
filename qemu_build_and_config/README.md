# Amélioration de configuration et automatisation de la compilation/assemblage sur emulateur QEMU

## Introduction
Ce guide a pour but de vous aider à configurer l'émulateur QEMU sur un environnement Linux, améliorer le terminal de base et de vous aider à automatiser la compilation et l'assemblage de vos projets.

## Prérequis
- Un environnement Linux (Ubuntu, Debian, Fedora, Arch, etc.)
- Un émulateur QEMU installé
Ici, j'utilise même une distribution basé sur Arch et le package manager `nixpkg` pour installer QEMU temporairement dans un environnement isolé.
- 

Par exemple, avec `nixpkg`, on créer un environnement isolé avec la commande: 
`nix-shell -p qemu` 
pour installer QEMU. Sinon, installez-le avec votre package manager (i.e. `sudo apt install qemu` etc.).
- Avoir modifié le fichier /etc/hosts pour ajouter l'adresse IP de l'émulateur QEMU à la fin du fichier:
`sudo echo "127.0.1.1        armv8" >> /etc/hosts`
- Une clé SSH pour se connecter à l'émulateur:
    - Générer une clé SSH: 
    `ssh-keygen -t rsa -b 4096 -C "un_commentaire_identifiant_votre_clé"` (en remplaceant le commentaire...). 
    Entré le nom de fichier de la clé (i.e. `qemu_ift209_rsa4096`) et un mot de passe.
    - Lancer l'agent SSH `eval "$(ssh-agent -s)"`.
    - Ajouter la clé à l'agent SSH: `ssh-add ~/.ssh/qemu_ift209_rsa4096`.
On devra éventuellement copié la clé publique sur l'émulateur pour se connecter sans mot de passe.
- Avoir téléchargé les images de l'émulateur et avoir créer un fichier `SOURCES` dans le même parent où se trouvent les images. (voir [guide site web IFT-209](https://mblondin.espaceweb.usherbrooke.ca/cours/ift209_h24/armv8/acces_vm.pdf)) 
Par exemple, dans le repertoire `ift-209`:
`ls`
`ìmages/ SOURCES/`
- Avoir téléchargé le fichier `build-ift209.sh` et le fichier `.bashrc` qui se trouve ici sur le repo GitHub dans le répertoire `qemu_build_and_config/`.

## Connection sshfs à l'émulateur
1. Naviguez vers le répertoire parent où se trouve le répertoire `images` et le fichier `SOURCES`.

2. Lancer l'émulateur avec la commande:
```bash
qemu-system-aarch64 -M virt -cpu cortex-a57 -m 2048 \
-drive file=./images/arm64.img,if=none,id=blk \
-device virtio-blk-device,drive=blk \
-device virtio-net-device,netdev=net0 \
-netdev user,id=net0,hostfwd=tcp::2016-:22,hostfwd=tcp::2080-:80, \
-kernel ./images/vmlinuz-4.2.0-1-arm64 \
-initrd ./images/initrd.img-4.2.0-1-arm64 \
-append "root=/dev/vda2 rw console=ttyAMA0 --" \
-nographic
```
3. Entrez ensuite le login et le mot de passe pour ouvrir une session sur l'émulateur.

Nous sommes maintenant dans le $HOME de l'utilisateur.

4. Modifier le fichier `~/.ssh/authorized_keys` pour ajouter la clé publique de l'utilisateur. 

- Tout d'abord, avec un autre terminal, copier la clé publique sur l'émulateur:
```bash
cd ~/.ssh
cat le_nom_de_votre_cle_rsa4096.pub
```
- Copier dans votre clipboard la clé publique.
- Retourner dans le terminal où vous êtes connecté à l'émulateur et éditer le fichier `~/.ssh/authorized_keys`:
```bash
cd ~/.ssh
# Avec vi ou nano, ajouter la clé publique à la fin du fichier.
vi authorized_keys
#SHIFT + G pour aller à la fin du fichier
#o pour ajouter une nouvelle ligne
#CTRL + SHIFT + V pour coller la clé publique
# :wq pour sauvegarder et quitter
```

5. Monter le répertoire de l'émulateur sur votre système hôte avec `sshfs`:
```bash
sshfs -p 2016 root@armv8:/root/SOURCES/ift209/ ./SOURCES/
```
Vous pouvez maintenant naviguer dans le répertoire `SOURCES` et voir les fichiers de l'émulateur a partir du système hôte. Donc dans terminal 1/2 on a l'émulateur QEMU et dans le terminal 2/2 on a le système hôte qui peut accéder au système de fichier de l'émulateur.

## Transfert du `.bashrc` et script de compilation `build-ift209.sh` vers l'émulateur
1. En utilisant le terminal hôte, copier les fichiers `.bashrc` et `build-ift209.sh` dans le répertoire `SOURCES` de l'émulateur:
```bash
# Naviguez vers le répertoire où se trouve les fichiers téléchargés
cd chemin_vers_le_repertoire_ou_se_trouve_les_fichiers

# Copier les fichiers dans le répertoire de l'émulateur
cp qemu_build_and_config/ chemin_vers_le_repertoire_parent/SOURCES/
```

2. Copie des fichiers de config et scripts d'automatisation

Dans le terminal de l'émulateur:

- Ecraser le fichier `.bashrc` avec celui du répertoire `SOURCES`:
```bash
cd ~/SOURCES/ift209/qemu_build_and_config/
cp .bashrc ~/
```
- Creer un rpertoire `custom_bins` dans le $HOME de l'utilisateur:
```bash
mkdir ~/custom_bins
```
- Creer un lien symbolique vers le script de compilation `build-ift209.sh` dans le répertoire `custom_bins`:
```bash
cd ~/custom_bins
ln -s ~/SOURCES/ift209/qemu_build_and_config/build-ift209.sh build-ift209
chmod +x build-ift209
```
On peut maintenant source le fichier `.bashrc` pour appliquer les changements:
```bash
source ~/.bashrc
```
## Couleur et prompt amélioré
Le fichier `.bashrc` contient des configurations pour améliorer le terminal. Il ajoute des couleurs pour les commandes et permet de track le statut git d'un répertoire. Il ajoute aussi un prompt amélioré pour afficher le nom de l'utilisateur, le nom de l'hôte, le répertoire courant et le statut git.


## Utilisation du script de compilation
Puisque nous avons fait le lien entre le répertoire `custom_bins` et le fichier `.bashrc`, nous pouvons maintenant utiliser le script de compilation `build-ift209.sh` à partir de n'importe quel répertoire en utilisant la commande:
```bash
build-ift209 nom_du_fichier.s
```
Le script va assembler le fichier `.s` et le linker en utilisant le `makefile` fournit pour créer un fichier exécutable `nom_du_fichier` dans le sous-repertoire `build/` en utilisant le fichier `.s`.

Le script s'occupe également de faire le nettoyage des fichiers temporaires et des fichiers exécutables, de valider si l'assemblage et le linking ont réussi et d'afficher un message d'erreur si l'assemblage ou le linking ont échoué.

La raison pour laquelle le fichier exécutable et objet sont placés dans un sous-répertoire `build/` est pour éviter de polluer le répertoire courant avec des fichiers temporaires et de pouvoir facilement ajouter le répertoire `build/` dans le fichier `.gitignore` pour éviter de tracker les fichiers temporaires.

Le prend également un argument option `-e --execute` donc `build-ift209 nom_du_fichier.s -e` pour exécuter le fichier exécutable après l'assemblage et le linking directement. C'est utile si nous n'avons pas a passer des fichiers (via stdin) ou 'pipe' l'executable avec d'autre commande shell.