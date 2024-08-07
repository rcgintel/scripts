import tkinter as tk
import sqlite3

root=tk.Tk()

# setting the windows size
root.geometry("800x500")

# declaring string variable
# for storing strings

blockNameVar=tk.StringVar()

runLocationVar=tk.StringVar()


# defining a function that will
# get the name and password and
# print them on the screen
def submit():
 
    blockName=blockNameVar.get()
    runLocation=runLocationVar.get()
    print("The name is : " + blockName)
    print("The runLocation is : " + runLocation)

    con = sqlite3.connect('/nfs/site/disks/elg_x2_a0_msnodecom_pv_01/rcg/spvRuns/inputs/myInputs.sdb')
    cursorObj = con.cursor()
    cursorObj.execute("CREATE TABLE if not exists spvDataInput(id integer PRIMARY KEY, blockName text, blockLocation text)")
    entities = (blockName, runLocation)
    cursorObj.execute('INSERT INTO spvDataInput(blockName, blockLocation) VALUES(?, ?)', entities)  
    #sqlCmd = "insert into spvDataInput (blockName, blockLocation) values ("+blockName+","+runLocation+")"
    #cursorObj.execute(sqlCmd)

    con.commit()
    cursorObj.close()


    blockNameVar.set("")
    runLocationVar.set("")


# creating a label for
# name using widget Label
blockName_label = tk.Label(root, text = 'blockName', font=('arial',15, 'normal'))

# creating a entry for input
# name using widget Entry
blockName_entry = tk.Entry(root,textvariable = blockNameVar, font=('arial',15, 'normal'))

# creating a label for password
runLocation_label = tk.Label(root, text = 'runLocation', font = ('arial',15, 'normal'))

# creating a entry for password
runLocation_entry=tk.Entry(root, textvariable = runLocationVar, font = ('arial',15, 'normal'))

# creating a button using the widget
# Button that will call the submit function
sub_btn=tk.Button(root,text = 'Submit', command = submit)

# placing the label and entry in
# the required position using grid
# method
blockName_label.grid(row=0,column=0)
blockName_entry.grid(row=0,column=1)
runLocation_label.grid(row=1,column=0)
runLocation_entry.grid(row=1,column=1)
sub_btn.grid(row=2,column=1)

# performing an infinite loop
# for the window to display
root.mainloop()
