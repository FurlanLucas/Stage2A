# Caractérisation et identification de capteurs de flux en conditions extrêmes  

Travail présenté à l'ENSEIRB-MATMECA dans l'Institut National Polytechinique de Bordeaux comme stage de deuxiéme année, realisé au Laboratoire de l’Intégration du Matériau au Système (IMS) et au Institut de mécanique et d’ingénierie (I2M).

Auteur : Lucas Furlan
Encadrants : Stéphane Victor, Jean-Luc Battaglia et Andrzej Kusiak.

## Labview thermal identification

Celui est un programme Labview qui a été conçu pour commander l'entrée e l'acquisition de données appliqué à un système thermique. Il utilise une alimentation à haut rendement de la série EA-PSI 9200-25 et un enregistreur de données Sefram DAS 240. La communication avec le premier est faite à aide du protocole Modbus USB et le deuxième utilise le Modbus TCP-IP. Dans le cadre de l'implatation de cette interface, il est importante remarquer que un cable ethernet commun ne peut pas être utilisé : il faut un cable ethernet croisé ou un switch (ce qui a été utilisé).

### Drivers et packages

Le dossier << labview main project >> contien tous les fichiers labview pour l'utilisation du programme. Par contre, il est absolutment nécessaire télecherger et installer les drivers et packages pour faire la communication avec les deux machines. Pour ce dernier, il faut suivre le procedure suivant :

1. Executer le installateur du driver PSI9000 USB ;
2. Copiez et collez le dossier IF-XX avec tous ses fichier dans le dossier des packages Labview. Normalement, il est localisé dans le même dossier que labView a été installé, par example : << C:Programmes(x86)\NationalInstruments\LabVIEW (version)\instr.lib >>.
3. Télechargez et executez le installateur du package NVISA, disponible en << https://www.ni.com/fr-fr/support/downloads/drivers/download.ni-visa.html#480875 >>. Il permetra d'utiliser le package Modbus Master pour le protocolle TCP-IP. Cette partie peut prendre du temps.
4. Installer le Modbus avec le JKI VI Package Manager (VIPM), en utilisant le lien << https://www.ni.com/fr-fr/support/downloads/tools-network/download/unpackaged.modbus-master.374378.html >>. Il sera necessaire se connecter avec une compte d'utilisateur NI.


### En utilisant le logiciell

Un fois que le programme va être executé, l'user doit voir dans l'écran la face avant du VI. Il est constitué d'une partie de génération de données à gauche et d'aquisition de données à droite. 

La génération de données pseudo aléatoire (PRBS) peut être faite soit avec Labview il-même, en specifient les valeurs de fréquence et emplitude, soit avec la lecture d'un fichier CSV. La  


![Alt text](https://github.com/FurlanLucas/Stage2A/blob/main/mdFig/mainVIp.png)

Pour connaître l'adresse IP du DAS 240, il est necessaire aller dans << setup >> dans le menu du enrigestreur.

![alt text](https://github.com/FurlanLucas/Stage2A/blob/main/mdFig/TCPIP.bmp)


Ce dossier contien tous les fichiers utilisée pour

## freqAnalysis
Do the frequency analysis for the transfert function F(s). Two different analysis are avaiable with 1D and 3D models. In both the Pade approximation for e^x and for some orders are shown and compared with respect to the non approximated solution.