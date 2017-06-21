<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Edit.aspx.cs" Inherits="EPaper.Edit" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <title></title>
    <script src="Content/jquery-3.2.1.min.js"></script>
    <link href="Content/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <script src="Content/bootstrap/js/bootstrap.min.js"></script>
    <script src="Content/ajaxfileupload.js"></script>
</head>
<body>
    <form id="form1" runat="server">
        <div class="container">
            <div class="page-header">
                <button class="btn btn-info" onclick="return save()">
                    <span class="glyphicon glyphicon-floppy-disk"></span>
                    <span>Save</span>
                </button>
                <button class="btn btn-warning" onclick="return redirectToIndex()">
                    <span class="glyphicon glyphicon glyphicon-arrow-left"></span>
                    <span>Back</span>
                </button>
            </div>
            <div class="form-group">
                <label for="exampleInputEmail1">Upload EPaper</label>
                <input type="file" id="file1" name="file1" onchange="uploadEPaper()" />
                <p class="help-block">The first step is upload a EPaper</p>
            </div>
            <div class="row">
                <div class="col-md-12" style="overflow: hidden; height: 600px; background-color: #EFEFEF">
                    <svg id="svg1" style="position: absolute; left: 10px; top: 10px">
                    </svg>
                </div>
            </div>
        </div>
    </form>
</body>
</html>
<script type="text/javascript">
    function redirectToIndex() {
        window.location.href = "<%=this.ResolveClientUrl("~/Index.aspx") %>";
        return false;
    }

    function save() {
        
    }

    function uploadEPaper() {
        $.ajaxFileUpload({
            url: "<%=this.ResolveClientUrl("~/Upload.ashx") %>",
            secureuri: false,
            fileElementId: "file1",
            dataType: "json",
            success: function (data, status) {
                $("#svg1").css({ backgroundImage: "url(" + data.url + ")", width: data.width + "px", height: data.height + "px", left: "10px", top: "10px" });
            },
            error: function () {
                //alert()
            },
            complete: function () {
                var up = document.createElement("input");
                up.setAttribute("type", "file");
                var _file1 = document.getElementById("file1");
                _file1.parentNode.insertBefore(up, _file1);
                _file1.parentNode.removeChild(_file1);
                up.setAttribute("id", "file1");
                up.setAttribute("name", "file1");
                up.onchange = uploadEPaper;
            }
        });
    }

    var startX, startY, adorner;
    document.getElementById("svg1").onmousedown = function (evt) {
        if (!evt.altKey) {
            return;
        }
        startX = evt.clientX;
        startY = evt.clientY;
        adorner = this;
        this.style.cursor = "pointer";
        $(document.body).bind("mousemove", onbodymousemove);
        $("#svg1").bind("mouseup", onrelease).bind("mouseout", onrelease);
    }

    document.getElementById("svg1").onclick = function (evt) {
        if (evt.altKey) {
            return;
        }
        //todo:
    }

    var onbodymousemove = function (evt) {
        adorner.style.top = (parseInt(adorner.style.top.replace("px", "")) + evt.clientY - startY) + "px";
        startY = evt.clientY;
        adorner.style.left = (parseInt(adorner.style.left.replace("px", "")) + evt.clientX - startX) + "px";
        startX = evt.clientX;
    }

    var onrelease = function (evt) {
        $(document.body).unbind("mousemove", onbodymousemove);
        $("#svg1").unbind("mouseup", onrelease).unbind("mouseout", onrelease);
        this.style.cursor = "default";
    }

</script>

