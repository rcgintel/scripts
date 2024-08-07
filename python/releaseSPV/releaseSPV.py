import UsrIntel.R1

import tkinter as tk
import sqlite3 as sdb

root=tk.Tk()
    
# setting the windows size
root.geometry("600x400")
name_var=tk.StringVar()
passw_var=tk.StringVar()
databaseLoc = "/nfs/site/disks/elg_x2_a0_msnodecom_pv_01/rcg/spvRuns/PEOInputs/runLocationDb.db"

def submit(): 
    name=name_var.get()
    location=passw_var.get()
     
    print("The name is : " + value_inside.get())
    print("The location is : " + location)
    print("submitted this data in the next run if this data is available will pick it else old data will be picked")
    

def check():
    name=name_var.get()
    password=passw_var.get()
    print("The data entered for the block : " + value_inside.get())
    con = sdb.connect(databaseLoc)
    cursorObj = con.cursor()
    #cursorObj.execute('UPDATE employees SET name = "Rogers" where id = 2')
    #con.commit()
    print('SELECT * FROM inputs WHERE name like \"%'+value_inside.get()+'%\"')
    cursorObj.execute('SELECT * FROM inputs WHERE name like \"%'+value_inside.get()+'%\"')
    rows = cursorObj.fetchall()
    for row in rows:
        print(row)


     
     

name_label = tk.Label(root, text = 'Blockname', font=('calibre',10, 'bold'))


options_list = ["gtmsnodecompar1", "gtmsnodecompar2", "gtmsnodecompar3", "gtmsnodecompar4","gtmssqidi0","gtmssqidi1","gtmssqidi2","gtmssqidi3"]
value_inside = tk.StringVar(root)
value_inside.set("Select an Option")
question_menu = tk.OptionMenu(root, value_inside, *options_list)
  
# creating a label for password
passw_label = tk.Label(root, text = 'Runlocation', font = ('calibre',20,'bold'))
  
# creating a entry for password
passw_entry=tk.Entry(root, textvariable = passw_var, font = ('calibre',20,'normal'))
  
# creating a button using the widget
# Button that will call the submit function
sub_btn=tk.Button(root,text = 'Submit', command = submit)
chk_btn=tk.Button(root,text = 'Check', command = check)
  
# placing the label and entry in
# the required position using grid
# method
name_label.grid(row=0,column=0)
passw_label.grid(row=1,column=0)
passw_entry.grid(row=1,column=1)
sub_btn.grid(row=2,column=1)
chk_btn.grid(row=2,column=0)
question_menu.grid(row=0,column=1)
# performing an infinite loop
# for the window to display
root.mainloop()