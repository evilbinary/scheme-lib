import os  
from os.path import join, getsize  
import pickle  
import subprocess  
import time

file_info = None  
  
def compile_source():  
    for root, dirs, files in os.walk('.'):  
        for f in files:  
            if f in ['sync.py','dump.pkl']:  
                continue  
            if not f.endswith('.py'):  
                continue  
            p = join(root,f)  
            size = os.path.getsize(p)  
            fstat = os.stat(p)  
            info = (size,fstat.st_mtime)  
            if p in file_info and  info == file_info[p]:  
                if os.path.exists(p.replace('.py','.pyo')):  
                    continue  
            print 'compile ',p  
            print subprocess.check_output('python -OO -m py_compile '+p)  
  
def sync_source():  
    for root, dirs, files in os.walk('.'):  
        for f in files:  
            if f in ['sync.py','sync.pyo','dump.pkl']:  
                continue  
#            if f.endswith('.py'):  
#                continue  
            p = join(root,f)  
            size = os.path.getsize(p)  
            fstat = os.stat(p)  
            info = (size,fstat.st_mtime)  
            if p in file_info and  info == file_info[p]:  
                    continue  
            file_info[p] = info  
            #root_dir = '/data/local/tmp/chez/'  
            root_dir = '/sdcard/org.evilbinary.chez/lib/'  
            #root_dir = '/storage/emulated/legacy/org.evilbinary.chez/lib/gui/'  
            cmd = ['adb','push',p,join(root_dir,p[2:].replace('\\','/'))]  
            print ' '.join(cmd)  
            print subprocess.check_output(cmd)  
      
    with open('dump.pkl','wb') as f:  
        pickle.dump(file_info,f)  
  
if __name__ == '__main__':  
    try:  
        with open('dump.pkl','rb') as f:  
            file_info = pickle.load(f)  
    except Exception,e:  
        print e  
        file_info = {}  
    while True:
        sync_source()  
        time.sleep(1)
