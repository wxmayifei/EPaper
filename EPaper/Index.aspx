<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Index.aspx.cs" Inherits="EPaper.Index" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <title></title>
    <script src="Content/jquery-3.2.1.min.js"></script>
    <link href="Content/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <script src="Content/bootstrap/js/bootstrap.min.js"></script>
</head>
<body>
    <form id="form1" runat="server">
        <div class="container">
            <div class="page-header">
                <button class="btn btn-primary" onclick="return redirectToCreate()">
                    <span class="glyphicon glyphicon-plus"></span>
                    <span>Create</span>
                </button>
                <button class="btn btn-danger" onclick="return deleteChoosed()">
                    <span class="glyphicon glyphicon-remove"></span>
                    <span>Delete</span>
                </button>
            </div>
            <div class="row">
                <div class="col-md-3">
                    <asp:Panel ID="pnThubms" runat="server" Style="overflow-y: auto">
                    </asp:Panel>
                </div>
                <div class="col-md-9">
                    <a href="javascript:void(0)" class="thumbnail">
                        <img id="imgBigThumb" src="" />
                    </a>
                </div>
            </div>
        </div>
    </form>
</body>
</html>
<script type="text/javascript">
    var currentid = 0;
    $(document).ready(function () {
        var _pnThubms = document.getElementById("pnThubms");
        _pnThubms.style.height = (document.documentElement.clientHeight - 150) + "px";
        loadDatas(_pnThubms);
    });

    function loadDatas(_pnThubms) {
        _pnThubms.innerHTML = "";
        $.ajax({
            url: "<%=this.ResolveClientUrl("~/Process.ashx") %>",
            type: "post",
            data: { m: "GetTopEPapers" },
            dataType: "json",
            success: function (result) {
                var temp;
                for (var i = 0; i < result.length; i++) {
                    var _a = document.createElement("a");
                    _a.setAttribute("href", "javascript:void(0)");
                    _a.className = "thumbnail";
                    var _img = document.createElement("img");
                    _img.setAttribute("src", baseurl + result[i].ThumbPath);
                    _a.appendChild(_img);
                    _pnThubms.appendChild(_a);
                    var size = $.parseJSON(result[i].Size);
                    _a.onclick = (function (epaperID, bigThumb, scaleX, scaleY) {
                        return function () {
                            alert(scale);
                            currentid = epaperID;
                            var _imgBigThumb = document.getElementById("imgBigThumb");
                            _imgBigThumb.setAttribute("src", baseurl + bigThumb);
                            $.ajax({
                                url: "<%=this.ResolveClientUrl("~/Process.ashx") %>",
                                type: "post",
                                data: { m: "GetEPaperDetails", id: epaperID },
                                dataType: "json",
                                success: function (result) {
                                    for (var i = 0; i < result.length; i++) {

                                    }
                                }
                            });
                        }
                    }(result[i].ID, result[i].BigThumbPath, size.x2 / size.x, size.y2 / size.y));
                    if (!temp) {
                        temp = _a;
                    }
                }
                if (temp) {
                    temp.click();
                }
                else {
                    document.getElementById("imgBigThumb").setAttribute("src", "");
                }
            }
        });
    }

    function deleteChoosed() {
        if (!currentid) {
            return false;
        }
        $.ajax({
            url: "<%=this.ResolveClientUrl("~/Process.ashx") %>",
            type: "post",
            data: { m: "DeleteEPaper", id: currentid },
            success: function () {
                loadDatas(document.getElementById("pnThubms"));
            }
        });
        return false;
    }

    function redirectToCreate() {
        window.location.href = "<%=this.ResolveClientUrl("~/Edit.aspx") %>";
        return false;
    }
</script>
