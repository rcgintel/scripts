#! /usr/intel/bin/python3.6.3a

import UsrIntel.R1
import pandas as pd
import sqlalchemy as sa
import optparse
import sqlite3
import re
import subprocess
import configparser


parser = optparse.OptionParser("user arg1")
parser.add_option("-C", "--csv", dest="csv", default="Nil" , help = "give the csv file name")
parser.add_option("-S", "--sql", dest="sql", default="Nil", help = "give the sql location")
parser.add_option("-T", "--table", dest="table", default="Table1", help="give the table name")
#parser.add_option("-N", "--name", dest="name", default="py_terminal", help="give the name of the terminal")
(option, args) = parser.parse_args()


if option.csv == "Nil":
	print("Please give the csv file location")
	sys.exit()

if option.sql == "Nil":
	print("Please give the sql location")
	sys.exit()

#df = pd.read_csv("gen12p93dl2.connectivity_power.csv.bak")
df = pd.read_csv(option.csv)
df.head()
#engine = sa.create_engine('sqlite:///save.db', echo = True)
engine = sa.create_engine("sqlite:///"+option.sql, echo = True)
sqlConn = engine.connect()

command = "drop table if exists "+option.table+";"
sqlConn.execute(command)

sqlTable = option.table
df.to_sql(sqlTable, sqlConn)
sqlConn.close()

