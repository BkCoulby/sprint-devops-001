# Sprint DevOps Promo 001
Mon carnet de bord du sprint MeggieOnTheStack.
## Semaine 1, Linux
- Jour 1, installation de ma machine
- Jour 2, le shell
- Jour 3, les users et les permissions
- Jour 4, les processus et systemd, mon premier service
- Jour 5, le réseau et ma page servie par ma machine
## Ce que j'ai cassé et réparé
j'ai cassé mon service veilleur avec un script qui la modifie 
et le réparé avec la procédure suivante:
 - la commande "journalctl -u verificateur -f" pour pour voir 
   l'historique du veuilleur
 - remodifié le script du service et lancé la commande 
   "sudo systemctl daemon-reload" pour que systemd reconnait 
   le script 
## Ce que je ne savais pas faire il y a une semaine
je connaissais pas le fonctionnement des scripts
