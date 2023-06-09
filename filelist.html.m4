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

      if (location.pathname == '/') {
        document.getElementById('loadparent').style.display = 'none';
      }
    };

    function copyCloneLink(alink,path) {
      var username = JSON.parse(localStorage.gitfiler)['username'];
      var hostname = location.host;

      var testHolder = document.getElementById("clipboardtemp");

      testHolder.value = username + "@" + hostname + ":BASEPATH" + path;

      testHolder.select();
      testHolder.setSelectionRange(0, 99999);
      navigator.clipboard.writeText(testHolder.value);

      alink.innerHTML = alink.innerHTML.replace(/Copy/,'Copied');
      
      setTimeout(function() {
        alink.innerHTML = alink.innerHTML.replace(/Copied/,'Copy');
      },5000);
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
      document.getElementById('usernamepane').style.display = 'block';
      document.getElementById('filenavpane').style.display = 'none';

      if (Object.keys(localStorage).indexOf('gitfiler') > -1) {
        var username = JSON.parse(localStorage.gitfiler)['username'];

        document.getElementById('usernameentry').value = username;
      }
    }
  </script>
</head>

<body onload="initializeWebFiler();">
  <div id="usernamepane">
    <label for="usernameentry">Username</label><input type="text" id="usernameentry" /><br/>
    <button onclick="saveUsername();">Save</button><button onclick="cancelEditUsername();">Cancel</button>
  </div>
  <div id="filenavpane">
    <button onclick="editUsername();">Edit Username</button><br/>
    <h2>Contents of {{dirlist["path"]}}</h2>
    <a id="loadparent" href="{{dirlist["path"]}}..">Parent Directory</a><br /><br />
    <table style="border-width:0px;">
      <tr>
        <th>Type</th>
        <th>File Name</th>
        <th>Size</th>
        <th>Modified</th>
        <th>Action</th>
      </tr>
      {% for thisfile in dirlist["files"] %}
      <tr>
        <td>[{{thisfile["type"]}}]</td>
        <td><a href="{{thisfile["path"]}}">{{thisfile["shortname"]}}</a></td>
        <td>{{thisfile["size"]}} bytes</td>
        <td>{{thisfile["modify"]}}</td>
        <td>{% if thisfile["type"].endswith("+R") %}<a href="#" onclick="copyCloneLink(this,'{{thisfile["path"]}}');">Copy Clone Link</a>{% endif %}</td>
      </tr>
      {% endfor %}
    </table>
    <input type="text" style="display:none;" id="clipboardtemp" />
  </div>
  <br /><span style="font-style:italic;">Powered by gitfiler</span><br />
</body>

</html>
