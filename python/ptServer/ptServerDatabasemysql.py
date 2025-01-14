#! /usr/intel/bin/python3.10.8
import sys
import UsrIntel.R1

sys.path.append('/nfs/site/disks/vmisd_vclp_efficiency/rcg/server/fullServer/venvRcg/lib/python3.11/site-packages')
import configparser
import globalVariable
import os
import code
import time
from rich import print
import mysql.connector
import datetime
import functools
import timingCommands

from log_config import get_client_logger, get_server_logger

def log_performance(logger_type):
    def decorator(func):
        @functools.wraps(func)
        def wrapper(*args, **kwargs):
            start_time = time.time()
            result = func(*args, **kwargs)
            end_time = time.time()
            if logger_type == "server":
                logger = get_server_logger()
            elif logger_type == "client":
                logger = get_client_logger()
            else:
                raise ValueError(f"Invalid logger type: {logger_type}")
            logger.debug(f"{func.__name__} executed in {end_time - start_time:.4f} seconds")
            return result
        return wrapper
    return decorator
################### procedures

def connectMySql():
    #connection_config = {
    #    "host": "maria3119-lb-ba-in.dbaas.intel.com",
    #    "port": 3307,
    #    "user": "rcg_ptServer",
    #    "password": "PTServer123",
    #    "database": "rcg",
    #    "sql_mode":"TRADITIONAL",
    #    "tls_versions": ["TLSv1.2", "TLSv1.1"]
    #}
    connection_config = {
        "host": "maria4598-lb-fm-in.dbaas.intel.com",
        "port": 3306,
        "user": "rcg_ptServer",
        "password": "PTServer123",
        "database": "rcg",
        "sql_mode":"TRADITIONAL",
        "tls_versions": ["TLSv1.2", "TLSv1.1"]
    }

    connection = mysql.connector.connect(**connection_config)
    return connection

def create_database(connection, schema):
    cursor = connection.cursor(dictionary=True)
    # Execute the schema SQL statement
    for schemaCmd in schema.split(";"):
        if schemaCmd != "":
            cursor.execute(schemaCmd+";")
    # Committing changes and closing the connection
    connection.commit()
    connection.close()

################# variable config

def setupDatabase():
    """this proc is for setting up the database
    Schema definition
    commandInputTable = ["commandId","command","user","corner","machineName","serviced","complete","outputLocation"]
    machineTrackerTable = ["machineId","machineName","corner","status","load","commandId"]

    """
    #global ptServerCLI.configFile
    config = configparser.ConfigParser()
    project = globalVariable.project
    config.read(globalVariable.configFile)
    databaseLocation = config[project]["database"]

    ################ code
    commandInputTable = ["commandId","command","user","corner","machineName","serviced","complete","outputLocation","workWeek"]
    machineTrackerTable = ["machineId","machineName","corner","status","loads","commandId","workWeek"]
    userVariablesTable = ["variableId","variableName", "user","variableValue"]

    cmd = """CREATE TABLE IF NOT EXISTS commandInputTable (
        commandId INT AUTO_INCREMENT PRIMARY KEY,
        start_time DATETIME DEFAULT CURRENT_TIMESTAMP,
        command TEXT NOT NULL,
        user varchar(20) NOT NULL,
        corner varchar(100) NOT NULL,
        machineName varchar(200),
        serviced INT default 0,
        complete INT default -1,
        outputLocation TEXT,
        workWeek varchar(30) NOT NULL,
        sectionTop varchar(30) default " ",
        blockName varchar(30) NOT NULL,
        projectName varchar(30) NOT NULL,
        runTime INT
    );

    CREATE TABLE IF NOT EXISTS machineTrackerTable (
        machineId INT AUTO_INCREMENT PRIMARY KEY,
        start_time DATETIME DEFAULT CURRENT_TIMESTAMP,
        machineName varchar(200) NOT NULL,
        corner varchar(100) NOT NULL,
        status varchar(20) NOT NULL,
        loads INT DEFAULT  0,
        commandId INT DEFAULT 0,
        workWeek varchar(20) NOT NULL,
        sectionTop varchar(30) default " ",
        blockName varchar(30) NOT NULL,
        projectName varchar(30) NOT NULL,
        heartBeat INT DEFAULT 0,
        totalRunTime INT
    );

    CREATE TABLE IF NOT EXISTS outputTrackerTable (
        id INT AUTO_INCREMENT PRIMARY KEY,
        commandId INT NOT NULL,
        corner varchar(100) NOT NULL,
        workWeek varchar(100) NOT NULL,
        projectName varchar(100) NOT NULL,
        blockName varchar(30) NOT NULL,
        cellName varchar(100) NOT NULL,
        incrementalDelay float NOT NULL,
        transitionDelay float NOT NULL,
        objType varchar(100) NOT NULL,
        fanout INT NOT NULL,
        cap float NOT NULL,
        totalDelay float NOT NULL
    );

    CREATE TABLE IF NOT EXISTS compareInputTable (
        compareId INT AUTO_INCREMENT PRIMARY KEY,
        user TEXT NOT NULL,
        commandID INTEGER NOT NULL,
        pathName TEXT NOT NULL,
        comparePoint INTEGER NOT NULL,
        startPoint TEXT NOT NULL,
        endPoint TEXT NOT NULL,
        pinsList TEXT NOT NULL,
        slack TEXT NOT NULL,
        corner TEXT NOT NULL,
        workWeek TEXT NOT NULL,
        sectionTop TEXT default " ",
        nameOfBlock TEXT NOT NULL,
        projectName TEXT NOT NULL
    );

    create table if not exists userVariablesTable (
        variableId INT AUTO_INCREMENT PRIMARY KEY,
        variableName varchar(30) NOT NULL,
        user varchar(20) NOT NULL,
        variableValue TEXT NOT NULL
    );"""
    connection = connectMySql()
    create_database(connection,cmd)

