using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace EPaper
{
    public partial class Index : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            //if (!IsPostBack)
            //{
                //get first 20 items
                //using (var dbContext = new Models.DBAccess())
                //{
                //    var html = "";
                //    foreach (var epaper in dbContext.EPapers.OrderByDescending(m => m.CreateTime).Take(20))
                //    {
                //        html += "<a href=\"javascript:void(0)\" class=\"thumbnail\" onclick=\"showBigThumb(" + epaper.ID + ",'" + epaper.BigThumbPath + "')\"><img src=\"" + this.ResolveUrl("~/EPapers/" + epaper.ThumbPath) + "\" /></a>";
                //    }
                //    ltThumbs.Text = html;
                //}
            //}
            this.ClientScript.RegisterStartupScript(this.GetType(), "AA", "var baseurl=\"" + this.ResolveUrl("~/EPapers/") + "\"", true);
        }
    }
}