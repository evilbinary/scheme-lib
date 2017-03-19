#-*- coding: UTF-8 -*-
import os
import re
types={
        "float":"float",
        "int":"int",
        "void":"void",
        "NVGcontext*":"void*",
        "NVGcolor*":"void*",
        "NVGcolor":"NVGcolor",
        "const char*":"string",
        "int*":"void*",
        "NVGpaint":"NVGpaint",
        "NVGpaint*":"void*",
        "":"",
        "unsigned char":"int",
        "float*":"void*",
        "const float*":"void*",
        "unsigned char*":"void*",
        "const unsigned char*":"void*",
        "NVGglyphPosition*":"void*",
        "NVGtextRow*","void*",
    
        }
keepWord='(HSLA|RGBA|RGB|[A-Z])'
def getType(type):
    t=types.get(type)
    if t:
        return t
    return ''

func=[]
f = open("h.txt", "r")
for line in f:

    if line.strip().lstrip()[0:2]=="//":
        print ';;',line.strip().lstrip()[3:]
        pass;
    elif line.strip().lstrip() !="" :
        print ';;',line.replace('\n','') 
        l= re.split('[()]',line)
        l2=re.split("\\s+",l[0]) 
        l3=re.split(',',l[1])
        args=[]
        for arg in l3:
            argType=arg[:arg.rfind(' ')].strip(' ')
            args.append(getType(argType))            
        ret=getType(l2[0])
        name=''
        oldName=l2[1]
        n=re.split(keepWord,l2[1])
        for nn in n:
            if nn.isupper():
                name+='-'+nn.lower()
            else:
                name+=nn
        func.append(name) 
        define='(def-function %s \n  \
               "%s" (%s) %s)\n'%(name,oldName," ".join(args) ,ret)
        print define
        #func.append([ret,name])
    pass    # do something here
f.close()

print "\n".join(func)
