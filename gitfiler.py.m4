from flask import Flask, render_template, send_file, request, make_response
import os
import re
import time
import sys

webroot = "LOCALPATH"

webassets = os.listdir('assets')

app = Flask(__name__)

@app.route("/", defaults ={'path':''}, methods=["GET"])
@app.route("/<path:path>", methods=["GET"])
def GetLogs(path):
  if path in webassets:
    return send_file("assets/" + path)
  elif re.match(r'^newrepo',path):
    reponame = request.args.get('name')

    repopath = webroot + '/' + reponame + ".git"

    cmd_ar = []
    cmd_ar.append("mkdir " + repopath)
    cmd_ar.append("git init --bare " + repopath)
    cmd_ar.append("git config --global init.defaultBranch master " + repopath)

    failmsg = ''

    for thiscmd in cmd_ar:
      try:
        os.system(thiscmd)
      except:
        print("ERROR:  " + thiscmd)
        failmsg = "Failed command:  " + thiscmd
        break
    
    resp = "{\"success\":true}" if len(failmsg) == 0 else "{\"success\":false,\"msg\":\"" + failmsg + "\"}"
    
    return make_response(resp,200)
  else:
    thispath = webroot + "/" + path

    if os.path.isfile(thispath):
      fileinfo = {}
      fileinfo["shortname"] = re.sub(webroot,"",thispath)

      with open(thispath,"r") as f:
        filecontent = f.readlines()
      
      fileinfo["content"] = "\n".join(filecontent)

      return render_template('filedisplay.html',fileinfo = fileinfo)
    else:
      isrepo = False
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
            isrepo = True
        else:
          ftype="X"
        
        if len(path) == 0:
          linkpath = re.sub("\/\/","/",path + "/" + shortfile)
        else:
          linkpath = re.sub("\/\/","/","/" + path + "/" + shortfile)

        dirlist["files"].append({"shortname":shortfile,"path":linkpath,"type":ftype,"modify":time.ctime(os.path.getmtime(thispath + "/" + thisfile)),"size":os.path.getsize(thispath + "/" + thisfile),"isrepo":isrepo})
      
      return render_template('filelist.html', dirlist = dirlist)
  
app.run("0.0.0.0",WEBPORT)
