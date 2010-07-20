#!/usr/bin/env python
#-*- coding: UTF-8 -*-


# ce script collecte des statistiques sur les prouveurs

import sys

import lib

# connexion DB
import sqlite3

conn = sqlite3.connect("output.db")
cursor = conn.cursor()

# trouver les prouveurs

provers = cursor.execute("select distinct prover from runs").fetchall()
provers = [line[0] for line in provers]

print "prouveurs trouvés :", ", ".join(provers)

lib.print_sep()
print ""


# collecter les statistiques (succès, échecs) de chaque prouveur

stats = {}

for prover in provers:

  successes = cursor.execute("""
    SELECT DISTINCT file,goal FROM runs
    WHERE result = "Valid"
    AND prover = "%s"
    """ % prover).fetchall()


  failures = cursor.execute("""
    SELECT DISTINCT file,goal FROM runs
    WHERE result = "Timeout"
    AND prover = "%s"
    """ % prover).fetchall()

  stats[prover] = (len(successes), len(failures))


# mettre en forme

table = [["prouveur", u"nombre de succès", u"nombre d'échecs", "nombre total"]]

for prover in provers:

  entry = [prover, stats[prover][0], stats[prover][1], stats[prover][0] + stats[prover][1]]
  table.append(entry)

lib.print_columns(table, sep = " ")



# trouver quels prouveurs sont supérieurs les uns aux autres

lib.print_sep()

order = {}

for p1, p2 in [(p1,p2) for p1 in provers for p2 in provers if p1 != p2]:


  print "compare", p1, p2,
  sys.stdout.flush()
  sups = lib.superior(cursor, p1, p2)

  # effacer la ligne
  lib.erase_line()

  order[ (p1, p2) ] = len(sups)

print "\n"

# affiche l'ordre partiel

table = [ ["prouveur1", ">", "prouveur2", "de", "nombre de tasks"] ]

for ((p1,p2), num) in order.iteritems():
  table.append( [p1, "", p2, "", unicode(num)] )

def getKey(x):
  try:
    return int(x[4])
  except:
    return 0

table.sort(key = getKey)

lib.print_columns(table, sep = " ") # TODO : afficher un tableau