@log_performance("client")
def writeToCommandInputTable(command):
    """
    This function takes a command as argument and adds it to the CommandInputTable in the database. 
    Used extensively in timingCommands.py to write commands into the table.
    """
    #print(command)
    #global ptServerCLI.configFile
    conn = connectMySql()
    
    corner = globalVariable.corner
    user = os.environ['USER']
    config = configparser.ConfigParser()
    project = globalVariable.project
    config.read(globalVariable.configFile)
    
    #conn = sqlite3.connect(databaseLocation)
    #cursor = conn.cursor()
    curTim = datetime.datetime.now()
    cursor = conn.cursor(dictionary=True)
    datas = [
        (curTim, command, corner, user, globalVariable.project, globalVariable.runName, globalVariable.blockName ),
    ]   

    sql = "INSERT INTO commandInputTable (start_time, command, corner, user, projectName, workWeek, blockName) VALUES (%s, %s, %s, %s, %s, %s, %s)"
    #code.interact(local=locals())
    for data in datas:
        cursor.execute(sql, data)
        id = cursor.lastrowid
    conn.commit()
    conn.close()
    getMachineStatusFromCommandInputTable(id)
    return id

@log_performance("server")
def writeToMachineTrackerTable(dataSql):
    """
    Function stores data about all initiated machines in the database.
    Used by  ptServerMachineSpawn.py to inititialize ptShells
    """
    corner = globalVariable.corner
    user = os.environ['USER']
    config = configparser.ConfigParser()
    project = globalVariable.project
    config.read(globalVariable.configFile)
    databaseLocation = config[project]["database"]
    conn = connectMySql()
    #conn = sqlite3.connect(databaseLocation)
    cursor = conn.cursor(dictionary = True)
    print(dataSql)
    sql = "INSERT INTO machineTrackerTable (start_time,machineName,corner,status,loads,commandId,workWeek,projectName,blockName) VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s)"
    #code.interact(local=locals())
    cursor.execute(sql, dataSql)
    conn.commit()
    conn.close()

