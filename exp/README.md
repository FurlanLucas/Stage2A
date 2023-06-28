# Labview thermal identification

Celui est un programme Labview pour commander l'entrée e l'acquisition de données appliqué à un système thermique dans le cadre d'un stage realisé au Laboratoire de l’Intégration du Matériau au Système (IMS) et au Institut de mécanique et d’ingénierie (I2M). Il utilise une alimentation à haut rendement de la série EA-PSI 9200-25 et un enregistreur de données Sefram DAS 240. Les deux sont contrôlés par une interface labview.

Auteur : Lucas Furlan

## Drivers et packages

Le dossier << labview main project >> contien tous les fichiers labview pour l'utilisation du programme. Par contre, il est absolutment nécessaire télecherger et installer les drivers et packages pour faire la communication avec les deux machines. Pour utiliser le logiciell correctement, il faut suivre le procedure suivant :

1. Executer le installateur du driver PSI9000 USB ;
2. Copiez et collez le dossier IF-XX avec tous ses fichier dans le dossier des packages Labview. Normalement, il est localisé dans le dossier que labView a été installé, par example : << C:Programmes(x86)\NationalInstruments\LabVIEW (version)\instr.lib >>.
3. Télechargez et executez le installateur du package NVISA, disponible en << https://www.ni.com/fr-fr/support/downloads/drivers/download.ni-visa.html#480875 >>. Il permetra de utiliser le package Modbus Master pour le protocolle TCP-IP. Cette partie peut prendre du temps.
4. Installer le Modbus avec le lien << https://www.ni.com/fr-fr/support/downloads/tools-network/download/unpackaged.modbus-master.374378.html >>. Il sera necessaire se connecter avec une compte d'utilisateur NI.



## En utilisant le logiciell

Un fois que le programme va être executé, l'user doit voir dans l'écran la face avant du VI. Il est constittué d'une partie de génération de données à gauche et d'aquisition de données à droite.


![Alt text](https://github.com/FurlanLucas/Stage2A/blob/main/exp/mdFig/mainVIp.png)

![alt text](https://github.com/FurlanLucas/Stage2A/blob/main/exp/mdFig/TCPIP.bmp)
