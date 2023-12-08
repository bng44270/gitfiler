<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE html>
<html>

<head>
  <title>Contents of {{dirlist["path"]}}</title>
  <style>
    td {
      width: 20%;
      text-align: center;
    }
  </style>
  <script type="text/javascript" src="/webrequest.js"></script>
  <script type="text/javascript">
    function initializeWebFiler() {
      if (Object.keys(localStorage).indexOf('gitfiler') == -1) {
        document.getElementById('usernamepane').style.display = 'block';
        document.getElementById('filenavpane').style.display = 'none';
      }
      else {
        document.getElementById('usernamepane').style.display = 'none';
        document.getElementById('filenavpane').style.display = 'block';
      }
    };

    function doRepoOperation(op,path) {
      if (op != 'NONE') {
        if (op == 'clone') {
          var username = JSON.parse(localStorage.gitfiler)['username'];
          var sshPort = JSON.parse(localStorage.gitfiler)['sshport'];
          var hostname = location.host.replace(/:[0-9]+/,'');
    
          var testHolder = document.getElementById("clipboardtemp");
    
          var sshPort = "SSHPORT";
          var basePath = "BASEPATH";
    
          testHolder.value = "ssh://" + username + "@" + hostname + ":" + sshPort + basePath + path;
    
          testHolder.select();
          testHolder.setSelectionRange(0, 99999);
          navigator.clipboard.writeText(testHolder.value);
    
          setStatus("Copied clone link");
        }
        else if (op == 'rebuildcommit') {
          var req = new WebRequest("GET","/$/buildcommit?folder=" + path);
          req.response.then(resp => {
            var obj = JSON.parse(resp.body);
      	    
            if (obj.success) {
              setStatus("Git Hook post-commit successfully rebuilt.");
            }
            else {
              setStatus('<span style="color:#ff0000;">' + obj.msg + '</span>');
            }
          });
        }
        document.getElementById('repooperation').value = 'NONE';
      }
    }

    function createRepo() {
      var repoName = document.getElementById('newrepoentry').value;
      var gitData = JSON.parse(localStorage.gitfiler);

      var req = new WebRequest("GET","/$/newrepo?name=" + repoName);

      req.response.then(resp => {
        var obj = JSON.parse(resp.body);
	      
        if (obj.success) {
          setStatus("Repository " + repoName + " created.  Reloading in 2 seconds.");
          setTimeout(function() {
            location.reload();
          },2000);
		    }
		    else {
          setStatus('<span style="color:#ff0000;">' + obj.msg + '</span>');
		    }

		    document.getElementById('newrepoentry').value = '';
      });
    }

    function setStatus(msg) {
      document.getElementById('statusbar').innerHTML = msg;
      document.body.scrollTo(0,0);
    }

    function saveUsername() {
      var username = document.getElementById('usernameentry').value;

      localStorage.gitfiler = '{"username":"' + username + '"}';

      document.getElementById('usernamepane').style.display = 'none';
      document.getElementById('filenavpane').style.display = 'block';
    }

    function cancelEditUsername() {
      document.getElementById('usernamepane').style.display = 'none';
      document.getElementById('filenavpane').style.display = 'block';
    }

    function editUsername() {
      if (Object.keys(localStorage).indexOf('gitfiler') > -1) {
        var username = JSON.parse(localStorage.gitfiler)['username'];

        if (username.length > 0) {
          document.getElementById('usernamepane').style.display = 'block';
          document.getElementById('filenavpane').style.display = 'none';

          document.getElementById('usernameentry').value = username;
        }
        else {
          alert("Please specify username and email");
        }        
      }
    }
  </script>
</head>

<body onload="initializeWebFiler();">
  <div id="usernamepane">
    <label class="inputlabel" for="usernameentry">Username</label><input class="inputfield" type="text" id="usernameentry" /><br/>
    <button class="actionbtn" onclick="saveUsername();">Save</button><button class="actionbtn" onclick="cancelEditUsername();">Cancel</button>
  </div>
  <div id="filenavpane">
    <button class="actionbtn" onclick="editUsername();" style="margin-right:50px;">Edit Configuration</button>
    {% if dirlist["isroot"] %}<button class="actionbtn" id="loadparent" onclick="location.href='{{dirlist["path"]}}..';" style="margin-right:50px;">Parent Directory</button>{% endif %}
    <label class="inputlabel" for="newrepoentry">New Repository</label><input type="text" class="inputfield" id="newrepoentry" /><button onclick="createRepo();" style="margin-right:50px;">Create</button>
    <span id="statusbar"></span><br/>

    <h2>Contents of {{dirlist["path"]}}</h2>
    
    <table style="border-width:0px;">
      <tr>
        <th>Type</th>
        <th>File Name</th>
        <th>Size</th>
        <th>Modified</th>
      </tr>
      {% for thisfile in dirlist["files"] %}
      <tr>
        <td><span class="tabletext">[{{thisfile["type"]}}]</span></td>
        <td><a class="tabletext" href="{{thisfile["path"]}}" style="margin-right:10px;">{{thisfile["shortname"]}}</a>{% if thisfile["isrepo"] %}<select id="repooperation" onchange="doRepoOperation(this.value,'{{thisfile["path"]}}');"><option value="NONE">--Select Operation</option><option value="clone">Copy Clone Link</option><option value="rebuildcommit">Rebuild Commit Hook</option></select>{% endif %}</td>
        <td><span class="tabletext">{{thisfile["size"]}} bytes</span></td>
        <td><span class="tabletext">{{thisfile["modify"]}}</span></td>
      </tr>
      {% endfor %}
    </table><br/>
  </div>
  <input type="text" style="display:none;" id="clipboardtemp" />
  <br /><span style="font-style:italic;">Powered by gitfiler</span><br />
</body>

</html>