@log_performance("client")   
def writeToUserVariablesTable(dataSql):
    """
    Function writes to the UserVariablesTable.
    Used by set_var fucntion in timingCommands.py
    """
    user = os.environ['USER']
    config = configparser.ConfigParser()
    project = globalVariable.project
    databaseName = globalVariable.globalDatabaseName
    config.read(globalVariable.configFile)
    databaseLocation = config[project]["database"]
    #conn = sqlite3.connect(databaseLocation)
    conn = connectMySql()
    cursor = conn.cursor(dictionary = True)
    #userVariablesTable = ["variableId","variableName", "user","variableValue"]
    print(dataSql)
    sql = "INSERT INTO "+databaseName+".userVariablesTable (variableName,user,variableValue) VALUES (%s,%s,%s)"
    #code.interact(local=locals())
    cursor.execute(sql, dataSql)
    conn.commit()
    conn.close()

@log_performance("client")
def writeTocompareInputTable(dataSql,returnlastrow = False):
    """
    Writes data initially to the Compare Input table for compare_timing command.
    Used in timingCommands.py
    """
    sql = "INSERT INTO compareInputTable (user,commandID,pathName,comparePoint,startPoint,endPoint,pinsList,slack,corner,workWeek,sectionTop,nameOfBlock,projectName) VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)"
    #code.interact(local=locals())
    conn = connectMySql()
    cursor = conn.cursor(dictionary = True)

    cursor.execute(sql, dataSql)
    if returnlastrow:
        id = cursor.lastrowid
    conn.commit()
    conn.close()
    if returnlastrow:
        return id

@log_performance("client")
def getCompleteFromCommandInputTable(commandId):
    """
    Checks if command whose commandId is passed as argument is serviced yet. Returns location of report when services. waits for 2 seconds and repolls if not serviced
    Used extensively in timingCommands.py
    """
    config = configparser.ConfigParser()
    project = globalVariable.project
    globalDatabaseName = globalVariable.globalDatabaseName
    config.read(globalVariable.configFile)
    databaseLocation = config[project]["database"]
    #conn = sqlite3.connect(databaseLocation)

    flag = 0
    #code.interact(local=locals())
    #sqlcmd = "select complete from "+globalDatabaseName+".commandInputTable where commandId = \'"+str(commandId)+"\';"
    sqlcmd = "SELECT complete FROM {}.commandInputTable WHERE commandId = %s;".format(globalDatabaseName)
    conn = connectMySql()
    cursor = conn.cursor()
    printCount = -1
    while flag != 1:
        if printCount > 10:
            print("time getCompleteFromCommandInputTable: ",datetime.datetime.now())
            printCount = 0

        if printCount == -1:
            print("time getCompleteFromCommandInputTable: ",datetime.datetime.now())

        printCount += 1
        time.sleep(1)
        #cursor.execute(sqlcmd)
        cursor.execute(sqlcmd, (commandId,))
        flag = cursor.fetchone()[0]
        conn.commit()
        #print("Command in wait state and flag is : ", flag)
    #conn.close()
    #conn = connectMySql()
    #cursor = conn.cursor()
    #sqlcmd = "select outputLocation from commandInputTable where commandId = \'"+str(commandId)+"\';"
    sqlcmd = "SELECT outputLocation FROM {}.commandInputTable WHERE commandId = %s;".format(globalDatabaseName)
    #cursor.execute(sqlcmd)
    cursor.execute(sqlcmd, (commandId,))
    location = cursor.fetchone()[0]
    print("the location of report is ", location)
    cursor.close()
    conn.close()
    return location


def get_values_from_database(database, table, columns, condition=""):
    """
    Common interface for all database reads to enable easy migration of databases. database argument is redundant. maintained for compatibilty to sqlite3 
    """
    try:
        # Connect to the SQLite database in write mode
        connection = connectMySql()
        cursor = connection.cursor(dictionary=True)
        # Construct the SQL query to retrieve the specified columns
        columns_str = ', '.join(columns)
        if condition == "":
            query = f"SELECT {columns_str} FROM {table};"
        else:
            ## here condition should be the eniter where for example
            ## condition = "where serviced = 0"
            query = f"SELECT {columns_str} FROM {table} {condition};"
        #print(query)
        #code.interact(local=locals())
        cursor.execute(query)
        # Fetch all the results
        results = cursor.fetchall()
        return results  # Return the fetched results
    except mysql.connector.Error as e:
        print("Error retrieving values from database:", e)
        return None
    finally:
        if connection in globals() or connection in locals():
            if connection:
                connection.close()  # Close the database connection





