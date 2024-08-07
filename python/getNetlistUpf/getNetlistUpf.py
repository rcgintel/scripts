
import UsrIntel.R1
import os
import sys
from tkinter import *
def clicked():
    project = lbl3.cget("text")
    print("copied netlist and upf to VCLP run location to project", project)
    if project == "MTL128B0":
        userInput = "/nfs/site/disks/mtl_128_b0_intg_mw_01/rcg/sam_creation/inputs/userInput/"
        print("copy the netlist data ",txt.get())
        print("copy the upf data ",txt2.get())
        netlist = txt.get()
        upf = txt2.get()

    elif project == "LNLA0":
        userInput = "/nfs/site/disks/lnl_m128_a0_intg_mw_01/rcg/inputs/userInputs/"
        print("copy the netlist data ",txt.get())
        print("copy the upf data ",txt2.get())
        netlist = txt.get()
        upf = txt2.get()
    else:
        print("select the project from the drop down menu")
        root.destroy()
        sys.exit(1)

    if "spyglass_splitbus.pg.vg" in netlist:
        print("netlist is correct")
    else:
        print("netlist is incorrect")
        
    cmd = "cp -rf "+netlist+" "+userInput
    os.system(cmd)
    cmd = "cp -rf "+upf+" "+userInput
    os.system(cmd)
    cmd = "chmod 777 "+userInput+"/*"
    os.system(cmd)
    root.destroy()

def changename(index):
    name = mbtn.menu.entrycget(index, "label")
    print(name)
    selectedText.set(name)
    lbl3.config(text = name)
    #mbtn.grid(row=1, column=1)


root = Tk()
root.title("Get Netlist and UPF")
root.geometry('350x200')

#project['values'] = (' MTL128B0', ' LNLA0')

selectedText=StringVar()
selectedText.set("Select Race")

mbtn = Menubutton(root, text="selectProject", relief=RAISED)
mbtn.grid(column = 0, row=0)
mbtn.menu = Menu(mbtn, tearoff = 0)
mbtn["menu"] = mbtn.menu

MTL128B0 = IntVar()
LNLA0 = IntVar()

mbtn.menu.add_checkbutton(label="MTL128B0", variable=MTL128B0, command=lambda: changename(0))
mbtn.menu.add_checkbutton(label="LNLA0", variable=LNLA0, command=lambda: changename(1))

lbl3 = Label(root, text = " select Project ")
lbl3.grid(column = 1, row =0)

lbl = Label(root, text = "Netlist")
lbl.grid(column =0, row =1)
txt = Entry(root, width=50)
txt.grid(column =1, row =1)

lbl2 = Label(root, text = "UPF")
lbl2.grid(column=0, row=2)
txt2 = Entry(root, width=50)
txt2.grid(column=1, row=2)
btn = Button(root, text = "Submit" , fg = "black", command=clicked)
btn.grid(column=0, row=3)
root.mainloop()
