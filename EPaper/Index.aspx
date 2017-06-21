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
            </div>
            <div class="row">
                <div class="col-md-3">
                </div>
                <div class="col-md-9">
                </div>
            </div>
        </div>
    </form>
</body>
</html>
<script type="text/javascript">
    function redirectToCreate() {
        window.location.href = "<%=this.ResolveClientUrl("~/Edit.aspx") %>";
        return false;
    }
</script>