def update_field_in_database(database, table, column_to_update, new_value, condition):
    """
    Common interface for all database data UPDATES (not adding new entries) to enable easy migration of databases. database argument is redundant. maintained for compatibilty to sqlite3 
    """
    try:
        # Connect to the SQLite database
        connection = connectMySql()
        cursor = connection.cursor(dictionary=True)
        # Construct the SQL query to update the field
        query = f"UPDATE {table} SET {column_to_update} = \'{new_value}\' {condition} ;"
        #print(query)
        cursor.execute(query)
        # Commit the transaction
        connection.commit()
        #print("Field updated successfully.")
    except mysql.connector.Error as e:
        print("Error updating field in database:", e)
    finally:
        if connection:
            connection.close()  # Close the database connection


@log_performance("client")
def getAllWorkWeek():
    config = configparser.ConfigParser()
    project = globalVariable.project
    blockName = globalVariable.blockName
    config.read(globalVariable.configFile)
    databaseLocation = config[project]["database"]
    table = "machineTrackerTable"
    column = ["workWeek"]
    condition = " where projectName = \'"+project+"\' and blockName = \'"+blockName+"\' "
    sqlOutput = get_values_from_database(databaseLocation,table,column,condition)
    #code.interact(local=locals())
    unique_work_weeks = sorted({row['workWeek'] for row in sqlOutput})
    return unique_work_weeks


@log_performance("client")
def getAllblockName():
    config = configparser.ConfigParser()
    project = globalVariable.project
    config.read(globalVariable.configFile)
    databaseLocation = config[project]["database"]
    table = "machineTrackerTable"
    column = ["blockName"]
    condition = " where projectName = \'"+project+"\' "
    sqlOutput = get_values_from_database(databaseLocation,table,column,condition)
    #code.interact(local=locals())
    unique_block_name = sorted({row['blockName'] for row in sqlOutput})
    return unique_block_name

@log_performance("server")
def getAllNotServicedJobs():
    config = configparser.ConfigParser()
    project = globalVariable.project
    config.read(globalVariable.configFile)
    databaseLocation = config[project]["database"]
    table = "commandInputTable"
    column = ["commandId","corner"]
    condition = "where serviced = 0 "
    sqlOutput = get_values_from_database(databaseLocation,table,column,condition)
    return sqlOutput

#machineTrackerTable = ["machineId","machineName","corner","status","loads","commandId","workWeek"]

@log_performance("server")
def getAllAvailbeMachineForCorner(corner):
    config = configparser.ConfigParser()
    project = globalVariable.project
    workWeek = globalVariable.runName
    config.read(globalVariable.configFile)
    databaseLocation = config[project]["database"]
    table = "machineTrackerTable"
    column = ["machineId","machineName","workWeek"]
    condition = "where status = \'ready\' and corner = \'"+corner+"\' and workWeek = \'"+workWeek+"\' and status = \'ready\'"
    #code.interact(local=locals())
    sqlOutput = get_values_from_database(databaseLocation,table,column,condition)
    return sqlOutput

@log_performance("server")
def getAllAvailbeMachine():
    config = configparser.ConfigParser()
    project = globalVariable.project
    runName = globalVariable.runName
    config.read(globalVariable.configFile)
    databaseLocation = config[project]["database"]
    table = "machineTrackerTable"
    column = ["machineId","machineName","workWeek","projectName","heartBeat"]
    condition = "where projectName = \'"+project+"\' and workWeek = \'"+runName+"\' and status = \'ready\' "
    #code.interact(local=locals())
    sqlOutput = get_values_from_database(databaseLocation,table,column,condition)
    #print(sqlOutput)
    return sqlOutput


