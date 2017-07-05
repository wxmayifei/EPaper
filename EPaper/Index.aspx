<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Index.aspx.cs" Inherits="EPaper.Index" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <title></title>
    <script src="Content/jquery-3.2.1.min.js"></script>
    <link href="Content/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <script src="Content/bootstrap/js/bootstrap.min.js"></script>
    <link href="Content/epaper.css" rel="stylesheet" />
</head>
<body>
    <form id="form1" runat="server">
        <div class="container">
            <div class="page-header">
                <button class="btn btn-primary" onclick="return redirectToCreate()">
                    <span class="glyphicon glyphicon-plus"></span>
                    <span>Create</span>
                </button>
                <button class="btn btn-primary" onclick="return editChoosed()">
                    <span class="glyphicon glyphicon-pencil"></span>
                    <span>Edit</span>
                </button>
                <button class="btn btn-danger" onclick="return deleteChoosed()">
                    <span class="glyphicon glyphicon-minus"></span>
                    <span>Delete</span>
                </button>
            </div>
            <div class="row">
                <div class="col-md-3">
                    <asp:Panel ID="pnThubms" runat="server" Style="overflow-y: auto">
                    </asp:Panel>
                </div>
                <div class="col-md-9">
                    <a href="javascript:void(0)" class="thumbnail" style="text-align: center">
                        <svg id="svg1" style="margin-top: 10px"></svg>
                    </a>
                </div>
            </div>
        </div>
    </form>
    <div class="modal fade bs-example-modal-lg text-center" id="imgDetail" tabindex="-1" role="dialog" aria-labelledby="myLargeModalLabel">
        <div class="modal-dialog modal-lg" style="display: inline-block; width: auto;">
            <div id="img_show" class="modal-content">
            </div>
        </div>
    </div>
</body>
</html>
<script type="text/javascript">
    var currentid = 0, ns = "http://www.w3.org/2000/svg";
    $(function () {
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
                    delete size.x1;
                    delete size.y1;
                    _a.onclick = (function (epaperID, bigThumb, size) {
                        return function () {
                            currentid = epaperID;
                            var _svg = document.getElementById("svg1");
                            _svg.style.backgroundImage = "url(" + baseurl + bigThumb + ")";
                            _svg.style.width = size.x2 + "px";
                            _svg.style.height = size.y2 + "px";
                            for (var i = 0; i < _svg.childNodes.length; i++) {
                                _svg.removeChild(_svg.childNodes[i]);
                                i--;
                            }
                            $.ajax({
                                url: "<%=this.ResolveClientUrl("~/Process.ashx") %>",
                                type: "post",
                                data: { m: "GetEPaperDetails", id: epaperID },
                                dataType: "json",
                                success: function (result) {
                                    var scaleX = size.x2 / size.x;
                                    var scaleY = size.y2 / size.y;
                                    for (var i = 0; i < result.length; i++) {
                                        var shape = $.parseJSON(result[i].Shape);
                                        switch (shape.type) {
                                            case "rect":
                                                appendRect(_svg, shape.x * scaleX, shape.y * scaleY, shape.width * scaleX, shape.height * scaleY, result[i].Path);
                                                break;
                                        }
                                    }
                                }
                            });
                        }
                    }(result[i].ID, result[i].BigThumbPath, size));
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

    function appendRect(_svg, x, y, width, height, path) {
        var _rect = document.createElementNS(ns, "rect");
        _rect.setAttributeNS(null, "x", x);
        _rect.setAttributeNS(null, "y", y);
        _rect.setAttributeNS(null, "width", width);
        _rect.setAttributeNS(null, "height", height);
        _rect.setAttributeNS(null, "class", "e_rect_display");
        _rect.onclick = function () {
            $("#imgDetail").find("#img_show").html("<img src=\"" + (baseurl + path) + "\" class=\"carousel-inner img-responsive img-rounded\" />");
            var height = $("#imgDetail").modal().height();
            //$("#imgDetail");
            var node = $("#imgDetail div.modal-dialog");
            if (node.length == 0) {
                return;
            }
            var _top = (height - node.clientHeight) * 0.4;
            if (_top < 30) {
                _top = 30;
            }
            node[0].style.marginTop = _top + "px";
        }
        _svg.appendChild(_rect);
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

    function editChoosed() {
        if (!currentid) {
            return false;
        }
        window.location.href = "<%=this.ResolveClientUrl("~/Edit.aspx") %>?id=" + currentid;
        return false;
    }

    function redirectToCreate() {
        window.location.href = "<%=this.ResolveClientUrl("~/Edit.aspx") %>";
        return false;
    }
</script>
