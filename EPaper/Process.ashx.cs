using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.Drawing;
using System.IO;
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
            var m = context.Request.Form["m"];
            switch (m)
            {
                case "SaveEPaper":
                    SaveEPaper(context);
                    break;
                case "DeleteEPaper":
                    DeleteEPaper(context);
                    break;
                case "GetEPaperDetails":
                    GetEPaperDetails(context);
                    break;
                case "GetTopEPapers":
                    GetTopEPapers(context);
                    break;
            }
            context.Response.End();
        }

        public void SaveEPaper(HttpContext context)
        {
            //process image
            var rootPath = context.Server.MapPath("~/EPapers");
            var file = Path.Combine(rootPath, "Temp", Path.GetFileName(context.Request.Form["image"]));
            if (!File.Exists(file))
            {
                context.Response.Write(JsonConvert.SerializeObject(new Models.ReturnResult() { IsSuccess = false, Message = "Couldn't find EPaper" }));
                return;
            }
            //save to DB
            var shapes = JArray.Parse(context.Request.Form["shapes"]);
            var prefixPath = DateTime.Now.ToString("yyyy/MM/dd");
            var storeDir = Path.Combine(rootPath, prefixPath);
            if (!Directory.Exists(storeDir))
            {
                Directory.CreateDirectory(storeDir);
            }
            var ePaper = new Models.EPaper();
            ePaper.CreateTime = DateTime.Now;
            var extenstion = Path.GetExtension(file);
            using (var image = Image.FromFile(file))
            {
                var strSize = "{\"x\":" + image.Width + ",\"y\":" + image.Height;
                ePaper.Path = prefixPath + "/" + Guid.NewGuid().ToString() + extenstion;
                var size = GetSize(image.Width, image.Height, 180, 135);
                strSize += ",\"x1\":" + size.Item1 + ",\"y1\":" + size.Item2;
                var thumbImage = image.GetThumbnailImage(size.Item1, size.Item2, () => { return false; }, IntPtr.Zero);
                ePaper.ThumbPath = prefixPath + "/" + Guid.NewGuid().ToString() + extenstion;
                thumbImage.Save(Path.Combine(rootPath, ePaper.ThumbPath));
                size = GetSize(image.Width, image.Height, 600, 800);
                strSize += ",\"x2\":" + size.Item1 + ",\"y2\":" + size.Item2 + "}";
                thumbImage = image.GetThumbnailImage(size.Item1, size.Item2, () => { return false; }, IntPtr.Zero);
                ePaper.BigThumbPath = prefixPath + "/" + Guid.NewGuid().ToString() + extenstion;
                thumbImage.Save(Path.Combine(rootPath, ePaper.BigThumbPath));
                ePaper.Size = strSize;
                using (var dbContext = new Models.DBAccess())
                {
                    dbContext.EPapers.Add(ePaper);
                    dbContext.SaveChanges();
                    foreach (var item in shapes)
                    {
                        if (item.Value<string>("type") == "rect")
                        {
                            var ePaperDetail = new Models.EPaperDetail()
                            {
                                EPaperID = ePaper.ID,
                                Shape = JsonConvert.SerializeObject(item),
                                Path = prefixPath + "/" + Guid.NewGuid().ToString() + extenstion
                            };
                            using (Image block = CutImage(image, item.Value<int>("x"), item.Value<int>("y"), item.Value<int>("width"), item.Value<int>("height")))
                            {
                                block.Save(Path.Combine(rootPath, ePaperDetail.Path));
                            }
                            dbContext.EPaperDetails.Add(ePaperDetail);
                        }
                    }
                    dbContext.SaveChanges();
                }
            }
            File.Delete(file);
        }

        private Image CutImage(Image source, int x, int y, int width, int height)
        {
            Bitmap bitmap = new Bitmap(width, height);
            Graphics graphic = Graphics.FromImage(bitmap);
            graphic.DrawImage(source, 0, 0, new Rectangle(x, y, width, height), GraphicsUnit.Pixel);
            return bitmap;
        }

        private Tuple<int, int> GetSize(int imgWidth, int imgHeight, int maxWidth, int maxHeight)
        {
            if (imgHeight > maxHeight || imgWidth > maxWidth)
            {
                if (imgWidth > imgHeight)
                {
                    //以宽度为准
                    return new Tuple<int, int>(maxWidth, imgHeight * maxWidth / imgWidth);
                }
                else
                {
                    return new Tuple<int, int>(imgWidth * maxHeight / imgHeight, maxHeight);
                }
            }
            return new Tuple<int, int>(imgWidth, imgHeight);
        }

        private void GetEPaperDetails(HttpContext context)
        {
            var id = Convert.ToInt32(context.Request.Form["id"]);
            using (var dbContext = new Models.DBAccess())
            {
                context.Response.Write(JsonConvert.SerializeObject(dbContext.EPaperDetails.Where(m => m.EPaperID == id).Select(m => new { m.ID, m.Shape }).ToList()));
            }
        }

        private void DeleteEPaper(HttpContext context)
        {
            var id = Convert.ToInt32(context.Request.Form["id"]);
            var rootPath = context.Server.MapPath("~/EPapers");
            using (var dbContext = new Models.DBAccess())
            {
                var epaper = dbContext.EPapers.FirstOrDefault(m => m.ID == id);
                if (epaper == null)
                {
                    return;
                }
                TryDeleteFile(Path.Combine(rootPath, epaper.Path));
                TryDeleteFile(Path.Combine(rootPath, epaper.ThumbPath));
                TryDeleteFile(Path.Combine(rootPath, epaper.BigThumbPath));
                foreach (var detail in epaper.EPaperDetails)
                {
                    TryDeleteFile(Path.Combine(rootPath, detail.Path));
                }
                dbContext.EPaperDetails.RemoveRange(epaper.EPaperDetails);
                dbContext.EPapers.Remove(epaper);
                dbContext.SaveChanges();
            }
        }

        private void GetTopEPapers(HttpContext context)
        {
            using (var dbContext = new Models.DBAccess())
            {
                context.Response.Write(JsonConvert.SerializeObject(dbContext.EPapers.OrderByDescending(m => m.CreateTime).Take(20).Select(m => new { m.ID, m.BigThumbPath, m.ThumbPath, m.CreateTime, m.Size }).ToList()));
            }
        }

        private void TryDeleteFile(string path)
        {
            try
            {
                File.Delete(path);
            }
            catch { }
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