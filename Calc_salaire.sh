#!/bin/bash

#verification nbr arguments
if [ $# -lt 2 ]
then 
	echo "ERREUR: commande incomplète, il manque des arguments !"
	exit 1
fi

taux="$1"
nbr_heures="$2"

if (( $(echo "$taux < 10" | bc) )) || (( $(echo "$taux > 50" | bc) ))
then 
	echo "ERREUR: taux mauvais, recommencez !"
	exit 2
fi

brut=0
net=0
norm=0
sup35=0
sup43=0
charges=0

if  [ $nbr_heures -lt 0 ] || [ $nbr_heures -gt 744 ] #744 = 24 heures * 31 jours
then
	echo "ERREUR: nombre d'heure mauvais, recommencez !"
	exit 3

else #calculs
	if [ $nbr_heures -le 151 ] #x<=151
	then 
		norm=$nbr_heures
		sup35=0
		sup43=0
		brut=$(echo "$taux * $norm" | bc)
		charges=$(echo "$brut * 0.23" | bc)
		net=$(echo "$brut - $charges" | bc)

	elif [ $nbr_heures -gt 151 ] && [ $nbr_heures -le 186 ] # 151<x<=186h
	then
		norm=151
		sup35=$(( nbr_heures - 151 ))
		sup43=0
		brut=$(echo "( $taux * $norm ) + ( $sup35 * $taux * 1.25 )" | bc)
		charges=$(echo "$brut * 0.23" | bc)
		net=$(echo "$brut - $charges" | bc)
	
	else #186<x
		norm=151
		sup35=35
		sup43=$(( nbr_heures - 186 ))
		brut=$(echo "( $taux * $norm ) + ( $sup35 * $taux * 1.25 ) + ( $sup43 * $taux * 1.5 )" | bc)
		charges=$(echo "$brut * 0.23" | bc)
		net=$(echo "$brut - $charges" | bc)
	fi
	
	sups=$(echo "$sup35 + $sup43" | bc)
	mont_sup=$(echo "( $sup35 * $taux * 1.25 ) + ( $sup43 * $taux * 1.5 )" | bc)
	
	#Affichage
	echo "=== BULLETIN DE SALAIRE MENSUEL ==="
	echo "heures normales = $norm h"
	echo "heures sups (majoration 25%) = $sup35 h"
	echo "heures sups (majoration 50%) = $sup43 h"
	echo "heures sups totales (majoration 25% et 50%) = $sups h"
	echo "montant heures sups = $mont_sup €"
	echo "salaire brut = $brut €"
	echo "charges = $charges €"
	echo "salaire net = $net €"

fi
