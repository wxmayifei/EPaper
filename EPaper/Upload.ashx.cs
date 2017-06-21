using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.IO;
using System.Drawing;

namespace EPaper
{
    /// <summary>
    /// Upload 的摘要说明
    /// </summary>
    public class Upload : IHttpHandler
    {

        public void ProcessRequest(HttpContext context)
        {
            if (context.Request.Files.Count > 0)
            {
                var file = context.Request.Files[0];
                var savePath = "~/EPapers/Temp/" + Guid.NewGuid().ToString() + Path.GetExtension(file.FileName);
                var physicalPath = context.Server.MapPath(savePath);
                file.SaveAs(physicalPath);
                using (Image image = Bitmap.FromFile(physicalPath))
                {
                    context.Response.Write("{\"url\":\"" + VirtualPathUtility.ToAbsolute(savePath) + "\",\"height\":" + image.Height + ",\"width\":" + image.Width + "}");
                }
                context.Response.End();
            }
        }

        public bool IsReusable
        {
            get
            {
                return false;
            }
        }
    }
}