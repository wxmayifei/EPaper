using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace EPaper
{
    /// <summary>
    /// Process 的摘要说明
    /// </summary>
    public class Process : IHttpHandler
    {

        public void ProcessRequest(HttpContext context)
        {
            
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