@log_performance("server")
def updateMachineHeartbeat(machineId, hbeat):
    config = configparser.ConfigParser()
    project = globalVariable.project
    databaseName = globalVariable.globalDatabaseName
    config.read(globalVariable.configFile)
    databaseLocation = config[project]["database"]
    table = databaseName+".machineTrackerTable"
    column_to_update = "heartBeat"
    new_value = hbeat
    condition = "where machineId = "+str(machineId)
    #code.interact(local=locals())
    update_field_in_database(databaseLocation, table, column_to_update, new_value, condition)


#commandInputTable = ["commandId","command","user","corner","machineName","serviced","complete","outputLocation","workWeek"]

@log_performance("server")
def updateMachineNameInCommandInputTable(machineName,commandId):
    config = configparser.ConfigParser()
    project = globalVariable.project
    databaseName = globalVariable.globalDatabaseName
    config.read(globalVariable.configFile)
    databaseLocation = config[project]["database"]
    table = databaseName+".commandInputTable"
    column_to_update = "machineName"
    new_value = machineName
    condition = "where commandId = "+str(commandId)
    #code.interact(local=locals())
    update_field_in_database(databaseLocation, table, column_to_update, new_value, condition)

@log_performance("server")
def setMachineKilledInMachineTrackerTable(machineName,workWeek,project):
    config = configparser.ConfigParser()
    #project = globalVariable.project
    databaseName = globalVariable.globalDatabaseName
    config.read(globalVariable.configFile)
    databaseLocation = config[project]["database"]
    table = databaseName + ".machineTrackerTable"
    column_to_update = "status"
    new_value = "killed"
    condition = "where machineName = \'" + str(machineName) + "\' and workWeek = \'" + str(workWeek) + "\' and projectName = \'"+ str(project)+"\'"
    update_field_in_database(databaseLocation, table, column_to_update, new_value, condition)
    column_to_update = "heartBeat"
    new_value = 0
    condition = "where machineName = \'" + str(machineName) + "\' and workWeek = \'" + str(workWeek) + "\' and projectName = \'"+ str(project)+"\'"
    update_field_in_database(databaseLocation, table, column_to_update, new_value, condition)
    column_to_update = "status"
    new_value = "loading"
    condition = "where machineName = \'" + str(machineName) + "\' and workWeek = \'" + str(workWeek) + "\' and projectName = \'"+ str(project)+"\'"
    update_field_in_database(databaseLocation, table, column_to_update, new_value, condition)




@log_performance("client")
def getMachineStatusFromCommandInputTable(commandId):
    """
    Checks if command whose commandId is passed as argument is assigned a machine yet. Returns fail if not assigned in 30 secs
    """
    config = configparser.ConfigParser()
    project = globalVariable.project
    globalDatabaseName = globalVariable.globalDatabaseName
    config.read(globalVariable.configFile)
    databaseLocation = config[project]["database"]
    #conn = sqlite3.connect(databaseLocation)

    flag = 0
    #code.interact(local=locals())
    #sqlcmd = "select complete from "+globalDatabaseName+".commandInputTable where commandId = \'"+str(commandId)+"\';"
    sqlcmd = "SELECT start_time, machineName FROM {}.commandInputTable WHERE commandId = %s;".format(globalDatabaseName)
    conn = connectMySql()
    cursor = conn.cursor()
    printCount = -1
    #breakpoint()
    while flag != 1:
        #cursor.execute(sqlcmd)
        cursor.execute(sqlcmd, (commandId,))
        data = cursor.fetchone()
        time = data[0]
        machineName = data[1]
        delay = datetime.datetime.now() - time
        #code.interact(local=locals())
        if (delay.total_seconds() < 10) and machineName == None:
            flag = 0
            conn.commit()
        elif (delay.total_seconds() < 10) and machineName != "":
            flag = 1
            conn.commit()
        elif (delay.total_seconds() > 10) and machineName == None:
            print("Machine is not assigned please check with SPEO if the machineSpawnCode is running")
            timingCommands.show_info()
            sqlcmd = "delete FROM {}.commandInputTable WHERE commandId = %s;".format(globalDatabaseName)
            cursor.execute(sqlcmd, (commandId,))
            conn.commit()
            sys.exit()
    cursor.close()
    conn.close()
    return 1
