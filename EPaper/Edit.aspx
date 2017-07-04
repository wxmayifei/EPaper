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
    <link href="Content/epaper.css" rel="stylesheet" />
    <script src="Content/json2.js"></script>
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
                    <svg id="svg1" style="position: absolute; left: 10px; top: 10px"></svg>
                </div>
            </div>
        </div>
    </form>
    <div class="modal fade" id="searchModal" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-body">
                    <div id='modal_message' style="text-align: center">
                        <h2>Processing</h2>
                    </div>
                    <div class="progress progress-striped active">
                        <div class="progress-bar progress-bar-success" role="progressbar" aria-valuenow="60"
                            aria-valuemin="0" aria-valuemax="100" style="width: 100%;">
                        </div>
                    </div>
                </div>
            </div>
            <!-- /.modal-content -->
        </div>
        <!-- /.modal -->
    </div>
</body>
</html>
<script type="text/javascript">
    function redirectToIndex() {
        window.location.href = "<%=this.ResolveClientUrl("~/Index.aspx") %>";
        return false;
    }

    function save() {
        var _svg = document.getElementById("svg1");
        var shapes = [];
        for (var i = 0; i < _svg.childNodes.length; i++) {
            if (!_svg.childNodes[i].tagName || _svg.childNodes[i].getAttributeNS(null, "resizer")) {
                continue;
            }
            var shape = {
                type: _svg.childNodes[i].tagName,
            };
            switch (shape.type) {
                case "rect":
                    shape.x = _svg.childNodes[i].x.baseVal.value;
                    shape.y = _svg.childNodes[i].y.baseVal.value;
                    shape.height = _svg.childNodes[i].height.baseVal.value;
                    shape.width = _svg.childNodes[i].width.baseVal.value;
                    break;
            }
            shapes.push(shape);
        }
        $("#searchModal").modal("show");
        $.ajax({
            url: "<%=this.ResolveClientUrl("~/Process.ashx")%>",
            type: "POST",
            data: { m: "SaveEPaper", image: imageUrl, shapes: JSON.stringify(shapes) },
            success: function () {
                $("#searchModal").modal("hide");
                redirectToIndex();
            }
        });
        return false;
    }

    function uploadEPaper() {
        $.ajaxFileUpload({
            url: "<%=this.ResolveClientUrl("~/Upload.ashx") %>",
            secureuri: false,
            fileElementId: "file1",
            dataType: "json",
            success: function (data, status) {
                imageUrl = data.url;
                $("#svg1").css({ backgroundImage: "url(" + data.url + ")", width: data.width + "px", height: data.height + "px", left: "10px", top: "10px" });
                if (!document.getElementById("rect_left_top")) {
                    createResizer("rect_left_top");
                    createResizer("rect_right_bottom");
                    createResizer("rect_top");
                    createResizer("rect_bottom");
                    createResizer("rect_right_top");
                    createResizer("rect_left_bottom");
                    createResizer("rect_right");
                    createResizer("rect_left");
                }
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

    function createResizer(id) {
        var rect = document.createElementNS(ns, "rect");
        rect.setAttributeNS(null, "id", id);
        rect.setAttributeNS(null, "class", "e_rect_resizer");
        rect.style.display = "none";
        rect.setAttributeNS(null, "resizer", "1");
        switch (id) {
            case "rect_left_top":
            case "rect_right_bottom":
                rect.style.cursor = "nw-resize";
                break;
            case "rect_top":
            case "rect_bottom":
                rect.style.cursor = "s-resize";
                break;
            case "rect_right_top":
            case "rect_left_bottom":
                rect.style.cursor = "ne-resize";
                break;
            case "rect_right":
            case "rect_left":
                rect.style.cursor = "w-resize";
                break;
        }
        document.getElementById("svg1").appendChild(rect);
        $(rect).bind("mousedown", onresizermousedown);
    }

    var startX, startY, adorner, choosed, isReleased, isMouseDown, imageUrl;
    document.getElementById("svg1").onmousedown = function (evt) {
        isReleased = false;
        $(document.body).bind("mouseup", onsvgmouseup);
        document.onselectstart = function () { return false; };
        startX = evt.clientX;
        startY = evt.clientY;
        window.onsvgmousedowntimeout = setTimeout(function () {
            if (window.onsvgmousedowntimeout) {
                delete window.onsvgmousedowntimeout;
            }
            if (isReleased) {
                document.onselectstart = null;
                return;
            }
            isMouseDown = true;
            if (evt.altKey) {
                adorner = evt.target;
                evt.target.style.cursor = "pointer";
                $(document.body).bind("mousemove", onbodymousemove);
                $("#svg1").bind("mouseup", onrelease).bind("mouseout", onrelease);
            }
            else {
                if (!document.getElementById("rect_left_top")) {
                    return;
                }
                adorner = { element: this };
                $("#svg1").bind("mousemove", onsvgmousemove).bind("mouseup", onsvgrelease);
                //.bind("mouseout", onsvgrelease)
            }
        }, 120);
        evt.stopPropagation();
    }

    var onsvgmouseup = function () {
        if (window.onsvgmousedowntimeout) {
            clearTimeout(window.onsvgmousedowntimeout);
            delete window.onsvgmousedowntimeout;
        }
        isReleased = true;
        $(document.body).unbind("mouseup", onsvgmouseup);
    }

    document.getElementById("svg1").onclick = function () {
        if (!choosed || isMouseDown) {
            isMouseDown = false;
            return;
        }
        choosed = null;
        hideResizer();
    }

    var onbodymousemove = function (evt) {
        adorner.style.top = (parseInt(adorner.style.top.replace("px", "")) + evt.clientY - startY) + "px";
        startY = evt.clientY;
        adorner.style.left = (parseInt(adorner.style.left.replace("px", "")) + evt.clientX - startX) + "px";
        startX = evt.clientX;
    }

    var onrelease = function (evt) {
        adorner = null;
        $(document.body).unbind("mousemove", onbodymousemove);
        $("#svg1").unbind("mouseup", onrelease).unbind("mouseout", onrelease);
        this.style.cursor = "default";
    }
    var ns = "http://www.w3.org/2000/svg";
    var onsvgmousemove = function (evt) {
        if (!adorner.rect) {
            hideResizer();
            adorner.pos = getPosition(this.parentNode);
            adorner.pos.x = adorner.pos.x + parseFloat(this.style.left.replace("px", ""));
            adorner.pos.y = adorner.pos.y + parseFloat(this.style.top.replace("px", ""));
            adorner.rect = document.createElementNS(ns, "rect");
            adorner.rect.setAttributeNS(null, "x", startX - adorner.pos.x);
            adorner.rect.setAttributeNS(null, "y", startY - adorner.pos.y);
            adorner.rect.setAttributeNS(null, "class", "e_rect_focus");
            this.appendChild(adorner.rect);
            adorner.rect.onclick = onrectclick;
            adorner.rect.onmousedown = onrectmousedown;
        }
        else {
            if (evt.clientX > startX) {
                adorner.rect.setAttributeNS(null, "width", evt.clientX - startX);
            }
            else {
                adorner.rect.setAttributeNS(null, "x", evt.clientX - adorner.pos.x);
                adorner.rect.setAttributeNS(null, "width", startX - evt.clientX);
            }
            if (evt.clientY > startY) {
                adorner.rect.setAttributeNS(null, "height", evt.clientY - startY);
            }
            else {
                adorner.rect.setAttributeNS(null, "y", evt.clientY - adorner.pos.y);
                adorner.rect.setAttributeNS(null, "height", startY - evt.clientY);
            }
        }
    }

    var onsvgrelease = function (evt) {
        if (adorner.rect) {
            calculateResizerPosition(adorner.rect);
        }
        adorner = null;
        $("#svg1").unbind("mousemove", onsvgmousemove).unbind("mouseup", onsvgrelease);
    }

    var onrectclick = function (evt) {
        calculateResizerPosition(this);
        evt.stopPropagation();
    }

    var onrectmousedown = function (evt) {
        evt.stopPropagation();
        adorner = {
            rect: this,
            x: this.x.baseVal.value,
            y: this.y.baseVal.value,
            startX: evt.clientX,
            startY: evt.clientY
        };
        hideResizer();
        $(document.body).bind("mousemove", onrectmousemove_body).bind("mouseup", onrectrelease_body);
    }

    var onrectmousemove_body = function (evt) {
        adorner.rect.setAttributeNS(null, "x", adorner.x + evt.clientX - adorner.startX);
        adorner.rect.setAttributeNS(null, "y", adorner.y + evt.clientY - adorner.startY);
    }

    var onrectrelease_body = function () {
        adorner = null;
        $(document.body).unbind("mousemove", onrectmousemove_body).unbind("mouseup", onrectrelease_body);
    }

    var onresizermousedown = function (evt) {
        evt.stopPropagation();
        adorner = {
            rect: choosed,
            resizer: this,
            startX: evt.clientX,
            startY: evt.clientY,
            initX: choosed.x.baseVal.value,
            initY: choosed.y.baseVal.value,
            initHeight: choosed.height.baseVal.value,
            initWidth: choosed.width.baseVal.value,
        }
        hideResizer();
        $(document.body).bind("mousemove", onresizermousemove_body).bind("mouseup", onresizermouseup_body);
    }

    var onresizermousemove_body = function (evt) {
        var resizerID = adorner.resizer.getAttributeNS(null, "id");
        if (resizerID == "rect_top" || resizerID == "rect_left_top" || resizerID == "rect_right_top") {
            var height = adorner.initHeight + adorner.startY - evt.clientY;
            if (height <= 0) {
                adorner.rect.setAttributeNS(null, "y", adorner.initY + adorner.initHeight);
                adorner.rect.setAttributeNS(null, "height", Math.abs(height));
            }
            else {
                var y = adorner.initY - (adorner.startY - evt.clientY);
                if (y < 0) {
                    y = 0;
                }
                else {
                    adorner.rect.setAttributeNS(null, "height", height);
                }
                adorner.rect.setAttributeNS(null, "y", y);
            }
        }
        if (resizerID == "rect_right" || resizerID == "rect_right_top" || resizerID == "rect_right_bottom") {
            var width = adorner.initWidth + (evt.clientX - adorner.startX);
            if (width <= 0) {
                var x = adorner.initX - (adorner.startX - evt.clientX - adorner.initWidth);
                if (x < 0) {
                    x = 0;
                }
                adorner.rect.setAttributeNS(null, "x", x);
                adorner.rect.setAttributeNS(null, "width", Math.abs(width));
            }
            else {
                adorner.rect.setAttributeNS(null, "width", width);
            }
        }
        if (resizerID == "rect_bottom" || resizerID == "rect_left_bottom" || resizerID == "rect_right_bottom") {
            var height = adorner.initHeight + evt.clientY - adorner.startY;
            if (height <= 0) {
                var y = adorner.initY - (adorner.startY - evt.clientY - adorner.initHeight);
                if (y < 0) {
                    y = 0;
                }
                adorner.rect.setAttributeNS(null, "y", y);
                adorner.rect.setAttributeNS(null, "height", Math.abs(height));
            }
            else {
                adorner.rect.setAttributeNS(null, "height", height);
            }
        }
        if (resizerID == "rect_left" || resizerID == "rect_left_top" || resizerID == "rect_left_bottom") {
            var width = adorner.initWidth + (adorner.startX - evt.clientX);
            if (width <= 0) {
                adorner.rect.setAttributeNS(null, "x", adorner.initX + adorner.initWidth);
                adorner.rect.setAttributeNS(null, "width", Math.abs(width));
            }
            else {
                var x = adorner.initX - (adorner.startX - evt.clientX);
                if (x < 0) {
                    x = 0;
                }
                else {
                    adorner.rect.setAttributeNS(null, "width", width);
                }
                adorner.rect.setAttributeNS(null, "x", x);
            }
        }
    }

    var onresizermouseup_body = function () {
        calculateResizerPosition(adorner.rect);
        adorner = null;
        $(document.body).unbind("mousemove", onresizermousemove_body).unbind("mouseup", onresizermouseup_body);
    }

    function getPosition(element) {
        var pos = { y: element.offsetTop, x: element.offsetLeft };
        if (element.offsetParent != null) {
            var temp = getPosition(element.offsetParent);
            pos.x += temp.x;
            pos.y += temp.y;
        }
        return pos;
    }

    function calculateResizerPosition(rect) {
        choosed = rect;
        var x = rect.x.baseVal.value;
        var y = rect.y.baseVal.value;
        var width = rect.width.baseVal.value;
        var height = rect.height.baseVal.value;
        var lefttop = document.getElementById("rect_left_top");
        lefttop.style.display = "";
        lefttop.setAttributeNS(null, "x", x - 4);
        lefttop.setAttributeNS(null, "y", y - 4);
        lefttop.parentNode.appendChild(lefttop);
        var top = document.getElementById("rect_top");
        top.style.display = "";
        top.setAttributeNS(null, "x", x + width / 2 - 4);
        top.setAttributeNS(null, "y", y - 4);
        top.parentNode.appendChild(top);
        var righttop = document.getElementById("rect_right_top");
        righttop.style.display = "";
        righttop.setAttributeNS(null, "x", x + width - 4);
        righttop.setAttributeNS(null, "y", y - 4);
        righttop.parentNode.appendChild(righttop);
        var right = document.getElementById("rect_right");
        right.style.display = "";
        right.setAttributeNS(null, "x", x + width - 4);
        right.setAttributeNS(null, "y", y + height / 2 - 4);
        right.parentNode.appendChild(right);
        var rightbottom = document.getElementById("rect_right_bottom");
        rightbottom.style.display = "";
        rightbottom.setAttributeNS(null, "x", x + width - 4);
        rightbottom.setAttributeNS(null, "y", y + height - 4);
        rightbottom.parentNode.appendChild(rightbottom);
        var bottom = document.getElementById("rect_bottom");
        bottom.style.display = "";
        bottom.setAttributeNS(null, "x", x + width / 2 - 4);
        bottom.setAttributeNS(null, "y", y + height - 4);
        bottom.parentNode.appendChild(bottom);
        var leftbottom = document.getElementById("rect_left_bottom");
        leftbottom.style.display = "";
        leftbottom.setAttributeNS(null, "x", x - 4);
        leftbottom.setAttributeNS(null, "y", y + height - 4);
        leftbottom.parentNode.appendChild(leftbottom);
        var left = document.getElementById("rect_left");
        left.style.display = "";
        left.setAttributeNS(null, "x", x - 4);
        left.setAttributeNS(null, "y", y + height / 2 - 4);
        left.parentNode.appendChild(left);
    }

    function hideResizer() {
        document.getElementById("rect_left_top").style.display = "none";
        document.getElementById("rect_top").style.display = "none";
        document.getElementById("rect_right_top").style.display = "none";
        document.getElementById("rect_right").style.display = "none";
        document.getElementById("rect_right_bottom").style.display = "none";
        document.getElementById("rect_bottom").style.display = "none";
        document.getElementById("rect_left_bottom").style.display = "none";
        document.getElementById("rect_left").style.display = "none";
    }
</script>

