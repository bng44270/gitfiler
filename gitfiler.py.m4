from flask import Flask, render_template, send_file, request
import os
import re
import time
import sys

webroot = "LOCALPATH"

app = Flask(__name__)

@app.route("/", defaults ={'path':''}, methods=["GET"])
@app.route("/<path:path>", methods=["GET"])
def GetLogs(path):
  thispath = webroot + "/" + path

  if os.path.isfile(thispath):
    fileinfo = {}
    fileinfo["shortname"] = re.sub(webroot,"",thispath)

    with open(thispath,"r") as f:
      filecontent = f.readlines()
    
    fileinfo["content"] = "\n".join(filecontent)

    return render_template('filedisplay.html',fileinfo = fileinfo)
  else:
    dirlist = {}
    dirlist["path"] = re.sub("\/\/","/","/" + path + "/")
    dirlist["files"] = []
    for thisfile in os.listdir(thispath):
      shortfile = re.sub(webroot,"",thisfile)
      if os.path.isfile(thispath + "/" + thisfile):
        ftype="F"
      elif os.path.isdir(thispath + "/" + thisfile):
        ftype="D"
        if os.path.exists(thispath + "/" + thisfile + "/.git"):
          ftype += "+R"
      else:
        ftype="X"
      
      if len(path) == 0:
        linkpath = re.sub("\/\/","/",path + "/" + shortfile)
      else:
        linkpath = re.sub("\/\/","/","/" + path + "/" + shortfile)

      dirlist["files"].append({"shortname":shortfile,"path":linkpath,"type":ftype,"modify":time.ctime(os.path.getmtime(thispath + "/" + thisfile)),"size":os.path.getsize(thispath + "/" + thisfile)})
    
    return render_template('filelist.html', dirlist = dirlist)
  
app.run("0.0.0.0",WEBPORT)
