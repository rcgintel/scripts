import sqlite3
import subprocess
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart


def createDatabase(fileName):
    conn = sqlite3.connect(fileName)
    cursor = conn.cursor()
    print("creating the database")
    create_table_sql = """
    CREATE TABLE IF NOT EXISTS ECOTracker (
        id INTEGER PRIMARY KEY,
        blockName TEXT NOT NULL,
        ecoFileName TEXT NOT NULL,
        team TEXT NOT NULL,
        validTime INTEGER DEFAULT 3,
        inputData TEXT,
        status TEXT DEFAULT 'pending',
        runTime INTEGER,
        submitTime TEXT,
        runArea TEXT,
        hash TEXT,
        ecoOwner TEXT
    );
    """

    cursor.execute(create_table_sql)
    create_table_sql = """
    CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY,
        userName TEXT NOT NULL,
        userStatus TEXT NOT NULL,
        userAccess TEXT NOT NULL,
        userTeam TEXT NOT NULL,
        userLead TEXT NOT NULL,
        blockOwned TEXT
    );
    """

    cursor.execute(create_table_sql)

    conn.commit()
    conn.close()
    return 1



def removeTable(databaseLocation,tableName):
    conn = sqlite3.connect(databaseLocation)
    cursor = conn.cursor()
    print("deleating table "+tableName)
    sqlCmd = "delete from "+tableName
    cursor.execute(sqlCmd)
    conn.commit()
    conn.close()
    return 1

def getDataFromTable(databaseLocation,tableName,data,condition):
    conn = sqlite3.connect(databaseLocation)
    cursor = conn.cursor()
    sqlCmd = "select "+str(data)+" from "+str(tableName)+" where "+str(condition)+";"
    cursor.execute(sqlCmd)
    fetchedData = cursor.fetchall()
    cleanData = ""
    for formatData in fetchedData:
        cleanData = formatData[0]
    conn.close()
    return cleanData

def getMultiDataFromTable(databaseLocation,tableName,data):
    conn = sqlite3.connect(databaseLocation)
    cursor = conn.cursor()
    #import code
    #code.interact(local=locals())
    sqlCmd = "select "+str(data)+" from "+str(tableName)+" ORDER BY blockName;"
    cursor.execute(sqlCmd)
    fetchedData = cursor.fetchall()
    conn.close()
    return fetchedData

def setupUserTable(databaseLocation,tableName,data):
    conn = sqlite3.connect(databaseLocation)
    cursor = conn.cursor()
    print("inserting data ot database")
    sqlTemplate = "INSERT INTO "+tableName+" (userName,userStatus,userAccess,userTeam,userLead) values (?,?,?,?,?);"
    cursor.execute(sqlTemplate,data)
    conn.commit()
    conn.close()
    return 1



def insertEcoData(databaseLocation,tableName,data):
    conn = sqlite3.connect(databaseLocation)
    cursor = conn.cursor()
    print("inserting data ot database")
    sqlTemplate = "INSERT INTO "+tableName+" (blockName,ecoFileName,team,validTime,inputData,submitTime,hash,ecoOwner) values (?,?,?,?,?,?,?,?);"
    cursor.execute(sqlTemplate,data)
    conn.commit()
    conn.close()
    return 1




def getFileHash(filename, hash_command='md5sum'):
    try:
        # Run the hash command in the terminal
        result = subprocess.run([hash_command, filename], stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True, check=True)
        # The hash value is the first part of the output before any spaces
        hash_value = result.stdout.split()[0]
        return hash_value
    except subprocess.CalledProcessError as e:
        print(f"An error occurred while calculating the hash: {e}")
        return None


def send_mail(subject, recipients, body_file_path, attachments=None):
    command = ['mailx']
    # Add subject
    command += ['-s', subject]
    # Add recipients
    for recipient in recipients:
        command.append(recipient)
    # Add attachments if provided
    if attachments:
        for attachment in attachments:
            command += ['-a', attachment]
    # Open the body file for reading
    with open(body_file_path, 'r') as body_file:
        # Open a subprocess to send the mail, with stdin connected to the body file
        process = subprocess.Popen(command, stdin=body_file)
        process.communicate()



