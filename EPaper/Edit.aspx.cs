using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace EPaper
{
    public partial class Edit : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            var script = "";
            try
            {
                var dataid = int.Parse(Request.QueryString["id"]);
                script += "var dataid=\"" + dataid + "\";";
            }
            catch
            {
                script += "var dataid=\"0\";";
            }
            script += "var baseurl=\"" + this.ResolveUrl("~/EPapers/") + "\";";
            this.ClientScript.RegisterStartupScript(this.GetType(), "AA", script, true);
        }
    }
}