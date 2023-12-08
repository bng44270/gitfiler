from flask import Flask, render_template, send_file, request, make_response
import os
import re
import time
import sys
import git

touch_file = lambda f : open(f,"w").close()

ssh_port = "SSHPORT"

webroot = "LOCALPATH"

webassets = os.listdir('assets')

app = Flask(__name__)

def gitstash(repo_folder):
  repo = git.Repo(repo_folder)

  if len(repo.index.diff("HEAD")) > 0:
    repo.git.stash()

def buildcommithook(repo_folder):
  postcommitfile = open(f"{repo_folder}/.git/hooks/post-commit","w")
        
  postcommitlines = []
  postcommitlines.append("#!/bin/bash")
  postcommitlines.append("")
  postcommitlines.append(f"chgrp -R git-users {repo_folder}")
  postcommitlines.append(f"chown -R root {repo_folder}")
  postcommitlines.append(f"chmod -R 770 {repo_folder}")
  postcommitlines.append("")
  postcommitfile.write("\n".join(postcommitlines))
  
  os.chmod(f"{repo_folder}/.git/hooks/post-commit",0o755)

@app.route("/", defaults ={'path':''}, methods=["GET"])
@app.route("/<path:path>", methods=["GET"])
def GetLogs(path):
  if path in webassets:
    return send_file("assets/" + path)
  elif re.match(r'^\$\/buildcommit',path):
    try:
      repofolder = request.args.get('folder')

      repopath = webroot + repofolder

      buildcommithook(repopath)

      return "{\"success\":true}"
    except Exception as e:
      return "{\"success\":false,\"msg\":\"" + str(e).replace('\n','  ') + "\"}"
  elif re.match(r'^\$\/newrepo',path):
    reponame = request.args.get('name')

    repopath = webroot + '/' + reponame + ".git"
    
    failmsg = ""

    try:
      if os.path.exists(repopath) or reponame == "$":
        raise Exception("Invalid repository name (" + reponame + ")")
      else:
        os.mkdir(repopath)
        git.Repo.init(repopath)
        
        repo = git.Repo(repopath)
        
        repo.config_writer().set_value("core","bare","true").release()

        buildcommithook(repopath)

        touch_file(repopath + "/README")

        repo.index.add("README")
        repo.index.commit("Initial Commit")
        
        repo.config_writer().remove_option("core","bare")

        return "{\"success\":true}"
    except Exception as e:
      return "{\"success\":false,\"msg\":\"" + str(e).replace('\n','  ') + "\"}"
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
      isrepo = None
      dirlist = {}
      dirlist["path"] = re.sub("\/\/","/","/" + path + "/")
      dirlist["isroot"] = thispath != (webroot + "/")
      dirlist["isrepo"] = os.path.exists(thispath + "/.git")
      dirlist["files"] = []

      if dirlist["isrepo"]:
        gitstash(thispath)
      
      print("INFO:  " + thispath)
      
      dirlisting = os.listdir(thispath)
      dirlisting.sort()
      
      for thisfile in dirlisting:
        isrepo = False
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
  
app.run("0.0.0.0",WEBPORT,ssl_context=("CERTFILE","KEYFILE"))
