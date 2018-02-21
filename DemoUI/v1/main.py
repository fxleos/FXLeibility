from PyQt5 import uic, QtWidgets
from PyQt5.QtCore import Qt
from PyQt5.QtGui import QColor

import subprocess
import webbrowser
from collections import defaultdict



import sys
import glob
import os
if os.name=="nt":
    slash = "\\"
else:
    slash = slash

# Load UI file
form_class = uic.loadUiType("mainWindow.ui")[0]
form_class_edit = uic.loadUiType("editDialog.ui")[0]

class MyWindowClass(QtWidgets.QMainWindow, form_class):
    def __init__(self, parent=None):
        QtWidgets.QMainWindow.__init__(self, parent)
        self.setupUi(self)
        self.update_filelist()
    
    def update_filelist(self):
        self.files = glob.glob("./data/*/*.txt")
        files = ["Please choose a file.."] + [x.split(slash)[-2] for x in self.files]
        self.comboBox_case.clear()
        self.comboBox_case.addItems(files)

    def caseChanged(self):
        if self.comboBox_case.currentIndex()<=0:
            return
        print(self.comboBox_case.currentIndex())
        print(self.files[self.comboBox_case.currentIndex()-1])
        with open(self.files[self.comboBox_case.currentIndex()-1], "r") as f:
            lines = f.readlines()
        file_parsed = self.parser(lines)
        self.label_Status.setText(file_parsed["#status"])
        self.textEdit_des.setPlainText(file_parsed["#des"])
        self.selected_file = self.files[self.comboBox_case.currentIndex()-1]
        self.selected_dir = self.selected_file[:-len(self.selected_file.split(slash)[-1])]
        
            

    def parser(self, lines):
        result = dict()
        idx = "null"
        for line in lines:
            if "#" in line:
                idx = line.split(":")[0]
                line = line[len(idx)+1:]
                result[idx] = line
            else:
                result[idx] += line
        return result

    def create(self):    
        editWindow = EditDialog(None, mode="create")
        editWindow.exec_()
    
    def edit(self):        
        with open(self.files[self.comboBox_case.currentIndex()-1], "r") as f:
            lines = f.readlines()
        file_parsed = self.parser(lines)
        editWindow = EditDialog(None, file_addr=self.files[self.comboBox_case.currentIndex()-1], mode="edit", info=file_parsed)
        editWindow.exec_()

    def result(self):
        path = os.path.abspath(self.selected_dir)
        webbrowser.open(path, new=2)


class EditDialog(QtWidgets.QDialog, form_class_edit):
    def __init__(self, parent=None, file_addr="", mode="create", info=defaultdict(str)):
        super(EditDialog, self).__init__(parent)
        self.setupUi(self)
        self.info = info
        if mode=="edit":
            self.read()
        self.mode = mode
        self.addr =file_addr
    
    def read(self):
        geo_map={"PJM":0, "Germany":1, "Australia-NSW":2}
        tech_map={"ESS":0, "EV2G":1}
        self.lineEdit_name.setText(self.info["#name"])
        self.textEdit_des.setPlainText(self.info["#des"])
        self.checkBox_daem.setChecked(bool(int(self.info["#arbitrage.day-ahead-energy-market"])))
        self.doubleSpinBox_e2p.setValue(float(self.info["#energy-to-power-ratior"]))
        self.comboBox_geography.setCurrentIndex(geo_map[self.info["#geo"].strip()])
        self.comboBox_tech.setCurrentIndex(tech_map[self.info["#typeoftech"].strip()])
        # For each additional widget, add a line here to read data from file to UI.
        

    def refresh(self):
        # Load data from UI to self.info before saving
        self.info["#name"] = self.lineEdit_name.text()
        # str(int(self.ssxxx.isChecked()))

    def inverse_parser(self):
        text = ""
        for key in self.info.keys():
            text += key + ":" +self.info[key]
            text += "\n"
        return text

    def save(self):
        self.refresh()
        if self.mode=="edit":
            with open(self.addr, "w") as f:
                f.write(self.inverse_parser())
        elif self.mode=="create":
            try:
                os.mkdir("./data/"+str(self.info["#name"]))
            except ValueError:
                pass
            file_loc = "./data/"+str(self.info['#name'])+slash+str(self.info['#name'])+".txt"
            print(file_loc)
            with open(file_loc, "w") as f:
                f.write(self.inverse_parser())

    def cancel(self):
         self.close()
                
    

if __name__ == "__main__":
    app = QtWidgets.QApplication(sys.argv)
    myWindow = MyWindowClass(None)
    myWindow.show()
    sys.exit(app.exec_())
